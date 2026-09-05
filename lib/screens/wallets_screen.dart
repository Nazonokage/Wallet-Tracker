import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import '../models/wallet.dart';
import '../providers/wallet_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/formatter.dart';
import '../widgets/wallet_modal.dart';
import '../widgets/wallet_logo.dart';
import '../widgets/particle_background.dart';
import '../widgets/animated_count_text.dart';
import '../widgets/fade_in_slide.dart';

class WalletsScreen extends StatefulWidget {
  final Function(int?)? onWalletSelected;

  const WalletsScreen({super.key, this.onWalletSelected});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  double _calculateWalletBalance(
      Wallet wallet, TransactionProvider txnProvider) {
    final netTxn = txnProvider.netBalanceForWallet(wallet.id!);
    return wallet.initialBalance + netTxn;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = Provider.of<SettingsProvider>(context).currencySymbol;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.walletsAndSavings,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card),
            tooltip: l10n.addWallet,
            onPressed: () => _openAddWallet(context),
          ),
        ],
      ),
      body: ParticleBackground(
        child: Consumer2<WalletProvider, TransactionProvider>(
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
                    Text(l10n.noWalletsFound,
                        style:
                            const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _openAddWallet(context),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addYourFirstWallet),
                    ),
                  ],
                ),
              );
            }

            double totalNetBalance = 0;
            for (final w in wallets) {
              totalNetBalance += _calculateWalletBalance(w, txnProvider);
            }

            final Map<String, List<Wallet>> grouped = {};
            for (final wallet in wallets) {
              final cat = wallet.category.isEmpty ? l10n.bankAccount : wallet.category;
              grouped.putIfAbsent(cat, () => []).add(wallet);
            }

            int itemCounter = 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Summary Card
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
                                l10n.totalNetWorth,
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
                                  '${wallets.length} ${l10n.accounts}',
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
                          AnimatedCountText(
                            value: totalNetBalance,
                            prefix: currency,
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

                    double categoryTotal = 0;
                    for (final w in categoryWallets) {
                      categoryTotal += _calculateWalletBalance(w, txnProvider);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Header
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
                          itemCounter++;
                          final delay = (itemCounter * 50).clamp(0, 400);
                          final walletBalance =
                              _calculateWalletBalance(wallet, txnProvider);
                          return FadeInSlide(
                            delayMilliseconds: delay,
                            child: _build1ColumnWalletCard(
                              context: context,
                              wallet: wallet,
                              balance: walletBalance,
                              currency: currency,
                            ),
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
                      label: Text(
                        l10n.addCustomizableWallet,
                        style: const TextStyle(
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
    final l10n = AppLocalizations.of(context);

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

                // Subtitle Row
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
                  l10n.balance.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedCountText(
                  value: balance,
                  prefix: currency,
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
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.editWallet),
              onTap: () {
                Navigator.pop(sheetCtx);
                _openEditWallet(context, wallet);
              },
            ),
            if (!wallet.isDefault)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  l10n.deleteWallet,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(l10n.deleteWalletConfirmTitle(wallet.name)),
                      content: Text(
                        l10n.deleteWalletConfirmBody,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.red),
                          child: Text(l10n.delete),
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
