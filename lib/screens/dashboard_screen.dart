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
import '../widgets/income_modal.dart';
import '../widgets/expense_modal.dart';
import '../widgets/wallet_selector.dart';

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
      if (walletProvider.selectedWalletId == null) {
        walletProvider.selectWallet(Wallet.cashWalletId);
      }
      txnProvider.walletFilter =
          walletProvider.selectedWalletId ?? Wallet.cashWalletId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            const WalletSelector(),
            const SizedBox(height: 8),
            _buildBalanceCard(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: l10n.searchByRemark,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
                onChanged: (val) {
                  Provider.of<TransactionProvider>(context, listen: false)
                      .searchQuery = val;
                },
              ),
            ),
            Expanded(
              child: Consumer<TransactionProvider>(
                builder: (ctx, provider, _) {
                  final list = provider.filteredTransactions;
                  if (list.isEmpty) {
                    return Center(
                      child: Text(l10n.noTransactionsYet),
                    );
                  }
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (ctx, index) {
                      final txn = list[index];
                      return Dismissible(
                        key: Key(txn.id.toString()),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(l10n.deleteTransaction),
                                content: Text(l10n.deleteTransactionBody),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(l10n.cancel),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: Text(l10n.delete),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              provider.softDelete(txn.id!);
                              if (!context.mounted) return true;
                              _showUndoSnackBar(context);
                              return true;
                            } else {
                              return false;
                            }
                          } else {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
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
                              const Icon(Icons.delete, color: Colors.white),
                            ],
                          ),
                        ),
                        child: TransactionListItem(txn: txn),
                      );
                    },
                  );
                },
              ),
            ),
          ],
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
    return Consumer2<TransactionProvider, WalletProvider>(
      builder: (ctx, txnProvider, walletProvider, _) {
        final selectedWallet = walletProvider.selectedWallet;
        final startingBalance = selectedWallet != null
            ? selectedWallet.initialBalance
            : walletProvider.combinedInitialBalance;
        final balance = startingBalance + txnProvider.totalBalance;
        final weekIncome = txnProvider.weeklyIncome;
        final weekExpense = txnProvider.weeklyExpense;
        final settings = Provider.of<SettingsProvider>(context);
        final currency = settings.currencySymbol;
        final label = selectedWallet != null
            ? '${selectedWallet.icon} ${selectedWallet.name} ${l10n.balance}'
            : l10n.balanceAllWallets;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(label, style: const TextStyle(fontSize: 18)),
                Text(
                  '$currency${formatAmount(balance)}',
                  style: const TextStyle(
                      fontSize: 32, fontWeight: FontWeight.bold),
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
    return Provider.of<WalletProvider>(context, listen: false)
            .selectedWalletId ??
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
            Provider.of<TransactionProvider>(context, listen: false)
                .addTransaction(txn);
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
            Provider.of<TransactionProvider>(context, listen: false)
                .addTransaction(txn);
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
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: IncomeModal(
            initialTransaction: txn,
            defaultWalletId: txn.walletId,
            onSave: (updated) {
              Provider.of<TransactionProvider>(context, listen: false)
                  .updateTransaction(updated);
            },
          ),
        ),
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpenseModal(
            initialTransaction: txn,
            defaultWalletId: txn.walletId,
            onSave: (updated) {
              Provider.of<TransactionProvider>(context, listen: false)
                  .updateTransaction(updated);
            },
          ),
        ),
      );
    }
  }

  void _showUndoSnackBar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final snackBar = SnackBar(
      content: Text(l10n.transactionDeleted),
      action: SnackBarAction(
        label: l10n.undo,
        onPressed: () {
          final provider =
              Provider.of<TransactionProvider>(context, listen: false);
          provider.undoDelete();
          final last = provider.lastDeleted;
          if (last != null) {
            provider.addTransaction(last);
          }
        },
      ),
      duration: const Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
