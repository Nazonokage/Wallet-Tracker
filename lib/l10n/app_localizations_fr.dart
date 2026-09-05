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
      'Cela supprimera définitivement toutes les transactions. Continuer ?';

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
}
