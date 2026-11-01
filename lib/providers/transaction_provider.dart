import 'dart:async';
import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../db/database_helper.dart';
import '../db/transaction_queries.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = const [];
  List<Transaction> get transactions => _transactions;
  List<Transaction> get filteredTransactions => transactions;
  List<Map<String, Object?>> _totals = [];
  bool loading = false, hasMore = false, failed = false;
  int revision = 0, _generation = 0;
  bool _totalsLoaded = false;
  Timer? _searchTimer;
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    if (value == _searchQuery) return;
    _searchQuery = value;
    // Invalidate old responses immediately, even before the debounce fires.
    _generation++;
    _searchTimer?.cancel();
    _searchTimer = Timer(
      const Duration(milliseconds: 200),
      () => loadTransactions(refreshTotals: false),
    );
  }

  Category? _categoryFilter;
  Category? get categoryFilter => _categoryFilter;
  set categoryFilter(Category? value) {
    if (value == _categoryFilter) return;
    _categoryFilter = value;
    unawaited(loadTransactions(refreshTotals: false));
  }

  int? _walletFilter = Wallet.cashWalletId;
  int? get walletFilter => _walletFilter;
  set walletFilter(int? value) {
    if (value == _walletFilter) return;
    _walletFilter = value;
    unawaited(loadTransactions(refreshTotals: false));
  }

  Future<void> loadTransactions({bool refreshTotals = true}) async {
    refreshTotals = refreshTotals || !_totalsLoaded;
    final generation = ++_generation;
    loading = true;
    failed = false;
    notifyListeners();
    try {
      final db = await DatabaseHelper().database;
      final results = await Future.wait([
        TransactionQueries.page(
          db,
          walletId: _walletFilter,
          category: _categoryFilter,
          search: _searchQuery,
        ),
        refreshTotals
            ? TransactionQueries.totals(db, DateTime.now())
            : Future.value(_totals),
      ]);
      if (generation != _generation) return;
      _transactions = List.unmodifiable(results[0] as List<Transaction>);
      _totals = results[1] as List<Map<String, Object?>>;
      hasMore = _transactions.length == 50;
      if (refreshTotals) {
        _totalsLoaded = true;
        revision++;
      }
    } catch (_) {
      if (generation == _generation) failed = true;
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (loading || !hasMore || _transactions.isEmpty) return;
    final generation = _generation;
    loading = true;
    notifyListeners();
    try {
      final rows = await TransactionQueries.page(
        await DatabaseHelper().database,
        walletId: _walletFilter,
        category: _categoryFilter,
        search: _searchQuery,
        before: _transactions.last,
      );
      if (generation != _generation) return;
      _transactions = List.unmodifiable([..._transactions, ...rows]);
      hasMore = rows.length == 50;
    } catch (_) {
      if (generation == _generation) failed = true;
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> addTransaction(Transaction txn) async {
    if (txn.isDebtManaged) throw StateError('debt');
    await DatabaseHelper().insertTransaction(txn);
    await loadTransactions();
  }

  Future<void> updateTransaction(Transaction txn) async {
    if (txn.isDebtManaged) throw StateError('debt');
    await DatabaseHelper().updateTransaction(txn);
    await loadTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper().deleteTransaction(id);
    await loadTransactions();
  }

  void removeTransactionsForWallet(int walletId) {
    if (_walletFilter == walletId) _walletFilter = null;
    unawaited(loadTransactions());
  }

  Transaction? _lastDeleted;
  Transaction? get lastDeleted => _lastDeleted;
  Future<void> softDelete(int id) async {
    final txn = _transactions.firstWhere((t) => t.id == id);
    if (txn.isDebtManaged) return;
    _lastDeleted = txn;
    await deleteTransaction(id);
  }

  Future<void> undoDelete() async {
    final txn = _lastDeleted;
    if (txn == null) return;
    _lastDeleted = null;
    await DatabaseHelper().insertTransaction(txn);
    await loadTransactions();
  }

  double _sum(String column, {int? wallet, bool scoped = true}) => _totals
      .where(
        (r) =>
            (scoped ? _walletFilter : wallet) == null ||
            r['wallet_id'] == (scoped ? _walletFilter : wallet),
      )
      .fold(0.0, (sum, r) => sum + (r[column] as num).toDouble());
  double netBalanceForWallet(int id) =>
      _sum('balance', wallet: id, scoped: false);
  double get totalBalance => _sum('balance');
  double get totalIncome => _sum('income');
  double get totalExpense => _sum('expense');
  double get weeklyIncome => _sum('weekly_income');
  double get weeklyExpense => _sum('weekly_expense');

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }
}
