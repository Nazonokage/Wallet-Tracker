import 'package:expense_tracker/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/settings_provider.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../widgets/transaction_list_item.dart';
import '../widgets/transaction_details.dart';
import '../db/debt_store.dart';
import '../widgets/income_modal.dart';
import '../widgets/expense_modal.dart';
import '../widgets/wallet_selector.dart';
import '../widgets/particle_background.dart';
import '../widgets/animated_count_text.dart';
import '../widgets/fade_in_slide.dart';
import 'debts_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final walletProvider = context.read<WalletProvider>();
      final txnProvider = context.read<TransactionProvider>();
      txnProvider.walletFilter = walletProvider.selectedWalletId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: ParticleBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              const WalletSelector(),
              const SizedBox(height: 8),
              _buildBalanceCard(context),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => showDebtForm(context),
                  icon: const Icon(Icons.handshake_outlined),
                  label: Text(l10n.iou),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.searchByRemark,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                  onChanged: (val) {
                    Provider.of<TransactionProvider>(
                      context,
                      listen: false,
                    ).searchQuery = val;
                  },
                ),
              ),
              Expanded(
                child: Consumer<TransactionProvider>(
                  builder: (ctx, provider, _) {
                    final list = provider.filteredTransactions;
                    if (provider.failed) {
                      return Center(
                        child: TextButton(
                          onPressed: provider.loadTransactions,
                          child: Text(l10n.loadError),
                        ),
                      );
                    }
                    if (provider.loading && list.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (list.isEmpty) {
                      return Center(child: Text(l10n.noTransactionsYet));
                    }
                    return NotificationListener<ScrollNotification>(
                      onNotification: (n) {
                        if (n.metrics.extentAfter < 250) provider.loadMore();
                        return false;
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 160),
                        itemCount: list.length + (provider.hasMore ? 1 : 0),
                        itemBuilder: (ctx, index) {
                          if (index == list.length) {
                            return TextButton(
                              onPressed: provider.loadMore,
                              child: Text(l10n.loadMore),
                            );
                          }
                          final txn = list[index];
                          return FadeInSlide(
                            delayMilliseconds: (index * 40).clamp(0, 300),
                            child: Dismissible(
                              key: Key(txn.id.toString()),
                              direction: txn.isDebtManaged
                                  ? DismissDirection.none
                                  : DismissDirection.horizontal,
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.endToStart) {
                                  return _deleteTransaction(txn);
                                } else {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted) _openEditModal(context, txn);
                                  });
                                  return false;
                                }
                              },
                              background: Container(
                                color: Colors.green,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 24),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(Icons.edit, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              secondaryBackground: Container(
                                color: Colors.orange,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 24),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      l10n.delete,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              child: TransactionListItem(
                                txn: txn,
                                alternate: index.isEven,
                                onTap: () => _showRecordDetails(txn),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'income',
            onPressed: () => _openIncomeModal(context),
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'expense',
            onPressed: () => _openExpenseModal(context),
            backgroundColor: const Color(0xFFD32F2F),
            child: const Icon(Icons.remove),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currency = context.select<SettingsProvider, String>(
      (s) => s.currencySymbol,
    );
    return Selector2<
      TransactionProvider,
      WalletProvider,
      (double, double, double, String)
    >(
      selector: (ctx, txnProvider, walletProvider) {
        final selectedWallet = walletProvider.selectedWallet;
        final startingBalance = selectedWallet != null
            ? selectedWallet.initialBalance
            : walletProvider.combinedInitialBalance;
        final balance = startingBalance + txnProvider.totalBalance;
        final weekIncome = txnProvider.weeklyIncome;
        final weekExpense = txnProvider.weeklyExpense;
        final label = selectedWallet != null
            ? '${selectedWallet.icon} ${selectedWallet.name} ${l10n.balance}'
            : l10n.balanceAllWallets;
        return (balance, weekIncome, weekExpense, label);
      },
      builder: (ctx, values, _) {
        final (balance, weekIncome, weekExpense, label) = values;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(label, style: const TextStyle(fontSize: 18)),
                AnimatedCountText(
                  value: balance,
                  prefix: currency,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.thisWeek(
                    currency,
                    formatAmount(weekIncome),
                    formatAmount(weekExpense),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _currentDefaultWalletId(BuildContext context) {
    return Provider.of<WalletProvider>(
          context,
          listen: false,
        ).selectedWalletId ??
        Wallet.cashWalletId;
  }

  void _openIncomeModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: IncomeModal(
          defaultWalletId: _currentDefaultWalletId(context),
          onSave: (txn) {
            Provider.of<TransactionProvider>(
              context,
              listen: false,
            ).addTransaction(txn);
          },
        ),
      ),
    );
  }

  void _openExpenseModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ExpenseModal(
          defaultWalletId: _currentDefaultWalletId(context),
          onSave: (txn) {
            Provider.of<TransactionProvider>(
              context,
              listen: false,
            ).addTransaction(txn);
          },
        ),
      ),
    );
  }

  void _openEditModal(BuildContext context, Transaction txn) {
    if (txn.type == TransactionType.income) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: IncomeModal(
            initialTransaction: txn,
            defaultWalletId: txn.walletId,
            onSave: (updated) {
              Provider.of<TransactionProvider>(
                context,
                listen: false,
              ).updateTransaction(updated);
            },
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ExpenseModal(
            initialTransaction: txn,
            defaultWalletId: txn.walletId,
            onSave: (updated) {
              Provider.of<TransactionProvider>(
                context,
                listen: false,
              ).updateTransaction(updated);
            },
          ),
        ),
      );
    }
  }

  Future<bool> _deleteTransaction(Transaction transaction) async {
    if (transaction.isDebtManaged) return false;
    final l = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteTransaction),
        content: Text(l.deleteTransactionBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.delete),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return false;
    try {
      await context.read<TransactionProvider>().softDelete(transaction.id!);
      if (mounted) _showUndoSnackBar(context);
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.debtError)));
      }
      return false;
    }
  }

  Future<void> _showRecordDetails(Transaction transaction) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final action = await showModalBottomSheet<TransactionRecordAction>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      sheetAnimationStyle: AnimationStyle.noAnimation,
      builder: (_) => TransactionDetails(transaction: transaction),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case TransactionRecordAction.edit:
        _openEditModal(context, transaction);
      case TransactionRecordAction.delete:
        await _deleteTransaction(transaction);
      case TransactionRecordAction.openDebt:
        try {
          final debt = await DebtStore().forTransaction(transaction);
          if (!mounted) return;
          await showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            sheetAnimationStyle: AnimationStyle.noAnimation,
            builder: (_) => DebtDetail(debt: debt),
          );
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).loadError)),
            );
          }
        }
    }
  }

  void _showUndoSnackBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snackBar = SnackBar(
      content: Text(l10n.transactionDeleted),
      action: SnackBarAction(
        label: l10n.undo,
        onPressed: () {
          final provider = Provider.of<TransactionProvider>(
            context,
            listen: false,
          );
          provider.undoDelete();
        },
      ),
      duration: const Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
