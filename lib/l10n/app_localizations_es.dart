// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Rastreador de Cartera';

  @override
  String get dashboard => 'Panel';

  @override
  String get analytics => 'Analíticas';

  @override
  String get settings => 'Ajustes';

  @override
  String get balance => 'Saldo';

  @override
  String get balanceAllWallets => 'Saldo (Todas las carteras)';

  @override
  String thisWeek(String currency, String income, String expense) {
    return 'Esta semana: +$currency$income / −$currency$expense';
  }

  @override
  String get searchByRemark => 'Buscar por nota...';

  @override
  String get noTransactionsYet =>
      '📭 Aún no hay transacciones — toca + o − para añadir';

  @override
  String get addIncome => 'Añadir ingreso';

  @override
  String get editIncome => 'Editar ingreso';

  @override
  String get addExpense => 'Añadir gasto';

  @override
  String get editExpense => 'Editar gasto';

  @override
  String get amount => 'Cantidad';

  @override
  String get wallet => 'Cartera';

  @override
  String get remarkOptional => 'Nota (opcional)';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get direct => 'Directo';

  @override
  String get changeCalculator => 'Calculadora de cambio';

  @override
  String get cashGiven => 'Efectivo entregado';

  @override
  String get cashReceivedBack => 'Cambio recibido';

  @override
  String get computedAmount => 'Cantidad calculada:';

  @override
  String get category => 'Categoría';

  @override
  String get food => 'Comida';

  @override
  String get commute => 'Transporte';

  @override
  String get bills => 'Facturas';

  @override
  String get shopping => 'Compras';

  @override
  String get others => 'Otros';

  @override
  String get allWallets => 'Todas';

  @override
  String get addWallet => 'Añadir cartera';

  @override
  String get editWallet => 'Editar cartera';

  @override
  String get deleteWallet => 'Eliminar cartera';

  @override
  String deleteWalletConfirmTitle(String name) {
    return '¿Eliminar «$name»?';
  }

  @override
  String get deleteWalletConfirmBody =>
      'También se eliminan todas las transacciones de esta cartera. No se puede deshacer.';

  @override
  String get delete => 'Eliminar';

  @override
  String get largeExpenseTitle => '¿Gasto grande?';

  @override
  String largeExpenseBody(String currency, String amount, String category) {
    return '¿Seguro que quieres gastar $currency$amount en $category?\n\nEs más alto que un gasto típico de $category.';
  }

  @override
  String get yesSpendIt => 'Sí, gastar';

  @override
  String get deleteTransaction => '¿Eliminar transacción?';

  @override
  String get deleteTransactionBody => 'Esta acción no se puede deshacer.';

  @override
  String get transactionDeleted => 'Transacción eliminada';

  @override
  String get undo => 'DESHACER';

  @override
  String get noExpensesYet => 'Aún no hay gastos';

  @override
  String get addExpensesForAnalytics =>
      'Añade algunos gastos para ver analíticas';

  @override
  String get spendingByCategory => 'Gastos por categoría';

  @override
  String get clearAllData => 'Borrar todos los datos';

  @override
  String get clearAllDataConfirm =>
      'Esto elimina permanentemente las transacciones, deudas, pagos, contactos, presupuestos y carteras personalizadas, y restablece el efectivo a cero. Exporta una copia primero.';

  @override
  String get yesClear => 'Sí, borrar';

  @override
  String get areYouAbsolutelySure => '¿Estás absolutamente seguro?';

  @override
  String get cannotBeUndone => 'No se puede deshacer.';

  @override
  String get allDataCleared => 'Todos los datos borrados';

  @override
  String get exportFormat => 'Formato de exportación';

  @override
  String get csv => 'CSV';

  @override
  String get csvSubtitle => 'Ideal para Google Sheets / Excel';

  @override
  String get excel => 'Excel (.xlsx)';

  @override
  String get excelSubtitle => 'Formato nativo de Excel';

  @override
  String get noTransactionsToExport => 'No hay transacciones para exportar';

  @override
  String get exportFailed => 'Error al exportar';

  @override
  String get shareFile => '¿Compartir archivo?';

  @override
  String get shareFileBody =>
      '¿También quieres compartir el archivo exportado?';

  @override
  String get language => 'Idioma';

  @override
  String get currency => 'Moneda';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Modo oscuro';

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
  String get walletsAndSavings => 'Billeteras';

  @override
  String get totalNetWorth => 'Patrimonio Total';

  @override
  String get defaultWallet => 'Billetera Principal';

  @override
  String get analyticsAndTrends => 'Análisis y Tendencias';

  @override
  String get noExpensesPeriod => 'Sin gastos en este período';

  @override
  String get categoryBreakdown => 'Desglose por Categoría';

  @override
  String get spends => 'Gastos';

  @override
  String get helpAndUserGuide => 'Ayuda y Guía de Usuario';

  @override
  String get helpSubtitle => 'Gestos para deslizar, guías y consejos';

  @override
  String get allTime => 'Todo el tiempo';

  @override
  String get today => 'Hoy';

  @override
  String get thisMonth => 'Este Mes';

  @override
  String get calendar => 'Calendario';

  @override
  String get savings => 'Ahorros';

  @override
  String get digitalWallet => 'Billetera Digital';

  @override
  String get bankAccount => 'Cuenta Bancaria';

  @override
  String get card => 'Tarjeta';

  @override
  String get cash => 'Efectivo';

  @override
  String get exportData => 'Exportar Datos';

  @override
  String get importData => 'Importar Datos';

  @override
  String get exportImportSubtitle => 'CSV o Excel (.xlsx)';

  @override
  String get totalExpense => 'Gasto Total';

  @override
  String get pickSingleDay => 'Seleccionar Día Específico';

  @override
  String get pickCustomDateRange => 'Rango de Fechas Personalizado';

  @override
  String get noWalletsFound => 'No se encontraron billeteras';

  @override
  String get addYourFirstWallet => 'Agrega tu primera billetera';

  @override
  String get accounts => 'Cuentas';

  @override
  String get addCustomizableWallet => 'Agregar Billetera Personalizada';

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
  String get recordDetails => 'Detalles del registro';

  @override
  String get transactionType => 'Tipo';

  @override
  String get recordedAt => 'Fecha y hora';

  @override
  String get transactionCategory => 'Categoría';

  @override
  String get remarkLabel => 'Nota';

  @override
  String get incomeLabel => 'Ingreso';

  @override
  String get expenseLabel => 'Gasto';

  @override
  String get openDebt => 'Abrir deuda';

  @override
  String get managedDebtRecord =>
      'Este movimiento pertenece a una deuda. Abre la deuda para editarla o eliminar sus registros vinculados juntos.';

  @override
  String get thisWeekFilter => 'Esta semana';

  @override
  String get keepDataTitle => 'Conservar tus datos';

  @override
  String get keepDataBody =>
      'Las actualizaciones conservan tus registros. En un teléfono nuevo, restaura una copia de Android o exporta aquí e importa el archivo en el nuevo teléfono. Guarda la copia fuera de la aplicación.';
}
