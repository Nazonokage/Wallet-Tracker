import 'package:expense_tracker/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/providers/settings_provider.dart';
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
  Widget build(BuildContext context) {
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
                decoration: const InputDecoration(
                  hintText: 'Search by remark...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
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
                    return const Center(
                      child: Text(
                          '📭 No transactions yet — tap + or − to add one'),
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
                            // Swipe from right → left = DELETE (orange bar,
                            // shown via `secondaryBackground` below).
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete Transaction?'),
                                content:
                                    const Text('This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              provider.softDelete(txn.id!);
                              if (!context.mounted) return true;
                              _showUndoSnackBar(context);
                              return true; // remove the item
                            } else {
                              return false; // keep it
                            }
                          } else {
                            // Swipe from left → right = EDIT (green bar,
                            // shown via `background` below).
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) _openEditModal(context, txn);
                            });
                            return false; // do NOT remove the item
                          }
                        },
                        // ─── LEFT‑TO‑RIGHT SWIPE (Edit) ────────────────────────
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
                        // ─── RIGHT‑TO‑LEFT SWIPE (Delete) ──────────────────────
                        secondaryBackground: Container(
                          color: Colors.orange,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.delete, color: Colors.white),
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
            backgroundColor: Colors.red,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ✅ Balance now factors in the selected wallet's starting balance (or the
  // combined starting balance of every wallet, for the "All" view), plus
  // that wallet's own income/expense — TransactionProvider is already
  // scoped to the selected wallet via `walletFilter`.
  Widget _buildBalanceCard(BuildContext context) {
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
            ? '${selectedWallet.icon} ${selectedWallet.name} Balance'
            : 'Balance (All wallets)';
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
                  'This week: +$currency${formatAmount(weekIncome)} / −$currency${formatAmount(weekExpense)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ New transactions default to whichever wallet is currently selected
  // in the switcher. If "All" is selected, they default to Cash — the user
  // can still change wallet inside the modal's dropdown.
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
    final snackBar = SnackBar(
      content: const Text('Transaction deleted'),
      action: SnackBarAction(
        label: 'UNDO',
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
