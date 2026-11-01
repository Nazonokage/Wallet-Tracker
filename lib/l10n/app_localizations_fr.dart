// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Suivi de Portefeuille';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get analytics => 'Analyses';

  @override
  String get settings => 'Paramètres';

  @override
  String get balance => 'Solde';

  @override
  String get balanceAllWallets => 'Solde (Tous les portefeuilles)';

  @override
  String thisWeek(String currency, String income, String expense) {
    return 'Cette semaine : +$currency$income / −$currency$expense';
  }

  @override
  String get searchByRemark => 'Rechercher par remarque...';

  @override
  String get noTransactionsYet =>
      '📭 Aucune transaction — appuyez sur + ou − pour en ajouter';

  @override
  String get addIncome => 'Ajouter un revenu';

  @override
  String get editIncome => 'Modifier le revenu';

  @override
  String get addExpense => 'Ajouter une dépense';

  @override
  String get editExpense => 'Modifier la dépense';

  @override
  String get amount => 'Montant';

  @override
  String get wallet => 'Portefeuille';

  @override
  String get remarkOptional => 'Remarque (optionnel)';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get direct => 'Direct';

  @override
  String get changeCalculator => 'Calculateur de monnaie';

  @override
  String get cashGiven => 'Espèces données';

  @override
  String get cashReceivedBack => 'Monnaie reçue';

  @override
  String get computedAmount => 'Montant calculé :';

  @override
  String get category => 'Catégorie';

  @override
  String get food => 'Nourriture';

  @override
  String get commute => 'Transport';

  @override
  String get bills => 'Factures';

  @override
  String get shopping => 'Shopping';

  @override
  String get others => 'Autres';

  @override
  String get allWallets => 'Tous';

  @override
  String get addWallet => 'Ajouter un portefeuille';

  @override
  String get editWallet => 'Modifier le portefeuille';

  @override
  String get deleteWallet => 'Supprimer le portefeuille';

  @override
  String deleteWalletConfirmTitle(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get deleteWalletConfirmBody =>
      'Cela supprime aussi toutes les transactions de ce portefeuille. Irréversible.';

  @override
  String get delete => 'Supprimer';

  @override
  String get largeExpenseTitle => 'Grosse dépense ?';

  @override
  String largeExpenseBody(String currency, String amount, String category) {
    return 'Êtes-vous sûr de vouloir dépenser $currency$amount pour $category ?\n\nC\'est plus élevé qu\'une dépense typique de $category.';
  }

  @override
  String get yesSpendIt => 'Oui, dépenser';

  @override
  String get deleteTransaction => 'Supprimer la transaction ?';

  @override
  String get deleteTransactionBody => 'Cette action est irréversible.';

  @override
  String get transactionDeleted => 'Transaction supprimée';

  @override
  String get undo => 'ANNULER';

  @override
  String get noExpensesYet => 'Aucune dépense pour l\'instant';

  @override
  String get addExpensesForAnalytics =>
      'Ajoutez des dépenses pour voir les analyses';

  @override
  String get spendingByCategory => 'Dépenses par catégorie';

  @override
  String get clearAllData => 'Effacer toutes les données';

  @override
  String get clearAllDataConfirm =>
      'Ceci supprime définitivement les opérations, dettes, remboursements, contacts, budgets et portefeuilles personnalisés, et remet les espèces à zéro. Exportez d’abord une sauvegarde.';

  @override
  String get yesClear => 'Oui, effacer';

  @override
  String get areYouAbsolutelySure => 'Êtes-vous vraiment sûr ?';

  @override
  String get cannotBeUndone => 'Cela ne peut pas être annulé.';

  @override
  String get allDataCleared => 'Toutes les données ont été effacées';

  @override
  String get exportFormat => 'Format d\'export';

  @override
  String get csv => 'CSV';

  @override
  String get csvSubtitle => 'Idéal pour Google Sheets / Excel';

  @override
  String get excel => 'Excel (.xlsx)';

  @override
  String get excelSubtitle => 'Format Excel natif';

  @override
  String get noTransactionsToExport => 'Aucune transaction à exporter';

  @override
  String get exportFailed => 'Échec de l\'export';

  @override
  String get shareFile => 'Partager le fichier ?';

  @override
  String get shareFileBody => 'Voulez-vous aussi partager le fichier exporté ?';

  @override
  String get language => 'Langue';

  @override
  String get currency => 'Devise';

  @override
  String get theme => 'Thème';

  @override
  String get darkMode => 'Mode sombre';

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
  String get walletsAndSavings => 'Portefeuilles et Épargne';

  @override
  String get totalNetWorth => 'Valeur Nette Totale';

  @override
  String get defaultWallet => 'Portefeuille par Défaut';

  @override
  String get analyticsAndTrends => 'Analyses et Tendances';

  @override
  String get noExpensesPeriod => 'Aucune dépense pour cette période';

  @override
  String get categoryBreakdown => 'Répartition par Catégorie';

  @override
  String get spends => 'Dépenses';

  @override
  String get helpAndUserGuide => 'Aide et Guide Utilisateur';

  @override
  String get helpSubtitle => 'Gestes de balayage, guides et astuces';

  @override
  String get allTime => 'Tout';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get thisMonth => 'Ce Mois';

  @override
  String get calendar => 'Calendrier';

  @override
  String get savings => 'Épargne';

  @override
  String get digitalWallet => 'Portefeuille Numérique';

  @override
  String get bankAccount => 'Compte Bancaire';

  @override
  String get card => 'Carte';

  @override
  String get cash => 'Espèces';

  @override
  String get exportData => 'Exporter les Données';

  @override
  String get importData => 'Importer les Données';

  @override
  String get exportImportSubtitle => 'CSV ou Excel (.xlsx)';

  @override
  String get totalExpense => 'Dépenses Totales';

  @override
  String get pickSingleDay => 'Choisir un Jour Spécifique';

  @override
  String get pickCustomDateRange => 'Plage de Dates Personnalisée';

  @override
  String get noWalletsFound => 'Aucun portefeuille trouvé';

  @override
  String get addYourFirstWallet => 'Ajouter votre premier portefeuille';

  @override
  String get accounts => 'Comptes';

  @override
  String get addCustomizableWallet => 'Ajouter un Portefeuille Personnalisable';

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
  String get recordDetails => 'Détails de l’opération';

  @override
  String get transactionType => 'Type';

  @override
  String get recordedAt => 'Date et heure';

  @override
  String get transactionCategory => 'Catégorie';

  @override
  String get remarkLabel => 'Remarque';

  @override
  String get incomeLabel => 'Revenu';

  @override
  String get expenseLabel => 'Dépense';

  @override
  String get openDebt => 'Ouvrir la dette';

  @override
  String get managedDebtRecord =>
      'Ce mouvement est lié à une dette. Ouvrez la dette pour la modifier ou supprimer ensemble les opérations liées.';

  @override
  String get thisWeekFilter => 'Cette semaine';

  @override
  String get keepDataTitle => 'Conserver vos données';

  @override
  String get keepDataBody =>
      'Les mises à jour conservent vos données. Sur un nouveau téléphone, restaurez une sauvegarde Android ou exportez ici puis importez le fichier sur le nouveau téléphone. Gardez la sauvegarde hors de l’application.';
}
