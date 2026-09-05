import 'package:expense_tracker/widgets/wallet_modal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wallet.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import 'wallet_logo.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';

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
                avatar: const Icon(Icons.wallet, size: 18),
                label: Text(AppLocalizations.of(context).allWallets),
                selected: walletProvider.selectedWalletId == null,
                onSelected: (_) => _selectWallet(context, null),
              ),
              const SizedBox(width: 8),
              for (final w in wallets) ...[
                GestureDetector(
                  onLongPress:
                      w.isDefault ? null : () => _showWalletActions(context, w),
                  child: ChoiceChip(
                    avatar: WalletLogoWidget(
                      name: w.name,
                      fallbackIcon: w.icon,
                      size: 20,
                    ),
                    label: Text(w.name),
                    selected: walletProvider.selectedWalletId == w.id,
                    onSelected: (_) => _selectWallet(context, w.id),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: Text(AppLocalizations.of(context).addWallet),
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
              title: Text(AppLocalizations.of(context).editWallet),
              onTap: () {
                Navigator.pop(sheetCtx);
                _openEditWallet(context, wallet);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(AppLocalizations.of(context).deleteWallet,
                  style: const TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(sheetCtx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(AppLocalizations.of(context)
                        .deleteWalletConfirmTitle(wallet.name)),
                    content: Text(
                      AppLocalizations.of(context).deleteWalletConfirmBody,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(AppLocalizations.of(context).cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                        child: Text(AppLocalizations.of(context).delete),
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
