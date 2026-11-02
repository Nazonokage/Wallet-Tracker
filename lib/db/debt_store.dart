import 'package:sqflite/sqflite.dart' as sql;
import '../models/debt.dart';
import '../models/transaction.dart';
import 'database_helper.dart';

class DebtStore {
  final Future<sql.Database> Function() _open;
  DebtStore({Future<sql.Database> Function()? open})
    : _open = open ?? (() => DatabaseHelper().database);

  // sqflite runs onCreate/onUpgrade inside a single transaction already.
  static Future<void> migrate(sql.Database db) async {
    await db.execute(
      'ALTER TABLE wallets ADD COLUMN is_system INTEGER NOT NULL DEFAULT 0',
    );
    await db.execute('ALTER TABLE transactions ADD COLUMN debt_id INTEGER');
    await db.execute(
      'ALTER TABLE transactions ADD COLUMN debt_repayment_id INTEGER',
    );
    await db.execute('''CREATE TABLE debts (
      id INTEGER PRIMARY KEY AUTOINCREMENT, person_name TEXT NOT NULL,
      direction TEXT NOT NULL CHECK(direction IN ('lent','borrowed')),
      principal_minor INTEGER NOT NULL CHECK(principal_minor > 0),
      interest_rate REAL NOT NULL DEFAULT 0, total_due_minor INTEGER NOT NULL,
      remaining_minor INTEGER NOT NULL CHECK(remaining_minor >= 0),
      principal_paid_minor INTEGER NOT NULL DEFAULT 0, due_date TEXT, note TEXT,
      wallet_id INTEGER NOT NULL REFERENCES wallets(id), created_at TEXT NOT NULL,
      status TEXT NOT NULL DEFAULT 'outstanding' CHECK(status IN ('outstanding','partial','archived'))
    )''');
    await db.execute(
      '''CREATE TABLE debt_repayments (
      id INTEGER PRIMARY KEY AUTOINCREMENT, debt_id INTEGER NOT NULL REFERENCES debts(id) ON DELETE CASCADE,
      amount_minor INTEGER NOT NULL CHECK(amount_minor > 0), date TEXT NOT NULL, note TEXT)''',
    );
    await db.execute(
      'CREATE TABLE contacts (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE, last_used TEXT)',
    );
    await db.execute(
      "CREATE TABLE budgets (category INTEGER PRIMARY KEY, limit_minor INTEGER NOT NULL, period TEXT NOT NULL DEFAULT 'monthly')",
    );
    for (final entry in {
      'idx_tx_date': 'transactions(date DESC, id DESC)',
      'idx_tx_wallet_date': 'transactions(wallet_id, date DESC, id DESC)',
      'idx_debts_status_due': 'debts(status, due_date)',
      'idx_debts_direction_status': 'debts(direction, status)',
      'idx_debts_person': 'debts(person_name)',
      'idx_repayments_debt': 'debt_repayments(debt_id)',
      'idx_contacts_last_used': 'contacts(last_used DESC)',
      'idx_tx_debt': 'transactions(debt_id)',
      'idx_tx_repayment': 'transactions(debt_repayment_id)',
    }.entries) {
      await db.execute(
        'CREATE INDEX IF NOT EXISTS ${entry.key} ON ${entry.value}',
      );
    }
    for (final name in ['Receivables', 'Payables']) {
      await db.insert('wallets', {
        'name': name,
        'icon': '👛',
        'initialBalance': 0,
        'createdAt': DateTime.now().toIso8601String(),
        'category': 'Debts',
        'is_system': 1,
      });
    }
  }

  Future<List<Debt>> list(DebtStatus? status, {int? beforeId}) async {
    final db = await _open();
    final conditions = [
      if (status != null) 'status = ?',
      if (beforeId != null) 'id < ?',
    ];
    return (await db.query(
      'debts',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: [
        if (status != null) status.name,
        if (beforeId != null) beforeId,
      ],
      orderBy: 'id DESC',
      limit: 30,
    )).map(Debt.fromMap).toList();
  }

  Future<Map<DebtDirection, int>> totals() async {
    final db = await _open();
    final rows = await db.rawQuery(
      "SELECT direction, SUM(remaining_minor) AS total FROM debts WHERE status IN ('outstanding','partial') GROUP BY direction",
    );
    return {
      for (final r in rows)
        DebtDirection.values.byName(r['direction'] as String):
            r['total'] as int,
    };
  }

  Future<Debt> forTransaction(Transaction transaction) async {
    final db = await _open();
    final rows = transaction.debtId != null
        ? await db.query(
            'debts',
            where: 'id = ?',
            whereArgs: [transaction.debtId],
          )
        : await db.rawQuery(
            'SELECT debts.* FROM debts JOIN debt_repayments ON debt_repayments.debt_id = debts.id WHERE debt_repayments.id = ?',
            [transaction.debtRepaymentId],
          );
    return Debt.fromMap(rows.single);
  }

