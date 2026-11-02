// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '钱包追踪器';

  @override
  String get dashboard => '仪表盘';

  @override
  String get analytics => '分析';

  @override
  String get settings => '设置';

  @override
  String get balance => '余额';

  @override
  String get balanceAllWallets => '余额（所有钱包）';

  @override
  String thisWeek(String currency, String income, String expense) {
    return '本周: +$currency$income / −$currency$expense';
  }

  @override
  String get searchByRemark => '按备注搜索...';

  @override
  String get noTransactionsYet => '📭 还没有交易 — 点击 + 或 − 添加';

  @override
  String get addIncome => '添加收入';

  @override
  String get editIncome => '编辑收入';

  @override
  String get addExpense => '添加支出';

  @override
  String get editExpense => '编辑支出';

  @override
  String get amount => '金额';

  @override
  String get wallet => '钱包';

  @override
  String get remarkOptional => '备注（可选）';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get direct => '直接输入';

  @override
  String get changeCalculator => '找零计算器';

  @override
  String get cashGiven => '支付现金';

  @override
  String get cashReceivedBack => '收到找零';

  @override
  String get computedAmount => '计算金额：';

  @override
  String get category => '分类';

  @override
  String get food => '餐饮';

  @override
  String get commute => '交通';

  @override
  String get bills => '账单';

  @override
  String get shopping => '购物';

  @override
  String get others => '其他';

  @override
  String get allWallets => '全部';

  @override
  String get addWallet => '添加钱包';

  @override
  String get editWallet => '编辑钱包';

  @override
  String get deleteWallet => '删除钱包';

  @override
  String deleteWalletConfirmTitle(String name) {
    return '删除「$name」？';
  }

  @override
  String get deleteWalletConfirmBody => '该钱包下的所有交易也会被删除。此操作无法撤销。';

  @override
  String get delete => '删除';

  @override
  String get largeExpenseTitle => '大额支出？';

  @override
  String largeExpenseBody(String currency, String amount, String category) {
    return '确定要在$category上花费 $currency$amount 吗？\n\n这比一般的$category支出要高。';
  }

  @override
  String get yesSpendIt => '是的，花费';

  @override
  String get deleteTransaction => '删除交易？';

  @override
  String get deleteTransactionBody => '此操作无法撤销。';

  @override
  String get transactionDeleted => '交易已删除';

  @override
  String get undo => '撤销';

  @override
  String get noExpensesYet => '还没有支出';

  @override
  String get addExpensesForAnalytics => '添加一些支出以查看分析';

  @override
  String get spendingByCategory => '按分类支出';

  @override
  String get clearAllData => '清除所有数据';

  @override
  String get clearAllDataConfirm =>
      '这将永久删除交易、债务、还款、联系人、预算和自定义钱包，并将现金余额归零。请先导出备份。';

  @override
  String get yesClear => '是的，清除';

  @override
  String get areYouAbsolutelySure => '您确定吗？';

  @override
  String get cannotBeUndone => '无法撤销。';

  @override
  String get allDataCleared => '所有数据已清除';

  @override
  String get exportFormat => '导出格式';

  @override
  String get csv => 'CSV';

  @override
  String get csvSubtitle => '适合 Google 表格 / Excel';

  @override
  String get excel => 'Excel (.xlsx)';

  @override
  String get excelSubtitle => '原生 Excel 格式';

  @override
  String get noTransactionsToExport => '没有可导出的交易';

  @override
  String get exportFailed => '导出失败';

  @override
  String get shareFile => '分享文件？';

  @override
  String get shareFileBody => '是否也要分享导出的文件？';

  @override
  String get language => '语言';

  @override
  String get currency => '货币';

  @override
  String get theme => '主题';

  @override
  String get darkMode => '深色模式';

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
  String get walletsAndSavings => '钱包';

  @override
  String get totalNetWorth => '总净资产';

  @override
  String get defaultWallet => '默认钱包';

  @override
  String get analyticsAndTrends => '分析与趋势';

  @override
  String get noExpensesPeriod => '该时间段内暂无支出';

  @override
  String get categoryBreakdown => '类别明细';

  @override
  String get spends => '笔支出';

  @override
  String get helpAndUserGuide => '帮助与用户指南';

  @override
  String get helpSubtitle => '划动手势、钱包指南与技巧';

  @override
  String get allTime => '所有时间';

  @override
  String get today => '今天';

  @override
  String get thisMonth => '本月';

  @override
  String get calendar => '日历';

  @override
  String get savings => '储蓄';

  @override
  String get digitalWallet => '电子钱包';

  @override
  String get bankAccount => '银行账户';

  @override
  String get card => '卡';

  @override
  String get cash => '现金';

  @override
  String get exportData => '导出数据';

  @override
  String get importData => '导入数据';

  @override
  String get exportImportSubtitle => 'CSV 或 Excel (.xlsx)';

  @override
  String get totalExpense => '总支出';

  @override
  String get pickSingleDay => '选择特定单日';

  @override
  String get pickCustomDateRange => '选择自定义日期范围';

  @override
  String get noWalletsFound => '未找到钱包';

  @override
  String get addYourFirstWallet => '添加你的第一个钱包';

  @override
  String get accounts => '账户';

  @override
  String get addCustomizableWallet => '添加自定义钱包';

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
  String get recordDetails => '记录详情';

  @override
  String get transactionType => '类型';

  @override
  String get recordedAt => '时间戳';

  @override
  String get transactionCategory => '类别';

  @override
  String get remarkLabel => '备注';

  @override
  String get incomeLabel => '收入';

  @override
  String get expenseLabel => '支出';

  @override
  String get openDebt => '查看债务';

  @override
  String get managedDebtRecord => '此笔交易属于债务。请打开债务以编辑，或一并删除关联记录。';

  @override
  String get thisWeekFilter => '本周';

  @override
  String get keepDataTitle => '保留数据';

  @override
  String get keepDataBody =>
      '更新会保留记录。换新手机时，请恢复Android备份，或在此导出文件后在新手机上导入。请将备份保存在应用之外。';
}
