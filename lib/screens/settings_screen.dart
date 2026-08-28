import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallettracker/models/transaction.dart' show TransactionType;
import '../providers/settings_provider.dart' show SettingsProvider, AppTheme;
import '../providers/transaction_provider.dart';
import '../db/database_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Currency picker
          ListTile(
            title: const Text('Currency'),
            subtitle: Text('Current: ${settings.currencySymbol}'),
            trailing: DropdownButton<String>(
              value: settings.currencySymbol,
              items: const [
                DropdownMenuItem(value: '₱', child: Text('₱ PHP')),
                DropdownMenuItem(value: '\$', child: Text('\$ USD')),
                DropdownMenuItem(value: '€', child: Text('€ EUR')),
                DropdownMenuItem(value: '₹', child: Text('₹ INR')),
              ],
              onChanged: (newSymbol) {
                if (newSymbol != null) settings.setCurrency(newSymbol);
              },
            ),
          ),

          // Theme picker
          ListTile(
            title: const Text('Theme'),
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
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: settings.isDarkMode,
              onChanged: (value) => settings.toggleDarkMode(value),
            ),
          ),

          const Divider(),

          // Clear all data
          ListTile(
            title: const Text('Clear All Data'),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () => _confirmClearData(context),
          ),

          // ✅ Export CSV – now fully functional
          ListTile(
            title: const Text('Export CSV'),
            trailing: const Icon(Icons.upload_file),
            onTap: () => _exportCSV(context),
          ),
        ],
      ),
    );
  }

  // --------------------- Clear Data (unchanged) ---------------------
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

  // --------------------- CSV Export ---------------------
  Future<void> _exportCSV(BuildContext context) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final transactions = provider.transactions;

    if (transactions.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions to export')),
      );
      return;
    }

    try {
      // 1. Build CSV content
      final List<List<dynamic>> rows = [
        ['Date', 'Type', 'Category', 'Amount', 'Remark']
      ];
      for (var txn in transactions) {
        rows.add([
          txn.date.toIso8601String(),
          txn.type == TransactionType.income ? 'Income' : 'Expense',
          txn.category?.toString().split('.').last ?? '',
          txn.amount,
          txn.remark ?? '',
        ]);
      }
      final csvString = const ListToCsvConverter().convert(rows);

      // 2. Ask user where to save
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choose folder to save CSV',
      );

      if (selectedDirectory == null) {
        // User canceled – do nothing
        return;
      }

      // 3. Write the file to the chosen folder
      final fileName =
          'transactions_${DateTime.now().millisecondsSinceEpoch}.csv';
      final filePath = '$selectedDirectory/$fileName';
      final file = File(filePath);
      await file.writeAsString(csvString);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV saved to: $filePath'),
          duration: const Duration(seconds: 4),
        ),
      );

      // 4. Optionally, offer to share the file via share_plus
      final shouldShare = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Share file?'),
          content: const Text('Do you want to share the CSV file as well?'),
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
          text: 'My transaction data from Wallet Tracker',
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }
}
