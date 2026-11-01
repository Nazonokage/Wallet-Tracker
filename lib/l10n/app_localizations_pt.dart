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
      'Isto elimina permanentemente transações, dívidas, pagamentos, contactos, orçamentos e carteiras personalizadas, e repõe o dinheiro a zero. Exporte primeiro uma cópia.';

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

  @override
  String get walletsAndSavings => 'Carteiras e Poupanças';

  @override
  String get totalNetWorth => 'Patrimônio Total';

  @override
  String get defaultWallet => 'Carteira Padrão';

  @override
  String get analyticsAndTrends => 'Análises e Tendências';

  @override
  String get noExpensesPeriod => 'Nenhuma despesa neste período';

  @override
  String get categoryBreakdown => 'Detalhamento por Categoria';

  @override
  String get spends => 'Despesas';

  @override
  String get helpAndUserGuide => 'Ajuda e Guia do Usuário';

  @override
  String get helpSubtitle => 'Gestos de deslizar, guias e dicas';

  @override
  String get allTime => 'Todo o período';

  @override
  String get today => 'Hoje';

  @override
  String get thisMonth => 'Este Mês';

  @override
  String get calendar => 'Calendário';

  @override
  String get savings => 'Poupança';

  @override
  String get digitalWallet => 'Carteira Digital';

  @override
  String get bankAccount => 'Conta Bancária';

  @override
  String get card => 'Cartão';

  @override
  String get cash => 'Dinheiro';

  @override
  String get exportData => 'Exportar Dados';

  @override
  String get importData => 'Importar Dados';

  @override
  String get exportImportSubtitle => 'CSV ou Excel (.xlsx)';

  @override
  String get totalExpense => 'Despesa Total';

  @override
  String get pickSingleDay => 'Escolher Dia Específico';

  @override
  String get pickCustomDateRange => 'Intervalo de Datas Personalizado';

  @override
  String get noWalletsFound => 'Nenhuma carteira encontrada';

  @override
  String get addYourFirstWallet => 'Adicione sua primeira carteira';

  @override
  String get accounts => 'Contas';

  @override
  String get addCustomizableWallet => 'Adicionar Carteira Personalizável';

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
  String get recordDetails => 'Detalhes do registo';

  @override
  String get transactionType => 'Tipo';

  @override
  String get recordedAt => 'Data e hora';

  @override
  String get transactionCategory => 'Categoria';

  @override
  String get remarkLabel => 'Observação';

  @override
  String get incomeLabel => 'Receita';

  @override
  String get expenseLabel => 'Despesa';

  @override
  String get openDebt => 'Abrir dívida';

  @override
  String get managedDebtRecord =>
      'Este movimento pertence a uma dívida. Abra a dívida para editar ou eliminar os registos associados em conjunto.';

  @override
  String get thisWeekFilter => 'Esta semana';

  @override
  String get keepDataTitle => 'Manter os dados';

  @override
  String get keepDataBody =>
      'As atualizações mantêm os registos. Num novo telemóvel, restaure uma cópia Android ou exporte aqui e importe o ficheiro no novo telemóvel. Guarde a cópia fora da aplicação.';
}
