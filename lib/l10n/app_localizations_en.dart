// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wallet Tracker';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get analytics => 'Analytics';

  @override
  String get settings => 'Settings';

  @override
  String get balance => 'Balance';

  @override
  String get balanceAllWallets => 'Balance (All wallets)';

  @override
  String thisWeek(String currency, String income, String expense) {
    return 'This week: +$currency$income / −$currency$expense';
  }

  @override
  String get searchByRemark => 'Search by remark...';

  @override
  String get noTransactionsYet =>
      '📭 No transactions yet — tap + or − to add one';

  @override
  String get addIncome => 'Add Income';

  @override
  String get editIncome => 'Edit Income';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get amount => 'Amount';

  @override
  String get wallet => 'Wallet';

  @override
  String get remarkOptional => 'Remark (optional)';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get direct => 'Direct';

  @override
  String get changeCalculator => 'Change Calculator';

  @override
  String get cashGiven => 'Cash given';

  @override
  String get cashReceivedBack => 'Cash received back';

  @override
  String get computedAmount => 'Computed amount:';

  @override
  String get category => 'Category';

  @override
  String get food => 'Food';

  @override
  String get commute => 'Commute';

  @override
  String get bills => 'Bills';

  @override
  String get shopping => 'Shopping';

  @override
  String get others => 'Others';

  @override
  String get allWallets => 'All';

  @override
  String get addWallet => 'Add wallet';

  @override
  String get editWallet => 'Edit wallet';

  @override
  String get deleteWallet => 'Delete wallet';

  @override
  String deleteWalletConfirmTitle(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteWalletConfirmBody =>
      'This also deletes every transaction recorded under this wallet. This cannot be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get largeExpenseTitle => 'Large expense?';

  @override
  String largeExpenseBody(String currency, String amount, String category) {
    return 'Are you sure you want to spend $currency$amount on $category?\n\nThis is higher than a typical $category expense.';
  }

  @override
  String get yesSpendIt => 'Yes, spend it';

  @override
  String get deleteTransaction => 'Delete Transaction?';

  @override
  String get deleteTransactionBody => 'This action cannot be undone.';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get undo => 'UNDO';

  @override
  String get noExpensesYet => 'No expenses yet';

  @override
  String get addExpensesForAnalytics => 'Add some expenses to see analytics';

  @override
  String get spendingByCategory => 'Spending by category';

  @override
  String get clearAllData => 'Clear all data';

  @override
  String get clearAllDataConfirm =>
      'This will permanently delete all transactions. Continue?';

  @override
  String get yesClear => 'Yes, clear';

  @override
  String get areYouAbsolutelySure => 'Are you absolutely sure?';

  @override
  String get cannotBeUndone => 'This cannot be undone.';

  @override
  String get allDataCleared => 'All data cleared';

  @override
  String get exportFormat => 'Export format';

  @override
  String get csv => 'CSV';

  @override
  String get csvSubtitle => 'Best for Google Sheets / Excel';

  @override
  String get excel => 'Excel (.xlsx)';

  @override
  String get excelSubtitle => 'Native Excel format';

  @override
  String get noTransactionsToExport => 'No transactions to export';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get shareFile => 'Share file?';

  @override
  String get shareFileBody => 'Do you also want to share the exported file?';

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark mode';

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