  Future<List<Contact>> contacts() async =>
      (await (await _open()).query(
            'contacts',
            orderBy: 'last_used DESC, id DESC',
            limit: 20,
          ))
          .map(
            (m) => Contact(
              m['id'] as int,
              m['name'] as String,
              DateTime.tryParse(m['last_used'] as String? ?? ''),
            ),
          )
          .toList();
  Future<List<DebtRepayment>> repayments(int id) async =>
      (await (await _open()).query(
        'debt_repayments',
        where: 'debt_id = ?',
        whereArgs: [id],
        orderBy: 'date DESC, id DESC',
      )).map(DebtRepayment.fromMap).toList();

  Future<void> _contact(sql.Transaction tx, String name) async {
    await tx.rawInsert(
      'INSERT INTO contacts(name,last_used) VALUES(?,?) ON CONFLICT(name) DO UPDATE SET last_used=excluded.last_used',
      [name.trim(), DateTime.now().toIso8601String()],
    );
  }

  Future<void> _realWallet(sql.Transaction tx, int id) async {
    if ((await tx.query(
      'wallets',
      where: 'id = ? AND is_system = 0',
      whereArgs: [id],
    )).isEmpty) {
      throw StateError('wallet');
    }
  }

  Future<int> save(Debt debt) async {
    if (debt.personName.trim().isEmpty) throw ArgumentError('person');
    final due = Debt.totalDue(debt.principalMinor, debt.interestRate);
    return (await _open()).transaction((tx) async {
      await _realWallet(tx, debt.walletId);
      final map = debt.toMap()..remove('id');
      int id;
      if (debt.id == null) {
        map['total_due_minor'] = due;
        map['remaining_minor'] = due;
        map['principal_paid_minor'] = 0;
        map['status'] = 'outstanding';
        id = await tx.insert('debts', map);
      } else {
        id = debt.id!;
        final old = Debt.fromMap(
          (await tx.query('debts', where: 'id = ?', whereArgs: [id])).single,
        );
        final hasRepayments = (await tx.query(
          'debt_repayments',
          where: 'debt_id = ?',
          whereArgs: [id],
          limit: 1,
        )).isNotEmpty;
        final moneyChanged =
            old.principalMinor != debt.principalMinor ||
            old.direction != debt.direction ||
            old.walletId != debt.walletId ||
            old.interestRate != debt.interestRate;
        if (!old.active || (hasRepayments && moneyChanged)) {
          throw StateError('locked');
        }
        map['remaining_minor'] = moneyChanged ? due : old.remainingMinor;
        map['total_due_minor'] = moneyChanged ? due : old.totalDueMinor;
        map['principal_paid_minor'] = old.principalPaidMinor;
        map['created_at'] = old.createdAt.toIso8601String();
        map['status'] = old.status.name;
        await tx.update('debts', map, where: 'id = ?', whereArgs: [id]);
        await tx.delete(
          'transactions',
          where: 'debt_id = ? AND debt_repayment_id IS NULL',
          whereArgs: [id],
        );
      }
      await tx.insert(
        'transactions',
        Transaction(
          type: debt.direction == DebtDirection.lent
              ? TransactionType.expense
              : TransactionType.income,
          amount: debt.principal,
          remark: debt.personName.trim(),
          date: debt.createdAt,
          walletId: debt.walletId,
          debtId: id,
        ).toMap()..remove('id'),
      );
      await _contact(tx, debt.personName);
      return id;
    });
  }

  Future<void> repay(int id, int amount, {String? note}) async {
    await (await _open()).transaction((tx) async {
      final debt = Debt.fromMap(
        (await tx.query('debts', where: 'id = ?', whereArgs: [id])).single,
      );
      final split = debt.splitRepayment(amount);
      final now = DateTime.now();
      final repaymentId = await tx.insert('debt_repayments', {
        'debt_id': id,
        'amount_minor': amount,
        'date': now.toIso8601String(),
        'note': note,
      });
      for (final isInterest in [false, true]) {
        final minor = isInterest ? split.interest : split.principal;
        if (minor == 0) continue;
        await tx.insert(
          'transactions',
          Transaction(
            type: debt.direction == DebtDirection.lent
                ? TransactionType.income
                : TransactionType.expense,
            amount: minor / 100,
            category: isInterest ? Category.others : null,
            remark: debt.personName,
            date: now,
            walletId: debt.walletId,
            debtId: isInterest ? null : id,
            debtRepaymentId: repaymentId,
          ).toMap()..remove('id'),
        );
      }
      final remaining = debt.remainingMinor - amount;
      await tx.update(
        'debts',
        {
          'remaining_minor': remaining,
          'principal_paid_minor': debt.principalPaidMinor + split.principal,
          'status': remaining == 0 ? 'archived' : 'partial',
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> archive(int id) async => (await _open()).transaction((tx) async {
    await tx.update(
      'debts',
      {'status': 'archived'},
      where: 'id = ?',
      whereArgs: [id],
    );
  });

  Future<void> delete(int id) async => (await _open()).transaction((tx) async {
    await tx.rawDelete(
      'DELETE FROM transactions WHERE debt_id = ? OR debt_repayment_id IN (SELECT id FROM debt_repayments WHERE debt_id = ?)',
      [id, id],
    );
    await tx.delete('debts', where: 'id = ?', whereArgs: [id]);
  });
}
