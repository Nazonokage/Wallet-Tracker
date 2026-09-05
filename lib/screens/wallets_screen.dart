import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wallet.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/formatter.dart';
import '../widgets/wallet_modal.dart';
import '../widgets/wallet_logo.dart';

class WalletsScreen extends StatefulWidget {
  final Function(int?)? onWalletSelected;

  const WalletsScreen({super.key, this.onWalletSelected});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  // Calculates live balance for a specific wallet: initialBalance + net transactions
  double _calculateWalletBalance(
      Wallet wallet, TransactionProvider txnProvider) {
    final netTxn = txnProvider.netBalanceForWallet(wallet.id!);
    return wallet.initialBalance + netTxn;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = Provider.of<SettingsProvider>(context).currencySymbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Wallets & Savings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card),
            tooltip: 'Add Wallet',
            onPressed: () => _openAddWallet(context),
          ),
        ],
      ),
      body: Consumer2<WalletProvider, TransactionProvider>(
        builder: (context, walletProvider, txnProvider, _) {
          final wallets = walletProvider.wallets;

          if (wallets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No wallets found',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _openAddWallet(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add your first wallet'),
                  ),
                ],
              ),
            );
          }

          // Calculate grand total net balance
          double totalNetBalance = 0;
          for (final w in wallets) {
            totalNetBalance += _calculateWalletBalance(w, txnProvider);
          }

          // Group wallets by category
          final Map<String, List<Wallet>> grouped = {};
          for (final wallet in wallets) {
            final cat = wallet.category.isEmpty ? 'Bank Accounts' : wallet.category;
            grouped.putIfAbsent(cat, () => []).add(wallet);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Summary Card (Reusing Dashboard styling)
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Net Savings',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${wallets.length} Accounts',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$currency${formatAmount(totalNetBalance)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Render 1-Column Grouped Categories
                ...grouped.entries.map((entry) {
                  final categoryName = entry.key;
                  final categoryWallets = entry.value;

                  // Compute total balance for this category
                  double categoryTotal = 0;
                  for (final w in categoryWallets) {
                    categoryTotal += _calculateWalletBalance(w, txnProvider);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Header matching reference image (▼ Category Name ...... ₱Total)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.arrow_drop_down,
                                    size: 22, color: Colors.grey),
                                const SizedBox(width: 2),
                                Text(
                                  categoryName,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$currency${formatAmount(categoryTotal)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // 1-Column List of customizable cards
                      ...categoryWallets.map((wallet) {
                        final walletBalance =
                            _calculateWalletBalance(wallet, txnProvider);
                        return _build1ColumnWalletCard(
                          context: context,
                          wallet: wallet,
                          balance: walletBalance,
                          currency: currency,
                        );
                      }),

                      const SizedBox(height: 12),
                    ],
                  );
                }),

                const SizedBox(height: 8),

                // Add Wallet Button at bottom
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _openAddWallet(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text(
                      'Add Customizable Wallet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _build1ColumnWalletCard({
    required BuildContext context,
    required Wallet wallet,
    required double balance,
    required String currency,
  }) {
    final cardColor = Color(wallet.colorValue);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (widget.onWalletSelected != null) {
              widget.onWalletSelected!(wallet.id);
            }
          },
          onLongPress: wallet.isDefault
              ? null
              : () => _showWalletActions(context, wallet),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Icon + Name and Option dots
                Row(
                  children: [
                    WalletLogoWidget(
                      name: wallet.name,
                      fallbackIcon: wallet.icon,
                      size: 38,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        wallet.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      onPressed: () => _showWalletActions(context, wallet),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subtitle Row (e.g. Debit • PHP or 1.25% yearly)
                Text(
                  wallet.subtitle ?? 'Debit • PHP',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Bottom Row: Balance
                Text(
                  'BALANCE',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$currency${formatAmount(balance)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openAddWallet(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: WalletModal(
          onSave: (wallet) => context.read<WalletProvider>().addWallet(wallet),
        ),
      ),
    );
  }

  void _openEditWallet(BuildContext context, Wallet wallet) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: WalletModal(
          initialWallet: wallet,
          onSave: (updated) =>
              context.read<WalletProvider>().updateWallet(updated),
        ),
      ),
    );
  }

  void _showWalletActions(BuildContext context, Wallet wallet) {
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Wallet Details'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _openEditWallet(context, wallet);
              },
            ),
            if (!wallet.isDefault)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Wallet',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Delete "${wallet.name}"?'),
                      content: const Text(
                        'This also deletes every transaction recorded under this wallet. This cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.red),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await context.read<WalletProvider>().deleteWallet(wallet.id!);
                    if (!context.mounted) return;
                    context
                        .read<TransactionProvider>()
                        .removeTransactionsForWallet(wallet.id!);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
