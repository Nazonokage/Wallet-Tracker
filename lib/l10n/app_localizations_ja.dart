// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ウォレットトラッカー';

  @override
  String get dashboard => 'ダッシュボード';

  @override
  String get analytics => '分析';

  @override
  String get settings => '設定';

  @override
  String get balance => '残高';

  @override
  String get balanceAllWallets => '残高（全ウォレット）';

  @override
  String thisWeek(String currency, String income, String expense) {
    return '今週: +$currency$income / −$currency$expense';
  }

  @override
  String get searchByRemark => '備考で検索...';

  @override
  String get noTransactionsYet => '📭 まだ取引がありません — + または − をタップして追加';

  @override
  String get addIncome => '収入を追加';

  @override
  String get editIncome => '収入を編集';

  @override
  String get addExpense => '支出を追加';

  @override
  String get editExpense => '支出を編集';

  @override
  String get amount => '金額';

  @override
  String get wallet => 'ウォレット';

  @override
  String get remarkOptional => '備考（任意）';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get direct => '直接入力';

  @override
  String get changeCalculator => 'おつり計算機';

  @override
  String get cashGiven => '渡した現金';

  @override
  String get cashReceivedBack => '受け取ったおつり';

  @override
  String get computedAmount => '計算された金額:';

  @override
  String get category => 'カテゴリ';

  @override
  String get food => '食費';

  @override
  String get commute => '交通費';

  @override
  String get bills => '請求書';

  @override
  String get shopping => '買い物';

  @override
  String get others => 'その他';

  @override
  String get allWallets => 'すべて';

  @override
  String get addWallet => 'ウォレットを追加';

  @override
  String get editWallet => 'ウォレットを編集';

  @override
  String get deleteWallet => 'ウォレットを削除';

  @override
  String deleteWalletConfirmTitle(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get deleteWalletConfirmBody => 'このウォレットのすべての取引も削除されます。元に戻せません。';

  @override
  String get delete => '削除';

  @override
  String get largeExpenseTitle => '大きな支出ですか？';

  @override
  String largeExpenseBody(String currency, String amount, String category) {
    return '$currency$amount を $category に使いますか？\n\nこれは通常の $category 支出より多いです。';
  }

  @override
  String get yesSpendIt => 'はい、使います';

  @override
  String get deleteTransaction => '取引を削除しますか？';

  @override
  String get deleteTransactionBody => 'この操作は元に戻せません。';

  @override
  String get transactionDeleted => '取引を削除しました';

  @override
  String get undo => '元に戻す';

  @override
  String get noExpensesYet => 'まだ支出がありません';

  @override
  String get addExpensesForAnalytics => '分析を見るには支出を追加してください';

  @override
  String get spendingByCategory => 'カテゴリ別支出';

  @override
  String get clearAllData => 'すべてのデータを削除';

  @override
  String get clearAllDataConfirm => 'すべての取引が完全に削除されます。続けますか？';

  @override
  String get yesClear => 'はい、削除';

  @override
  String get areYouAbsolutelySure => '本当によろしいですか？';

  @override
  String get cannotBeUndone => '元に戻せません。';

  @override
  String get allDataCleared => 'すべてのデータを削除しました';

  @override
  String get exportFormat => 'エクスポート形式';

  @override
  String get csv => 'CSV';

  @override
  String get csvSubtitle => 'Googleスプレッドシート / Excel向け';

  @override
  String get excel => 'Excel (.xlsx)';

  @override
  String get excelSubtitle => 'ネイティブExcel形式';

  @override
  String get noTransactionsToExport => 'エクスポートする取引がありません';

  @override
  String get exportFailed => 'エクスポートに失敗しました';

  @override
  String get shareFile => 'ファイルを共有しますか？';

  @override
  String get shareFileBody => 'エクスポートしたファイルも共有しますか？';

  @override
  String get language => '言語';

  @override
  String get currency => '通貨';

  @override
  String get theme => 'テーマ';

  @override
  String get darkMode => 'ダークモード';

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
  String get walletsAndSavings => 'ウォレットと貯金';

  @override
  String get totalNetWorth => '総資産額';

  @override
  String get defaultWallet => 'デフォルトウォレット';

  @override
  String get analyticsAndTrends => '分析とトレンド';

  @override
  String get noExpensesPeriod => 'この期間の支出はありません';

  @override
  String get categoryBreakdown => 'カテゴリ別内訳';

  @override
  String get spends => '件の支出';

  @override
  String get helpAndUserGuide => 'ヘルプとユーザーガイド';

  @override
  String get helpSubtitle => 'スワイプ操作、ガイド、ヒント';

  @override
  String get allTime => '全期間';

  @override
  String get today => '今日';

  @override
  String get thisMonth => '今月';

  @override
  String get calendar => 'カレンダー';

  @override
  String get savings => '貯蓄';

  @override
  String get digitalWallet => 'デジタルウォレット';

  @override
  String get bankAccount => '銀行口座';

  @override
  String get card => 'カード';

  @override
  String get cash => '現金';

  @override
  String get exportData => 'データをエクスポート';

  @override
  String get importData => 'データをインポート';

  @override
  String get exportImportSubtitle => 'CSV または Excel (.xlsx)';

  @override
  String get totalExpense => '総支出';

  @override
  String get pickSingleDay => '特定の日を選択';

  @override
  String get pickCustomDateRange => 'カスタム日付範囲を選択';

  @override
  String get noWalletsFound => 'ウォレットが見つかりません';

  @override
  String get addYourFirstWallet => '最初のウォレットを追加';

  @override
  String get accounts => '口座';

  @override
  String get addCustomizableWallet => 'カスタムウォレットを追加';
}
