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
      'Dies löscht dauerhaft Buchungen, Schulden, Rückzahlungen, Kontakte, Budgets und eigene Geldbörsen und setzt Bargeld auf null. Exportiere zuerst ein Backup.';

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

  @override
  String get walletsAndSavings => 'Geldbörsen';

  @override
  String get totalNetWorth => 'Gesamtvermögen';

  @override
  String get defaultWallet => 'Standard-Geldbörse';

  @override
  String get analyticsAndTrends => 'Analysen & Trends';

  @override
  String get noExpensesPeriod => 'Keine Ausgaben in diesem Zeitraum';

  @override
  String get categoryBreakdown => 'Kategorie-Aufschlüsselung';

  @override
  String get spends => 'Ausgaben';

  @override
  String get helpAndUserGuide => 'Hilfe & Benutzerhandbuch';

  @override
  String get helpSubtitle => 'Wischgesten, Anleitungen & Tipps';

  @override
  String get allTime => 'Gesamter Zeitraum';

  @override
  String get today => 'Heute';

  @override
  String get thisMonth => 'Diesen Monat';

  @override
  String get calendar => 'Kalender';

  @override
  String get savings => 'Ersparnisse';

  @override
  String get digitalWallet => 'Digitale Geldbörse';

  @override
  String get bankAccount => 'Bankkonto';

  @override
  String get card => 'Karte';

  @override
  String get cash => 'Bargeld';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get importData => 'Daten importieren';

  @override
  String get exportImportSubtitle => 'CSV oder Excel (.xlsx)';

  @override
  String get totalExpense => 'Gesamtausgaben';

  @override
  String get pickSingleDay => 'Bestimmten Tag auswählen';

  @override
  String get pickCustomDateRange => 'Benutzerdefinierten Datumsbereich wählen';

  @override
  String get noWalletsFound => 'Keine Geldbörsen gefunden';

  @override
  String get addYourFirstWallet => 'Fügen Sie Ihre erste Geldbörse hinzu';

  @override
  String get accounts => 'Konten';

  @override
  String get addCustomizableWallet => 'Anpassbare Geldbörse hinzufügen';

  @override
  String get debts => 'Debts';

  @override
  String get iou => 'IOU';

  @override
  String get lent => 'Lent';

  @override
  String get borrowed => 'Borrowed';

  @override
  String get outstanding => 'Outstanding';

  @override
  String get partial => 'Partial';

  @override
  String get archived => 'Archived';

  @override
  String get owedToYou => 'Owed to you';

  @override
  String get youOwe => 'You owe';

  @override
  String get receivables => 'Receivables';

  @override
  String get payables => 'Payables';

  @override
  String get noDebts => 'No debts yet. Tap + IOU to record one.';

  @override
  String get person => 'Person';

  @override
  String get interest => 'Flat interest';

  @override
  String get interestRate => 'Interest (%)';

  @override
  String get totalDue => 'Total due';

  @override
  String get dueDate => 'Due date (optional)';

  @override
  String get note => 'Note (optional)';

  @override
  String get recordRepayment => 'Record repayment';

  @override
  String get repaymentRecorded => 'Repayment recorded';

  @override
  String get markAsPaid => 'Mark as paid';

  @override
  String get markedAsPaid => 'Marked as paid';

  @override
  String get archive => 'Archive';

  @override
  String get archiveConfirmation =>
      'Archive this debt? It will leave active totals. Wallet movements stay unchanged.';

  @override
  String get paidConfirmation =>
      'Record the full remaining amount as a repayment?';

  @override
  String get debtSaved => 'Debt saved';

  @override
  String get debtError =>
      'Could not save the change. Check the amount and wallet, then retry.';

  @override
  String get loadError => 'Could not load data. Tap retry.';

  @override
  String get retry => 'Retry';

  @override
  String get loadMore => 'Load more';

  @override
  String get debtLocked =>
      'Amount, interest, direction and wallet cannot change after a repayment.';

  @override
  String get repaymentAmount => 'Repayment amount';

  @override
  String get debtAmountInvalid =>
      'Enter an amount greater than zero, up to the remaining balance.';

  @override
  String get debtGuide =>
      'Record money lent or borrowed using a real wallet. Optional interest is a flat percentage, off by default. Repayments pay principal first. Principal movements change your wallet balance but stay out of spending analytics; interest counts as income or expense. Fully repaid debts are archived automatically. Use CSV or Excel export to back up debts and repayments.';

  @override
  String debtOverdue(int days) {
    return 'Overdue $days days';
  }

  @override
  String debtDue(String date) {
    return 'Due $date';
  }

  @override
  String debtPaid(String amount) {
    return 'Paid $amount';
  }

  @override
  String get debtDelete => 'Delete debt';

  @override
  String get debtDeleteConfirmation =>
      'Delete this debt and reverse all its recorded wallet movements?';

  @override
  String get debtDeleted => 'Debt deleted';

  @override
  String get debtWalletInUse =>
      'This wallet has debt records. Keep it to preserve their payment history.';

  @override
  String get backupImported => 'Backup imported';

  @override
  String get backupGuide => 'Data and backup';

  @override
  String get edit => 'Edit';

  @override
  String get backupImportConfirmation =>
      'This adds the backup to your existing data, including wallet starting balances, transactions, debts and repayments. Existing records stay. Importing the same backup twice creates duplicates.';

  @override
  String get recordDetails => 'Buchungsdetails';

  @override
  String get transactionType => 'Typ';

  @override
  String get recordedAt => 'Zeitstempel';

  @override
  String get transactionCategory => 'Kategorie';

  @override
  String get remarkLabel => 'Notiz';

  @override
  String get incomeLabel => 'Einnahme';

  @override
  String get expenseLabel => 'Ausgabe';

  @override
  String get openDebt => 'Schuld öffnen';

  @override
  String get managedDebtRecord =>
      'Diese Buchung gehört zu einer Schuld. Öffne die Schuld, um sie zu bearbeiten oder ihre verknüpften Buchungen gemeinsam zu löschen.';

  @override
  String get thisWeekFilter => 'Diese Woche';

  @override
  String get keepDataTitle => 'Daten behalten';

  @override
  String get keepDataBody =>
      'Updates behalten deine Daten. Stelle auf einem neuen Handy ein Android-Backup wieder her oder exportiere hier eine Datei und importiere sie auf dem neuen Handy. Bewahre das Backup außerhalb der App auf.';
}
