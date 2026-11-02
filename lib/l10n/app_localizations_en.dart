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
      'This permanently removes transactions, debts, repayments, contacts and budgets, removes custom wallets, and resets Cash to zero. Export a backup first.';

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

  @override
  String get walletsAndSavings => 'Wallets';

  @override
  String get totalNetWorth => 'Total Net Worth';

  @override
  String get defaultWallet => 'Default Wallet';

  @override
  String get analyticsAndTrends => 'Analytics & Trends';

  @override
  String get noExpensesPeriod => 'No expenses found for this period';

  @override
  String get categoryBreakdown => 'Category Breakdown';

  @override
  String get spends => 'Spends';

  @override
  String get helpAndUserGuide => 'Help & User Guide';

  @override
  String get helpSubtitle => 'Swipe gestures, wallet guides & tips';

  @override
  String get allTime => 'All Time';

  @override
  String get today => 'Today';

  @override
  String get thisMonth => 'This Month';

  @override
  String get calendar => 'Calendar';

  @override
  String get savings => 'Savings';

  @override
  String get digitalWallet => 'Digital Wallet';

  @override
  String get bankAccount => 'Bank Account';

  @override
  String get card => 'Card';

  @override
  String get cash => 'Cash';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get exportImportSubtitle => 'CSV or Excel (.xlsx)';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get pickSingleDay => 'Pick Specific Single Day';

  @override
  String get pickCustomDateRange => 'Pick Custom Date Range';

  @override
  String get noWalletsFound => 'No wallets found';

  @override
  String get addYourFirstWallet => 'Add your first wallet';

  @override
  String get accounts => 'Accounts';

  @override
  String get addCustomizableWallet => 'Add Customizable Wallet';

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
  String get recordDetails => 'Record details';

  @override
  String get transactionType => 'Type';

  @override
  String get recordedAt => 'Timestamp';

  @override
  String get transactionCategory => 'Category';

  @override
  String get remarkLabel => 'Remark';

  @override
  String get incomeLabel => 'Income';

  @override
  String get expenseLabel => 'Expense';

  @override
  String get openDebt => 'Open debt';

  @override
  String get managedDebtRecord =>
      'This movement belongs to a debt. Open the debt to edit it or delete its linked records together.';

  @override
  String get thisWeekFilter => 'This week';

  @override
  String get keepDataTitle => 'Keep your data';

  @override
  String get keepDataBody =>
      'Updates retain your records. For a new phone, restore an Android backup or export here and import that file on the new phone. Keep the backup outside the app.';
}
