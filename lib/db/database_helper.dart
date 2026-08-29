import 'package:sqflite/sqflite.dart' as sql; // alias
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static sql.Database? _database;

  Future<sql.Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<sql.Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'expense_tracker.db');
    return await sql.openDatabase(
      path,
      version: 2, // ✅ bumped: version 2 adds multi-wallet support
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(sql.Database db, int version) async {
    await db.execute('''
      CREATE TABLE wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL DEFAULT '👛',
        initialBalance REAL NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');
    // ✅ Seed the default "Cash" wallet at id 1. Every transaction defaults
    // to this wallet_id, so nothing is ever left without a home.
    await db.insert('wallets', {
      'id': Wallet.cashWalletId,
      'name': 'Cash',
      'icon': '💵',
      'initialBalance': 0.0,
      'createdAt': DateTime.now().toIso8601String(),
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
  }

  Future<void> _onUpgrade(
    sql.Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // ✅ Migrating an install that predates wallets: add the table,
      // seed "Cash", and tag every existing transaction as belonging to it
      // via the column default, so nobody's history disappears.
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
  }

  // ---------- Transactions ----------

  Future<int> insertTransaction(Transaction txn) async {
    final db = await database;
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
    return await db.update(
      'transactions',
      txn.toMap(),
      where: 'id = ?',
      whereArgs: [txn.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('transactions');
  }

  // ---------- Wallets ----------

  Future<int> insertWallet(Wallet wallet) async {
    final db = await database;
    final map = wallet.toMap()..remove('id');
    return await db.insert('wallets', map);
  }

  Future<List<Wallet>> getAllWallets() async {
    final db = await database;
    final maps = await db.query('wallets', orderBy: 'id ASC');
    return maps.map((m) => Wallet.fromMap(m)).toList();
  }

  Future<int> updateWallet(Wallet wallet) async {
    final db = await database;
    return await db.update(
      'wallets',
      wallet.toMap(),
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }

  /// Deletes a wallet AND every transaction tagged with it.
  /// The default "Cash" wallet (id 1) should never be passed in here —
  /// that's guarded against up in WalletProvider before this is called.
  Future<void> deleteWallet(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'wallet_id = ?', whereArgs: [id]);
    await db.delete('wallets', where: 'id = ?', whereArgs: [id]);
  }
}
