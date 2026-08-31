import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme {
  mint,
  sunset,
  ocean,
  lavender,
  rose,
}

/// Combined language + currency preset with a flag emoji.
class RegionPreset {
  final String id;
  final Locale locale;
  final String currencySymbol;
  final String currencyCode;
  final String flag;

  /// Short display name in its own language / English fallback.
  final String name;

  const RegionPreset({
    required this.id,
    required this.locale,
    required this.currencySymbol,
    required this.currencyCode,
    required this.flag,
    required this.name,
  });

  String get label => '$flag  $currencySymbol $currencyCode · $name';
}

class SettingsProvider extends ChangeNotifier {
  static const String _currencyKey = 'currencySymbol';
  static const String _themeKey = 'themeIndex';
  static const String _darkModeKey = 'darkMode';
  static const String _localeKey = 'localeCode';
  static const String _regionKey = 'regionId';

  /// Presets: language + default currency + flag.
  static const List<RegionPreset> regionPresets = [
    RegionPreset(
      id: 'ph_en',
      locale: Locale('en'),
      currencySymbol: '₱',
      currencyCode: 'PHP',
      flag: '🇵🇭',
      name: 'English (PH)',
    ),
    RegionPreset(
      id: 'us_en',
      locale: Locale('en'),
      currencySymbol: '\$',
      currencyCode: 'USD',
      flag: '🇺🇸',
      name: 'English (US)',
    ),
    RegionPreset(
      id: 'in_en',
      locale: Locale('en'),
      currencySymbol: '₹',
      currencyCode: 'INR',
      flag: '🇮🇳',
      name: 'English (IN)',
    ),
    RegionPreset(
      id: 'jp_ja',
      locale: Locale('ja'),
      currencySymbol: '¥',
      currencyCode: 'JPY',
      flag: '🇯🇵',
      name: '日本語',
    ),
    RegionPreset(
      id: 'cn_zh',
      locale: Locale('zh'),
      currencySymbol: '¥',
      currencyCode: 'CNY',
      flag: '🇨🇳',
      name: '中文',
    ),
    RegionPreset(
      id: 'fr_fr',
      locale: Locale('fr'),
      currencySymbol: '€',
      currencyCode: 'EUR',
      flag: '🇫🇷',
      name: 'Français',
    ),
    RegionPreset(
      id: 'es_es',
      locale: Locale('es'),
      currencySymbol: '€',
      currencyCode: 'EUR',
      flag: '🇪🇸',
      name: 'Español',
    ),
    RegionPreset(
      id: 'de_de',
      locale: Locale('de'),
      currencySymbol: '€',
      currencyCode: 'EUR',
      flag: '🇩🇪',
      name: 'Deutsch',
    ),
    RegionPreset(
      id: 'pt_pt',
      locale: Locale('pt'),
      currencySymbol: '€',
      currencyCode: 'EUR',
      flag: '🇵🇹',
      name: 'Português',
    ),
    RegionPreset(
      id: 'br_pt',
      locale: Locale('pt'),
      currencySymbol: 'R\$',
      currencyCode: 'BRL',
      flag: '🇧🇷',
      name: 'Português (BR)',
    ),
  ];

  String _currencySymbol = '₱';
  AppTheme _currentTheme = AppTheme.mint;
  bool _isDarkMode = false;
  Locale _locale = const Locale('en');
  String _regionId = 'ph_en';

  String get currencySymbol => _currencySymbol;
  AppTheme get currentTheme => _currentTheme;
  bool get isDarkMode => _isDarkMode;
  Locale get locale => _locale;
  String get regionId => _regionId;

  RegionPreset get currentRegion {
    return regionPresets.firstWhere(
      (r) => r.id == _regionId,
      orElse: () => regionPresets.first,
    );
  }

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
    Locale('fr'),
    Locale('es'),
    Locale('de'),
    Locale('pt'),
  ];

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currencySymbol = prefs.getString(_currencyKey) ?? '₱';
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _currentTheme =
        AppTheme.values[themeIndex.clamp(0, AppTheme.values.length - 1)];
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    final code = prefs.getString(_localeKey) ?? 'en';
    _locale = Locale(code);
    _regionId =
        prefs.getString(_regionKey) ?? _matchRegionId(code, _currencySymbol);
    notifyListeners();
  }

  /// Best-effort match when only locale/currency were stored before regions.
  String _matchRegionId(String lang, String symbol) {
    for (final r in regionPresets) {
      if (r.locale.languageCode == lang && r.currencySymbol == symbol) {
        return r.id;
      }
    }
    for (final r in regionPresets) {
      if (r.locale.languageCode == lang) return r.id;
    }
    return 'ph_en';
  }

  /// Sets language + currency together from a region preset.
  Future<void> setRegion(RegionPreset region) async {
    _regionId = region.id;
    _locale = region.locale;
    _currencySymbol = region.currencySymbol;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_regionKey, region.id);
    await prefs.setString(_localeKey, region.locale.languageCode);
    await prefs.setString(_currencyKey, region.currencySymbol);
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

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }
}
