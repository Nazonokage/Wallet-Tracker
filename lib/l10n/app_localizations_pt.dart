// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Rastreador de Carteira';

  @override
  String get dashboard => 'Painel';

  @override
  String get analytics => 'Análises';

  @override
  String get settings => 'Configurações';

  @override
  String get balance => 'Saldo';

  @override
  String get balanceAllWallets => 'Saldo (Todas as carteiras)';

  @override
  String thisWeek(String currency, String income, String expense) {
    return 'Esta semana: +$currency$income / −$currency$expense';
  }

  @override
  String get searchByRemark => 'Pesquisar por observação...';

  @override
  String get noTransactionsYet =>
      '📭 Ainda sem transações — toque + ou − para adicionar';

  @override
  String get addIncome => 'Adicionar receita';

  @override
  String get editIncome => 'Editar receita';

  @override
  String get addExpense => 'Adicionar despesa';

  @override
  String get editExpense => 'Editar despesa';

  @override
  String get amount => 'Valor';

  @override
  String get wallet => 'Carteira';

  @override
  String get remarkOptional => 'Observação (opcional)';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get direct => 'Direto';

  @override
  String get changeCalculator => 'Calculadora de troco';

  @override
  String get cashGiven => 'Dinheiro dado';

  @override
  String get cashReceivedBack => 'Troco recebido';

  @override
  String get computedAmount => 'Valor calculado:';

  @override
  String get category => 'Categoria';

  @override
  String get food => 'Comida';

  @override
  String get commute => 'Transporte';

  @override
  String get bills => 'Contas';

  @override
  String get shopping => 'Compras';

  @override
  String get others => 'Outros';

  @override
  String get allWallets => 'Todas';

  @override
  String get addWallet => 'Adicionar carteira';

  @override
  String get editWallet => 'Editar carteira';

  @override
  String get deleteWallet => 'Excluir carteira';

  @override
  String deleteWalletConfirmTitle(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get deleteWalletConfirmBody =>
      'Isso também exclui todas as transações desta carteira. Não pode ser desfeito.';

  @override
  String get delete => 'Excluir';

  @override
  String get largeExpenseTitle => 'Despesa grande?';

  @override
  String largeExpenseBody(String currency, String amount, String category) {
    return 'Tem certeza de que deseja gastar $currency$amount em $category?\n\nIsso é maior que uma despesa típica de $category.';
  }

  @override
  String get yesSpendIt => 'Sim, gastar';

  @override
  String get deleteTransaction => 'Excluir transação?';

  @override
  String get deleteTransactionBody => 'Esta ação não pode ser desfeita.';

  @override
  String get transactionDeleted => 'Transação excluída';

  @override
  String get undo => 'DESFAZER';

  @override
  String get noExpensesYet => 'Ainda sem despesas';

  @override
  String get addExpensesForAnalytics =>
      'Adicione despesas para ver as análises';

  @override
  String get spendingByCategory => 'Gastos por categoria';

  @override
  String get clearAllData => 'Limpar todos os dados';

  @override
  String get clearAllDataConfirm =>
      'Isso excluirá permanentemente todas as transações. Continuar?';

  @override
  String get yesClear => 'Sim, limpar';

  @override
  String get areYouAbsolutelySure => 'Tem certeza absoluta?';

  @override
  String get cannotBeUndone => 'Isso não pode ser desfeito.';

  @override
  String get allDataCleared => 'Todos os dados limpos';

  @override
  String get exportFormat => 'Formato de exportação';

  @override
  String get csv => 'CSV';

  @override
  String get csvSubtitle => 'Ideal para Google Sheets / Excel';

  @override
  String get excel => 'Excel (.xlsx)';

  @override
  String get excelSubtitle => 'Formato nativo do Excel';

  @override
  String get noTransactionsToExport => 'Nenhuma transação para exportar';

  @override
  String get exportFailed => 'Falha na exportação';

  @override
  String get shareFile => 'Compartilhar arquivo?';

  @override
  String get shareFileBody => 'Deseja também compartilhar o arquivo exportado?';

  @override
  String get language => 'Idioma';

  @override
  String get currency => 'Moeda';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Modo escuro';

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
