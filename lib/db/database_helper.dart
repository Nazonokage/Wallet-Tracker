import 'package:sqflite/sqflite.dart' as sql; // alias
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import 'debt_store.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static sql.Database? _database;
  static Future<sql.Database>? _opening;

  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    final pending = _opening ??= _initDatabase();
    try {
      return _database = await pending;
    } finally {
      _opening = null;
    }
  }

  Future<sql.Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'expense_tracker.db');
    return openAt(path);
  }

  Future<sql.Database> openAt(
    String path, {
    sql.DatabaseFactory? factory,
  }) async {
    return await (factory ?? sql.databaseFactory).openDatabase(
      path,
      options: sql.OpenDatabaseOptions(
        version: 4,
        onConfigure: (db) async {
          await db.execute("PRAGMA foreign_keys = ON");
          await db.rawQuery("PRAGMA journal_mode=WAL");
        },
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        // Never recreate storage to make an older binary open a newer database.
        onDowngrade: (db, oldVersion, newVersion) async {
          throw StateError(
            'Database downgrade blocked: $oldVersion -> $newVersion',
          );
        },
      ),
    );
  }

  Future<void> _onCreate(sql.Database db, int version) async {
    await db.execute('''
      CREATE TABLE wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL DEFAULT '👛',
        initialBalance REAL NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'Bank Accounts',
        colorValue INTEGER NOT NULL DEFAULT 4280391411,
        subtitle TEXT
      )
    ''');
    // ✅ Seed the default "Cash" wallet at id 1.
    await db.insert('wallets', {
      'id': Wallet.cashWalletId,
      'name': 'Cash',
      'icon': '💵',
      'initialBalance': 0.0,
      'createdAt': DateTime.now().toIso8601String(),
      'category': 'Cash',
      'colorValue': 0xFF388E3C,
      'subtitle': 'Physical Cash',
    });
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category INTEGER,
        remark TEXT,
        date TEXT NOT NULL,
        wallet_id INTEGER NOT NULL DEFAULT ${Wallet.cashWalletId}
      )
    ''');
    await DebtStore.migrate(db);
  }

  Future<void> _onUpgrade(
    sql.Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS wallets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon TEXT NOT NULL DEFAULT '👛',
          initialBalance REAL NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL
        )
      ''');

      final existingCash = await db.query(
        'wallets',
        where: 'id = ?',
        whereArgs: [Wallet.cashWalletId],
      );
      if (existingCash.isEmpty) {
        await db.insert('wallets', {
          'id': Wallet.cashWalletId,
          'name': 'Cash',
          'icon': '💵',
          'initialBalance': 0.0,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      final columns = await db.rawQuery('PRAGMA table_info(transactions)');
      final hasWalletId = columns.any((c) => c['name'] == 'wallet_id');
      if (!hasWalletId) {
        await db.execute(
          'ALTER TABLE transactions ADD COLUMN wallet_id INTEGER NOT NULL DEFAULT ${Wallet.cashWalletId}',
        );
      }
    }

    if (oldVersion < 3) {
      final columns = await db.rawQuery('PRAGMA table_info(wallets)');
      final hasCategory = columns.any((c) => c['name'] == 'category');
      if (!hasCategory) {
        await db.execute(
          "ALTER TABLE wallets ADD COLUMN category TEXT NOT NULL DEFAULT 'Bank Accounts'",
        );
      }
      final hasColorValue = columns.any((c) => c['name'] == 'colorValue');
      if (!hasColorValue) {
        await db.execute(
          'ALTER TABLE wallets ADD COLUMN colorValue INTEGER NOT NULL DEFAULT 4280391411',
        );
      }
      final hasSubtitle = columns.any((c) => c['name'] == 'subtitle');
      if (!hasSubtitle) {
        await db.execute('ALTER TABLE wallets ADD COLUMN subtitle TEXT');
      }

      // Update default Cash wallet category & color if it exists
      await db.update(
        'wallets',
        {
          'category': 'Cash',
          'colorValue': 0xFF388E3C,
          'subtitle': 'Physical Cash',
        },
        where: 'id = ?',
        whereArgs: [Wallet.cashWalletId],
      );
    }
    if (oldVersion < 4) await DebtStore.migrate(db);
  }

  // ---------- Transactions ----------

  Future<int> insertTransaction(Transaction txn) async {
    final db = await database;
    if (txn.isDebtManaged) throw StateError('debt');
    final realWallet = await db.query(
      'wallets',
      where: 'id = ? AND is_system = 0',
      whereArgs: [txn.walletId],
      limit: 1,
    );
    if (realWallet.isEmpty) throw StateError('wallet');
    return await db.insert('transactions', txn.toMap());
  }

  Future<List<Transaction>> getAllTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      orderBy: 'date DESC',
    );
    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  Future<int> updateTransaction(Transaction txn) async {
    final db = await database;
    if (txn.isDebtManaged) throw StateError('debt');
    return await db.update(
      'transactions',
      txn.toMap(),
      where: 'id = ? AND debt_id IS NULL AND debt_repayment_id IS NULL',
      whereArgs: [txn.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ? AND debt_id IS NULL AND debt_repayment_id IS NULL',
      whereArgs: [id],
    );
  }

  // Only Settings' explicit, twice-confirmed reset calls this during normal use.
  Future<void> clearAll({sql.Database? connection}) async {
    final db = connection ?? await database;
    await db.transaction((tx) async {
      await tx.delete('transactions');
      await tx.delete('debts');
      await tx.delete('contacts');
      await tx.delete('budgets');
      await tx.delete(
        'wallets',
        where: 'is_system = 0 AND id != ?',
        whereArgs: [Wallet.cashWalletId],
      );
      await tx.update(
        'wallets',
        {'initialBalance': 0.0},
        where: 'id = ?',
        whereArgs: [Wallet.cashWalletId],
      );
    });
  }

  // ---------- Wallets ----------

  Future<int> insertWallet(Wallet wallet) async {
    final db = await database;
    if (wallet.isSystem) throw StateError('wallet');
    final map = wallet.toMap()..remove('id');
    return await db.insert('wallets', map);
  }

  Future<List<Wallet>> getAllWallets() async {
    final db = await database;
    final maps = await db.query(
      'wallets',
      where: 'is_system = 0',
      orderBy: 'id ASC',
    );
    return maps.map((m) => Wallet.fromMap(m)).toList();
  }

  Future<int> updateWallet(Wallet wallet) async {
    final db = await database;
    if (wallet.isSystem) throw StateError('wallet');
    return await db.update(
      'wallets',
      wallet.toMap(),
      where: 'id = ? AND is_system = 0',
      whereArgs: [wallet.id],
    );
  }

  /// Deletes a wallet AND every transaction tagged with it.
  /// The default "Cash" wallet (id 1) should never be passed in here —
  /// that's guarded against up in WalletProvider before this is called.
  Future<void> deleteWallet(int id) async {
    final db = await database;
    await db.transaction((tx) async {
      final debts = await tx.query(
        'debts',
        where: 'wallet_id = ?',
        whereArgs: [id],
        limit: 1,
      );
      final wallet = (await tx.query(
        'wallets',
        where: 'id = ?',
        whereArgs: [id],
      )).single;
      if (id == Wallet.cashWalletId ||
          wallet['is_system'] == 1 ||
          debts.isNotEmpty) {
        throw StateError('wallet');
      }
      await tx.delete('transactions', where: 'wallet_id = ?', whereArgs: [id]);
      await tx.delete('wallets', where: 'id = ?', whereArgs: [id]);
    });
  }
}
