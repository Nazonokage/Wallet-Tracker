import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../db/database_helper.dart';

class TransactionProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  // For filtering
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  set searchQuery(String val) {
    _searchQuery = val;
    notifyListeners();
  }

  // Optional category filter
  Category? _categoryFilter;
  Category? get categoryFilter => _categoryFilter;
  set categoryFilter(Category? val) {
    _categoryFilter = val;
    notifyListeners();
  }

  // ✅ Optional wallet filter — defaults to Cash (id 1).
  int? _walletFilter = Wallet.cashWalletId;
  int? get walletFilter => _walletFilter;
  set walletFilter(int? val) {
    _walletFilter = val;
    notifyListeners();
  }

  TransactionProvider() {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    final list = await DatabaseHelper().getAllTransactions();
    _transactions = list;
    notifyListeners();
  }

  // ✅ All the computed getters below operate on this wallet-scoped list,
  // so switching the wallet selector updates balance/income/expense too.
  List<Transaction> get _walletScoped {
    if (_walletFilter == null) return _transactions;
    return _transactions.where((t) => t.walletId == _walletFilter).toList();
  }

  List<Transaction> get filteredTransactions {
    return _walletScoped.where((txn) {
      // category filter
      if (_categoryFilter != null && txn.category != _categoryFilter) {
        return false;
      }
      // search (remark contains query)
      if (_searchQuery.isNotEmpty) {
        final remark = txn.remark?.toLowerCase() ?? '';
        return remark.contains(_searchQuery.toLowerCase());
      }
      return true;
    }).toList();
  }

  Future<void> addTransaction(Transaction txn) async {
    final id = await DatabaseHelper().insertTransaction(txn);
    txn.id = id;
    _transactions.insert(0, txn);
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction txn) async {
    await DatabaseHelper().updateTransaction(txn);
    final index = _transactions.indexWhere((t) => t.id == txn.id);
    if (index != -1) {
      _transactions[index] = txn;
      notifyListeners();
    }
  }

  Future<void> deleteTransaction(int id) async {
    await DatabaseHelper().deleteTransaction(id);
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  // ✅ Called after a wallet gets deleted (its transactions are already
  // gone from the DB via DatabaseHelper.deleteWallet) so the in-memory
  // list matches — otherwise deleted-wallet transactions would linger
  // until the next app restart.
  void removeTransactionsForWallet(int walletId) {
    _transactions.removeWhere((t) => t.walletId == walletId);
    notifyListeners();
  }

  // For undo: we can keep a soft-deleted transaction in memory
  Transaction? _lastDeleted;
  Transaction? get lastDeleted => _lastDeleted;

  void softDelete(int id) {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      _lastDeleted = _transactions[index];
      _transactions.removeAt(index);
      notifyListeners();
    }
  }

  void undoDelete() {
    if (_lastDeleted != null) {
      _transactions.insert(0, _lastDeleted!);
      _lastDeleted = null;
      notifyListeners();
      // also re-insert into DB?
      // We'll handle in UI: after undo, we call addTransaction again.
    }
  }

  double netBalanceForWallet(int walletId) {
    double income = 0, expense = 0;
    for (var txn in _transactions) {
      if (txn.walletId == walletId) {
        if (txn.type == TransactionType.income) {
          income += txn.amount;
        } else {
          expense += txn.amount;
        }
      }
    }
    return income - expense;
  }

  // Computed values (wallet-scoped)
  double get totalBalance {
    double income = 0, expense = 0;
    for (var txn in _walletScoped) {
      if (txn.type == TransactionType.income) {
        income += txn.amount;
      } else {
        expense += txn.amount;
      }
    }
    return income - expense;
  }

  double get totalIncome => _walletScoped
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _walletScoped
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  // Weekly summary (current calendar week), wallet-scoped
  double get weeklyIncome {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return _walletScoped
        .where(
          (t) =>
              t.type == TransactionType.income &&
              t.date.isAfter(startOfWeek) &&
              t.date.isBefore(now.add(const Duration(days: 1))),
        )
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get weeklyExpense {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return _walletScoped
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.isAfter(startOfWeek) &&
              t.date.isBefore(now.add(const Duration(days: 1))),
        )
        .fold(0, (sum, t) => sum + t.amount);
  }
}
