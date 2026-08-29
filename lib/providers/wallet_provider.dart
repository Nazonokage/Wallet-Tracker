import 'package:flutter/foundation.dart';

import '../db/database_helper.dart';
import '../models/wallet.dart';

class WalletProvider extends ChangeNotifier {
  final DatabaseHelper _database = DatabaseHelper();

  List<Wallet> _wallets = [];

  int? _selectedWalletId;

  bool _isLoading = false;

  String? _error;

  // ------------------------------------------------------------
  // GETTERS
  // ------------------------------------------------------------

  List<Wallet> get wallets => List.unmodifiable(_wallets);

  int? get selectedWalletId => _selectedWalletId;

  bool get isLoading => _isLoading;

  String? get error => _error;

  /// Returns the currently selected wallet.
  ///
  /// null means "All wallets" is selected.
  Wallet? get selectedWallet {
    if (_selectedWalletId == null) {
      return null;
    }

    try {
      return _wallets.firstWhere(
        (wallet) => wallet.id == _selectedWalletId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Combined starting balance of all wallets.
  double get combinedInitialBalance {
    return _wallets.fold(
      0.0,
      (total, wallet) => total + wallet.initialBalance,
    );
  }

  // ------------------------------------------------------------
  // CONSTRUCTOR
  // ------------------------------------------------------------

  WalletProvider() {
    loadWallets();
  }

  // ------------------------------------------------------------
  // LOAD WALLETS
  // ------------------------------------------------------------

  Future<void> loadWallets() async {
    _setLoading(true);
    _clearError();

    try {
      final wallets = await _database.getAllWallets();

      _wallets = wallets;

      // If the previously selected wallet no longer exists,
      // automatically switch back to "All wallets".
      if (_selectedWalletId != null &&
          !_wallets.any((wallet) => wallet.id == _selectedWalletId)) {
        _selectedWalletId = null;
      }
    } catch (e) {
      _setError('Failed to load wallets: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ------------------------------------------------------------
  // SELECT WALLET
  // ------------------------------------------------------------

  void selectWallet(int? walletId) {
    // null means "All wallets".

    if (walletId != null && !_wallets.any((wallet) => wallet.id == walletId)) {
      return;
    }

    if (_selectedWalletId == walletId) {
      return;
    }

    _selectedWalletId = walletId;

    notifyListeners();
  }

  // ------------------------------------------------------------
  // ADD WALLET
  // ------------------------------------------------------------

  Future<bool> addWallet(Wallet wallet) async {
    _clearError();

    try {
      final id = await _database.insertWallet(wallet);

      wallet.id = id;

      _wallets = [..._wallets, wallet];

      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to add wallet: $e');
      return false;
    }
  }

  // ------------------------------------------------------------
  // UPDATE WALLET
  // ------------------------------------------------------------

  Future<bool> updateWallet(Wallet wallet) async {
    _clearError();

    try {
      await _database.updateWallet(wallet);

      final index = _wallets.indexWhere(
        (existingWallet) => existingWallet.id == wallet.id,
      );

      if (index == -1) {
        return false;
      }

      final updatedWallets = [..._wallets];
      updatedWallets[index] = wallet;

      _wallets = updatedWallets;

      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to update wallet: $e');
      return false;
    }
  }

  // ------------------------------------------------------------
  // DELETE WALLET
  // ------------------------------------------------------------

  Future<bool> deleteWallet(int id) async {
    _clearError();

    // Never allow the default Cash wallet to be deleted.
    if (id == Wallet.cashWalletId) {
      _setError('The default Cash wallet cannot be deleted.');
      return false;
    }

    try {
      await _database.deleteWallet(id);

      _wallets = _wallets.where((wallet) => wallet.id != id).toList();

      // If the deleted wallet was selected,
      // return to "All wallets".
      if (_selectedWalletId == id) {
        _selectedWalletId = null;
      }

      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to delete wallet: $e');
      return false;
    }
  }

  // ------------------------------------------------------------
  // ERROR HANDLING
  // ------------------------------------------------------------

  void clearError() {
    if (_error == null) {
      return;
    }

    _error = null;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  // ------------------------------------------------------------
  // LOADING STATE
  // ------------------------------------------------------------

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;
    notifyListeners();
  }
}
