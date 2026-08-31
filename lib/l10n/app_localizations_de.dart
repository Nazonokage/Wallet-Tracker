// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Wallet-Tracker';

  @override
  String get dashboard => 'Übersicht';

  @override
  String get analytics => 'Analysen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get balance => 'Saldo';

  @override
  String get balanceAllWallets => 'Saldo (Alle Wallets)';

  @override
  String thisWeek(String currency, String income, String expense) {
    return 'Diese Woche: +$currency$income / −$currency$expense';
  }

  @override
  String get searchByRemark => 'Nach Bemerkung suchen...';

  @override
  String get noTransactionsYet =>
      '📭 Noch keine Transaktionen — tippe + oder − zum Hinzufügen';

  @override
  String get addIncome => 'Einnahme hinzufügen';

  @override
  String get editIncome => 'Einnahme bearbeiten';

  @override
  String get addExpense => 'Ausgabe hinzufügen';

  @override
  String get editExpense => 'Ausgabe bearbeiten';

  @override
  String get amount => 'Betrag';

  @override
  String get wallet => 'Wallet';

  @override
  String get remarkOptional => 'Bemerkung (optional)';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get direct => 'Direkt';

  @override
  String get changeCalculator => 'Wechselgeld-Rechner';

  @override
  String get cashGiven => 'Gegebenes Bargeld';

  @override
  String get cashReceivedBack => 'Erhaltenes Wechselgeld';

  @override
  String get computedAmount => 'Berechneter Betrag:';

  @override
  String get category => 'Kategorie';

  @override
  String get food => 'Essen';

  @override
  String get commute => 'Pendeln';

  @override
  String get bills => 'Rechnungen';

  @override
  String get shopping => 'Einkaufen';

  @override
  String get others => 'Sonstiges';

  @override
  String get allWallets => 'Alle';

  @override
  String get addWallet => 'Wallet hinzufügen';

  @override
  String get editWallet => 'Wallet bearbeiten';

  @override
  String get deleteWallet => 'Wallet löschen';

  @override
  String deleteWalletConfirmTitle(String name) {
    return '„$name“ löschen?';
  }

  @override
  String get deleteWalletConfirmBody =>
      'Dadurch werden auch alle Transaktionen dieses Wallets gelöscht. Nicht rückgängig machbar.';

  @override
  String get delete => 'Löschen';

  @override
  String get largeExpenseTitle => 'Große Ausgabe?';

  @override
  String largeExpenseBody(String currency, String amount, String category) {
    return 'Möchtest du wirklich $currency$amount für $category ausgeben?\n\nDas ist höher als eine typische $category-Ausgabe.';
  }

  @override
  String get yesSpendIt => 'Ja, ausgeben';

  @override
  String get deleteTransaction => 'Transaktion löschen?';

  @override
  String get deleteTransactionBody =>
      'Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get transactionDeleted => 'Transaktion gelöscht';

  @override
  String get undo => 'RÜCKGÄNGIG';

  @override
  String get noExpensesYet => 'Noch keine Ausgaben';

  @override
  String get addExpensesForAnalytics =>
      'Füge Ausgaben hinzu, um Analysen zu sehen';

  @override
  String get spendingByCategory => 'Ausgaben nach Kategorie';

  @override
  String get clearAllData => 'Alle Daten löschen';

  @override
  String get clearAllDataConfirm =>
      'Dadurch werden alle Transaktionen dauerhaft gelöscht. Fortfahren?';

  @override
  String get yesClear => 'Ja, löschen';

  @override
  String get areYouAbsolutelySure => 'Bist du dir absolut sicher?';

  @override
  String get cannotBeUndone => 'Das kann nicht rückgängig gemacht werden.';

  @override
  String get allDataCleared => 'Alle Daten gelöscht';

  @override
  String get exportFormat => 'Exportformat';

  @override
  String get csv => 'CSV';

  @override
  String get csvSubtitle => 'Ideal für Google Sheets / Excel';

  @override
  String get excel => 'Excel (.xlsx)';

  @override
  String get excelSubtitle => 'Natives Excel-Format';

  @override
  String get noTransactionsToExport => 'Keine Transaktionen zum Exportieren';

  @override
  String get exportFailed => 'Export fehlgeschlagen';

  @override
  String get shareFile => 'Datei teilen?';

  @override
  String get shareFileBody => 'Möchtest du die exportierte Datei auch teilen?';

  @override
  String get language => 'Sprache';

  @override
  String get currency => 'Währung';

  @override
  String get theme => 'Design';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get chinese => '中文';

  @override
  String get french => 'Français';

  @override
  String get spanish => 'Español';

  @override
  String get german => 'Deutsch';

  @override
  String get portuguese => 'Português';
}
