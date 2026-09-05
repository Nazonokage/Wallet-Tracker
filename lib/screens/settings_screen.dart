import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/settings_provider.dart'
    show SettingsProvider, AppTheme, RegionPreset;
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../db/database_helper.dart';
import '../utils/import_export_helper.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';

import '../widgets/help_guide_modal.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: l10n.helpAndUserGuide,
            onPressed: () => HelpGuideModal.show(context),
          ),
        ],
      ),
      body: ListView(
        children: [
          // Help & User Guide Tile
          ListTile(
            leading: const Icon(Icons.menu_book_rounded, color: Colors.amber),
            title: Text(l10n.helpAndUserGuide, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(l10n.helpSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => HelpGuideModal.show(context),
          ),
          const Divider(),

          // Region = language + currency (with flags)
          ListTile(
            title: Text(AppLocalizations.of(context).language),
            subtitle: Text(settings.currentRegion.label),
            trailing: DropdownButton<String>(
              value: settings.regionId,
              items: SettingsProvider.regionPresets.map((RegionPreset r) {
                return DropdownMenuItem<String>(
                  value: r.id,
                  child: Text(r.label),
                );
              }).toList(),
              onChanged: (id) {
                if (id == null) return;
                final region = SettingsProvider.regionPresets
                    .firstWhere((r) => r.id == id);
                settings.setRegion(region);
              },
            ),
          ),

          // Theme picker
          ListTile(
            title: Text(AppLocalizations.of(context).theme),
            subtitle:
                Text('Current: ${settings.currentTheme.name.toUpperCase()}'),
            trailing: DropdownButton<AppTheme>(
              value: settings.currentTheme,
              items: AppTheme.values.map((theme) {
                return DropdownMenuItem<AppTheme>(
                  value: theme,
                  child: Text(theme.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (newTheme) {
                if (newTheme != null) settings.setTheme(newTheme);
              },
            ),
          ),

          // Dark Mode toggle
          ListTile(
            title: Text(AppLocalizations.of(context).darkMode),
            trailing: Switch(
              value: settings.isDarkMode,
              onChanged: (value) => settings.toggleDarkMode(value),
            ),
          ),

          const Divider(),

          // Clear all data
          ListTile(
            title: Text(l10n.clearAllData),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () => _confirmClearData(context),
          ),

          // Export
          ListTile(
            title: Text(l10n.exportData),
            subtitle: Text(l10n.exportImportSubtitle),
            trailing: const Icon(Icons.upload_file),
            onTap: () => _showExportOptions(context),
          ),

          // Import
          ListTile(
            title: Text(l10n.importData),
            subtitle: Text(l10n.exportImportSubtitle),
            trailing: const Icon(Icons.download),
            onTap: () => _importData(context),
          ),
        ],
      ),
    );
  }

  // --------------------- Clear Data ---------------------
  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
            'This will permanently delete all transactions. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmAgain(context);
            },
            child: const Text('Yes, clear'),
          ),
        ],
      ),
    );
  }

  void _confirmAgain(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Are you absolutely sure?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await DatabaseHelper().clearAll();
              if (!context.mounted) return;
              Provider.of<TransactionProvider>(context, listen: false)
                  .loadTransactions();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --------------------- Export Options ---------------------
  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Export format',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.table_chart),
                title: const Text('CSV'),
                subtitle: const Text('Best for Google Sheets / Excel'),
                onTap: () {
                  Navigator.pop(ctx);
                  _export(context, 'csv');
                },
              ),
              ListTile(
                leading: const Icon(Icons.grid_on),
                title: const Text('Excel (.xlsx)'),
                subtitle: const Text('Native Excel format'),
                onTap: () {
                  Navigator.pop(ctx);
                  _export(context, 'xlsx');
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _export(BuildContext context, String format) async {
    final txnProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    final walletProvider = Provider.of<WalletProvider>(context, listen: false);

    final transactions = txnProvider.transactions;
    if (transactions.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
      return;
    }

    try {
      // Ask user where to save
      final selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choose folder to save export',
      );

      if (selectedDirectory == null) return; // cancelled

      final filePath = await ImportExportHelper.export(
        transactions: transactions,
        wallets: walletProvider.wallets,
        format: format,
        directoryPath: selectedDirectory,
      );

      if (filePath == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export failed')),
        );
        return;
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to: $filePath'),
          duration: const Duration(seconds: 4),
        ),
      );

      // Optional share
      final shouldShare = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Share file?'),
          content: const Text('Do you also want to share the exported file?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes'),
            ),
          ],
        ),
      );

      if (shouldShare == true) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'My transaction data from Expense Tracker',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  // --------------------- Import ---------------------
  Future<void> _importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'xlsx', 'xls'],
        dialogTitle: 'Select CSV or Excel file to import',
      );

      if (result == null || result.files.isEmpty) return;

      final platformFile = result.files.single;
      String? path = platformFile.path;

      // On some platforms we only get bytes
      if (path == null && platformFile.bytes != null) {
        final ext = platformFile.extension ?? 'csv';
        path = await ImportExportHelper.writeTempFile(
          platformFile.bytes!,
          ext,
        );
      }

      if (path == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not read the selected file')),
        );
        return;
      }

      // Confirm before importing
      if (!context.mounted) return;
      final shouldImport = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Import data?'),
          content: const Text(
            'This will ADD the transactions from the file to your existing data.\n\n'
            'Existing transactions will NOT be deleted.\n'
            'Duplicate rows may appear if you import the same file twice.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (shouldImport != true) return;
      if (!context.mounted) return;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      try {
        final parsed = await ImportExportHelper.parseImportFile(path);

        if (!context.mounted) return;
        final txnProvider =
            Provider.of<TransactionProvider>(context, listen: false);

        int imported = 0;
        for (final txn in parsed) {
          await txnProvider.addTransaction(txn);
          imported++;
        }

        if (!context.mounted) return;
        Navigator.pop(context); // close loading dialog

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully imported $imported transactions'),
            duration: const Duration(seconds: 4),
          ),
        );
      } catch (e) {
        if (context.mounted) {
          Navigator.pop(context); // close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Import failed: $e')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }
}
