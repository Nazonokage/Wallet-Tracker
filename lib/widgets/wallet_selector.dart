import 'package:expense_tracker/widgets/wallet_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wallet.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';

class WalletSelector extends StatelessWidget {
  const WalletSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletProvider>(
      builder: (ctx, walletProvider, _) {
        final wallets = walletProvider.wallets;
        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ChoiceChip(
                label: const Text('💰 All'),
                selected: walletProvider.selectedWalletId == null,
                onSelected: (_) => _selectWallet(context, null),
              ),
              const SizedBox(width: 8),
              for (final w in wallets) ...[
                GestureDetector(
                  onLongPress:
                      w.isDefault ? null : () => _showWalletActions(context, w),
                  child: ChoiceChip(
                    label: Text('${w.icon} ${w.name}'),
                    selected: walletProvider.selectedWalletId == w.id,
                    onSelected: (_) => _selectWallet(context, w.id),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Add wallet'),
                onPressed: () => _openAddWallet(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectWallet(BuildContext context, int? walletId) {
    context.read<WalletProvider>().selectWallet(walletId);
    context.read<TransactionProvider>().walletFilter = walletId;
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
              title: const Text('Edit wallet'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _openEditWallet(context, wallet);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete wallet',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Delete "${wallet.name}"?'),
                    content: const Text(
                      'This also deletes every transaction recorded under '
                      'this wallet. This cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
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
