import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:expense_tracker/db/database_helper.dart';
import 'package:expense_tracker/db/debt_store.dart';
import 'package:expense_tracker/db/transaction_queries.dart';
import 'package:expense_tracker/models/debt.dart';
import 'package:expense_tracker/providers/debt_provider.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/utils/backup_service.dart';
import 'package:expense_tracker/utils/analytics_period.dart';

void main() {
  sqfliteFfiInit();
  late Database db;
  late DebtStore store;
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('wallet_debt_test_');
    db = await DatabaseHelper().openAt(
      '${directory.path}/wallet.db',
      factory: databaseFactoryFfi,
    );
    store = DebtStore(open: () async => db);
  });
  tearDown(() async {
    await db.close();
    await directory.delete(recursive: true);
  });
  Debt debt({
    DebtDirection direction = DebtDirection.lent,
    double rate = 10,
    String person = 'Juan',
  }) => Debt(
    personName: person,
    direction: direction,
    principalMinor: 10000,
    interestRate: rate,
    totalDueMinor: Debt.totalDue(10000, rate),
    remainingMinor: Debt.totalDue(10000, rate),
    walletId: 1,
    createdAt: DateTime.now(),
  );

  test('Money rounding and flat interest use minor units', () {
    expect(toMinor(0.1 + 0.2), 30);
    expect(Debt.totalDue(101, 5), 106);
    expect(debt().splitRepayment(10500), (principal: 10000, interest: 500));
    expect(() => debt().splitRepayment(11001), throwsArgumentError);
    expect(() => toMinor(double.nan), throwsArgumentError);
  });

  test(
    'All keeps partial repayments visible and preserves status filters',
    () async {
      final id = await store.save(debt());
      final archivedId = await store.save(debt(person: 'Archived'));
      await store.archive(archivedId);
      final provider = DebtProvider(store: store);
      addTearDown(provider.dispose);
      await provider.load();
      expect(provider.status, isNull);
      expect(provider.debts.map((d) => d.id), [archivedId, id]);
      await provider.repay(provider.debts.last, 4000);
      final partial = provider.debts.last;
      expect(partial.status, DebtStatus.partial);
      expect(partial.remainingMinor, 7000);
      expect((await store.repayments(id)).single.amountMinor, 4000);
      await provider.load(filter: DebtStatus.outstanding);
      expect(provider.debts, isEmpty);
      await provider.load(filter: DebtStatus.partial);
      expect(provider.debts.single.id, id);
      await provider.load(filter: DebtStatus.archived);
      expect(provider.debts.single.id, archivedId);
      await provider.load(all: true);
      expect(provider.status, isNull);
      expect(provider.debts.length, 2);
    },
  );

  test(
    'All paginates across mixed debt statuses without skipping rows',
    () async {
      for (var i = 0; i < 32; i++) {
        final id = await store.save(debt(person: 'Person $i'));
        if (i.isEven) await store.repay(id, 100);
      }
      final first = await store.list(null);
      final second = await store.list(null, beforeId: first.last.id);
      expect(first.length, 30);
      expect(second.length, 2);
      expect(
        {...first.map((d) => d.id), ...second.map((d) => d.id)}.length,
        32,
      );
    },
  );

  for (final direction in DebtDirection.values) {
    test(
      '${direction.name}: principal first, analytics isolation, auto-archive',
      () async {
        final id = await store.save(debt(direction: direction));
        expect((await store.totals())[direction], 11000);
        final sign = direction == DebtDirection.lent ? -1 : 1;
        var totals = (await TransactionQueries.totals(
          db,
          DateTime.now(),
        )).single;
        expect(totals['balance'], sign * 100);
        expect(totals['income'], 0);
        expect(totals['expense'], 0);
        expect(await TransactionQueries.categories(db), isEmpty);
        await store.repay(id, 4000);
        expect(
          (await store.list(DebtStatus.partial)).single.principalPaidMinor,
          4000,
        );
        expect((await store.totals())[direction], 7000);
        await store.repay(id, 6500);
        totals = (await TransactionQueries.totals(db, DateTime.now())).single;
        expect(totals['balance'], -sign * 5);
        expect(
          totals[direction == DebtDirection.lent ? 'income' : 'expense'],
          5,
        );
        expect(
          totals[direction == DebtDirection.lent
              ? 'weekly_income'
              : 'weekly_expense'],
          5,
        );
        await store.repay(id, 500);
        final archived = (await store.list(DebtStatus.archived)).single;
        expect(archived.remainingMinor, 0);
        expect(archived.principalPaidMinor, 10000);
        expect(await store.totals(), isEmpty);
        expect((await store.repayments(id)).length, 3);
        for (final row in await db.query('transactions')) {
          expect((await store.forTransaction(Transaction.fromMap(row))).id, id);
        }
        final before = await db.query('transactions');
        await expectLater(store.repay(id, 1), throwsArgumentError);
        expect(await db.query('transactions'), before);
      },
    );
  }
  test('Overpayment and invalid wallet roll back atomically', () async {
    final id = await store.save(debt());
    await expectLater(store.repay(id, 11001), throwsArgumentError);
    expect(await store.repayments(id), isEmpty);
    expect(
      (await store.list(DebtStatus.outstanding)).single.remainingMinor,
      11000,
    );
    final original = await db.query('transactions');
    final systemId =
        (await db.query('wallets', where: 'is_system = 1')).first['id'] as int;
    final bad = Debt(
      personName: 'Invalid',
      direction: DebtDirection.lent,
      principalMinor: 100,
      totalDueMinor: 100,
      remainingMinor: 100,
      walletId: systemId,
      createdAt: DateTime.now(),
    );
    await expectLater(store.save(bad), throwsStateError);
    expect(await db.query('transactions'), original);
  });
  test(
    'Edits after repayment preserve money, contacts upsert and order',
    () async {
      final id = await store.save(debt());
      await store.save(debt(person: 'Maria'));
      await store.save(debt());
      expect((await store.contacts()).map((c) => c.name), ['Juan', 'Maria']);
      await store.repay(id, 1000);
      final old = (await store.list(DebtStatus.partial)).single;
      final map = old.toMap()..['principal_minor'] = 20000;
      await expectLater(store.save(Debt.fromMap(map)), throwsStateError);
      map['principal_minor'] = 10000;
      map['person_name'] = 'Juan updated';
      await store.save(Debt.fromMap(map));
      final updated = (await store.list(DebtStatus.partial)).single;
      expect(updated.remainingMinor, 10000);
      expect(updated.personName, 'Juan updated');
    },
  );
  test(
    '5001 rows paginate without skipping equal timestamps; SQL totals include all',
    () async {
      final batch = db.batch();
      for (int i = 0; i < 5001; i++) {
        batch.insert(
          'transactions',
          Transaction(
            type: TransactionType.income,
            amount: 1,
            date: DateTime(2026, 11, 2),
          ).toMap()..remove('id'),
        );
      }
      await batch.commit(noResult: true);
      final ids = <int>{};
      Transaction? before;
      do {
        final page = await TransactionQueries.page(db, before: before);
        expect(page.length, lessThanOrEqualTo(50));
        if (page.isEmpty) break;
        ids.addAll(page.map((t) => t.id!));
        before = page.last;
      } while (true);
      expect(ids.length, 5001);
      expect(
        (await TransactionQueries.totals(
          db,
          DateTime(2026, 11, 2),
        )).single['balance'],
        5001,
      );
    },
  );
  for (final format in ['csv', 'xlsx']) {
    test(
      '$format backups restore debt, repayment, wallet and analytics totals',
      () async {
        await db.update('wallets', {'initialBalance': 123.45}, where: 'id = 1');
        final id = await store.save(debt(direction: DebtDirection.borrowed));
        await store.repay(id, 10500);
        final totals = await TransactionQueries.totals(db, DateTime.now());
        final snapshot = await BackupService.export(
          directory.path,
          format,
          database: db,
        );
        final other = await DatabaseHelper().openAt(
          '${directory.path}/restore.db',
          factory: databaseFactoryFfi,
        );
        try {
          await BackupService.import(snapshot, database: other);
          final restored = DebtStore(open: () async => other);
          expect(
            (await other.query(
              'wallets',
              where: 'id = 1',
            )).single['initialBalance'],
            123.45,
          );
          expect(await restored.totals(), await store.totals());
          expect(
            (await restored.list(DebtStatus.partial)).single.remainingMinor,
            500,
          );
          expect((await other.query('debt_repayments')).length, 1);
          expect(
            await TransactionQueries.totals(other, DateTime.now()),
            totals,
          );
          expect(await other.rawQuery('PRAGMA foreign_key_check'), isEmpty);
        } finally {
          await other.close();
        }
      },
    );
  }
  test(
    'Archive preserves cash; delete reverses principal and interest',
    () async {
      final id = await store.save(debt());
      await store.repay(id, 10500);
      final before = await TransactionQueries.totals(db, DateTime.now());
      await store.archive(id);
      expect(await store.totals(), isEmpty);
      expect(await TransactionQueries.totals(db, DateTime.now()), before);
      await store.delete(id);
      expect(await db.query('transactions'), isEmpty);
      expect(await db.query('debt_repayments'), isEmpty);
    },
  );
  test('Malformed backup rolls back wallets and debt rows', () async {
    final id = await store.save(debt());
    await store.repay(id, 1000);
    final path = await BackupService.export(
      directory.path,
      'csv',
      database: db,
    );
    final rows = const CsvToListConverter(
      shouldParseNumbers: false,
    ).convert(await File(path).readAsString());
    final record = rows.firstWhere((r) => r.first == 'transactions');
    final transaction = jsonDecode(record[1] as String) as Map;
    transaction['wallet_id'] = 999999;
    record[1] = jsonEncode(transaction);
    await File(path).writeAsString(const ListToCsvConverter().convert(rows));
    final beforeWallets = await db.query('wallets');
    final beforeDebts = await db.query('debts');
    await expectLater(
      BackupService.import(path, database: db),
      throwsFormatException,
    );
    expect(await db.query('wallets'), beforeWallets);
    expect(await db.query('debts'), beforeDebts);
  });
  test('Older CSV imports without debt fields remain supported', () async {
    final path = '${directory.path}/old.csv';
    await File(path).writeAsString(
      'Date,Type,Category,Amount,Remark,Wallet\r\n2026-11-02,Expense,food,12.50,Lunch,Cash\r\n',
    );
    expect(await BackupService.import(path, database: db), 1);
    final transaction = Transaction.fromMap(
      (await db.query('transactions')).single,
    );
    expect(transaction.amount, 12.5);
    expect(transaction.debtId, isNull);
    expect((await TransactionQueries.categories(db))[Category.food], 12.5);
  });
  test('v3 upgrade preserves existing REAL values and balances', () async {
    final path = '${directory.path}/v3.db';
    var old = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, _) async {
          await db.execute(
            '''CREATE TABLE wallets (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,
        icon TEXT DEFAULT 'cash', initialBalance REAL NOT NULL DEFAULT 0, createdAt TEXT NOT NULL,
        category TEXT DEFAULT 'Cash', colorValue INTEGER DEFAULT 4280391411, subtitle TEXT)''',
          );
          await db.execute(
            '''CREATE TABLE transactions (id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL,
        amount REAL NOT NULL, category INTEGER, remark TEXT, date TEXT NOT NULL, wallet_id INTEGER NOT NULL DEFAULT 1)''',
          );
          await db.insert('wallets', {
            'id': 1,
            'name': 'Cash',
            'initialBalance': 123.45,
            'createdAt': '2026-01-01',
          });
          await db.insert('transactions', {
            'type': 'income',
            'amount': 0.1 + 0.2,
            'date': '2026-01-01',
            'wallet_id': 1,
          });
        },
      ),
    );
    final wallets = await old.query('wallets');
    final transactions = await old.query('transactions');
    await old.close();
    old = await DatabaseHelper().openAt(path, factory: databaseFactoryFfi);
    try {
      expect(await old.getVersion(), 4);
      final upgradedWallet = (await old.query(
        'wallets',
        where: 'id = 1',
      )).single;
      for (final entry in wallets.single.entries) {
        expect(upgradedWallet[entry.key], entry.value);
      }
      final upgradedTransaction = (await old.query('transactions')).single;
      for (final entry in transactions.single.entries) {
        expect(upgradedTransaction[entry.key], entry.value);
      }
      expect(
        (await old.query(
          'wallets',
          where: 'is_system = 0',
        )).single['initialBalance'],
        wallets.single['initialBalance'],
      );
      expect(
        (await old.query('transactions')).single['amount'],
        transactions.single['amount'],
      );
      expect((await old.query('wallets', where: 'is_system = 1')).length, 2);
      expect(
        (await old.rawQuery('PRAGMA foreign_keys')).single.values.single,
        1,
      );
    } finally {
      await old.close();
    }
  });
  test(
    'Reopening an installed database keeps debts, payments and wallets',
    () async {
      final id = await store.save(debt());
      await store.repay(id, 2000);
      await db.update('wallets', {'initialBalance': 123.45}, where: 'id = 1');
      final before = {
        for (final table in [
          'wallets',
          'transactions',
          'debts',
          'debt_repayments',
          'contacts',
        ])
          table: await db.query(table),
      };
      await db.close();
      db = await DatabaseHelper().openAt(
        '${directory.path}/wallet.db',
        factory: databaseFactoryFfi,
      );
      for (final table in before.keys) {
        expect(await db.query(table), before[table]);
      }
    },
  );
  test('Explicit Clear all removes financial data and resets Cash', () async {
    final id = await store.save(debt());
    await store.repay(id, 1000);
    await db.insert('wallets', {
      'name': 'Savings',
      'initialBalance': 500,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await db.update('wallets', {'initialBalance': 123}, where: 'id = 1');
    await db.insert('budgets', {'category': 0, 'limit_minor': 1000});
    await DatabaseHelper().clearAll(connection: db);
    for (final table in [
      'transactions',
      'debts',
      'debt_repayments',
      'contacts',
      'budgets',
    ]) {
      expect(await db.query(table), isEmpty);
    }
    final real = await db.query('wallets', where: 'is_system = 0');
    expect(real.length, 1);
    expect(real.single['id'], 1);
    expect(real.single['initialBalance'], 0);
    expect((await db.query('wallets', where: 'is_system = 1')).length, 2);
  });
  test(
    'Today and week aggregates include boundaries and exclude debt principal',
    () async {
      for (final date in [
        DateTime(2026, 11, 1, 23, 59, 59),
        DateTime(2026, 11, 2),
        DateTime(2026, 11, 3),
        DateTime(2026, 11, 8, 23, 59, 59),
        DateTime(2026, 11, 9),
      ]) {
        await db.insert(
          'transactions',
          Transaction(
            type: TransactionType.expense,
            amount: 10,
            category: Category.food,
            date: date,
          ).toMap()..remove('id'),
        );
      }
      await db.insert(
        'transactions',
        Transaction(
          type: TransactionType.expense,
          amount: 100,
          category: Category.food,
          date: DateTime(2026, 11, 2),
          debtId: 99,
        ).toMap()..remove('id'),
      );
      final today = analyticsPeriod(
        AnalyticsDateFilter.today,
        DateTime(2026, 11, 2),
      );
      final week = analyticsPeriod(
        AnalyticsDateFilter.thisWeek,
        DateTime(2026, 11, 2),
      );
      expect(
        (await TransactionQueries.categories(
          db,
          start: today.start,
          end: today.end,
        ))[Category.food],
        10,
      );
      expect(
        (await TransactionQueries.categories(
          db,
          start: week.start,
          end: week.end,
        ))[Category.food],
        30,
      );
    },
  );
  test('Failed update rolls back schema changes and retains legacy data', () async {
    final path = '${directory.path}/failed-upgrade.db';
    var legacy = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 3,
        onCreate: (db, _) async {
          await db.execute(
            "CREATE TABLE wallets(id INTEGER PRIMARY KEY, name TEXT, icon TEXT, initialBalance REAL, createdAt TEXT, category TEXT, colorValue INTEGER, subtitle TEXT)",
          );
          await db.execute(
            "CREATE TABLE transactions(id INTEGER PRIMARY KEY, type TEXT, amount REAL, category INTEGER, remark TEXT, date TEXT, wallet_id INTEGER)",
          );
          await db.insert('wallets', {
            'id': 1,
            'name': 'Cash',
            'initialBalance': 876.54,
          });
          await db.insert('transactions', {
            'id': 1,
            'type': 'income',
            'amount': 500,
            'date': '2026-11-02',
            'wallet_id': 1,
          });
          // Simulate an unexpected existing table that makes the new migration fail.
          await db.execute('CREATE TABLE debts(id INTEGER PRIMARY KEY)');
        },
      ),
    );
    final originalWallets = await legacy.query('wallets');
    final originalTransactions = await legacy.query('transactions');
    final originalColumns = await legacy.rawQuery('PRAGMA table_info(wallets)');
    await legacy.close();
    await expectLater(
      DatabaseHelper().openAt(path, factory: databaseFactoryFfi),
      throwsA(anything),
    );
    legacy = await databaseFactoryFfi.openDatabase(path);
    try {
      expect(await legacy.getVersion(), 3);
      expect(await legacy.query('wallets'), originalWallets);
      expect(await legacy.query('transactions'), originalTransactions);
      expect(
        await legacy.rawQuery('PRAGMA table_info(wallets)'),
        originalColumns,
      );
    } finally {
      await legacy.close();
    }
  });
  test('An older app refuses a newer database without resetting it', () async {
    final id = await store.save(debt());
    await store.repay(id, 1000);
    final before = await db.query('debts');
    await db.setVersion(5);
    await db.close();
    final path = '${directory.path}/wallet.db';
    await expectLater(
      DatabaseHelper().openAt(path, factory: databaseFactoryFfi),
      throwsA(anything),
    );
    db = await databaseFactoryFfi.openDatabase(path);
    expect(await db.getVersion(), 5);
    expect(await db.query('debts'), before);
  });
}
