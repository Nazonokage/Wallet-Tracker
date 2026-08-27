import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

          // ✅ Theme picker – add this block
// inside ListView children:
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
          // Clear data (unchanged)
          ListTile(
            title: const Text('Clear All Data'),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () => _confirmClearData(context),
          ),
          // Export (placeholder)
          ListTile(
            title: const Text('Export CSV'),
            trailing: const Icon(Icons.upload_file),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

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
}
