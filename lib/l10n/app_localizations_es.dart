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
      'Esto eliminará permanentemente todas las transacciones. ¿Continuar?';

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
  String get walletsAndSavings => 'Billeteras y Ahorros';

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
}
