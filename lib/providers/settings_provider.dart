import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { mint, sunset, ocean }

class SettingsProvider extends ChangeNotifier {
  static const String _currencyKey = 'currencySymbol';
  static const String _themeKey = 'themeIndex';

  String _currencySymbol = '₱'; // PHP default
  AppTheme _currentTheme = AppTheme.mint;

  String get currencySymbol => _currencySymbol;
  AppTheme get currentTheme => _currentTheme;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currencySymbol = prefs.getString(_currencyKey) ?? '₱';
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _currentTheme =
        AppTheme.values[themeIndex.clamp(0, AppTheme.values.length - 1)];
    notifyListeners();
  }

  Future<void> setCurrency(String symbol) async {
    _currencySymbol = symbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, symbol);
    notifyListeners();
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, theme.index);
    notifyListeners();
  }
}
