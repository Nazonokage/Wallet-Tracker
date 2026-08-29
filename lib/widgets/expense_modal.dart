import 'package:expense_tracker/utils/formatter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../providers/settings_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/amount_text_field.dart';

class ExpenseModal extends StatefulWidget {
  final Transaction? initialTransaction;
  final Function(Transaction) onSave;
  // ✅ Which wallet this should default to (e.g. whatever's selected on
  // the dashboard). Falls back to Cash if omitted.
  final int? defaultWalletId;

  const ExpenseModal({
    super.key,
    this.initialTransaction,
    required this.onSave,
    this.defaultWalletId,
  });

  @override
  State<ExpenseModal> createState() => _ExpenseModalState();
}

class _ExpenseModalState extends State<ExpenseModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  final _remarkController = TextEditingController();
  Category _selectedCategory = Category.others;
  late int _selectedWalletId;

  final _cashGivenController = TextEditingController();
  final _cashReceivedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // ✅ AmountTextField doesn't expose onChanged, so listen on the
    // controllers directly to keep the computed amount live.
    _cashGivenController.addListener(_calculateFromChange);
    _cashReceivedController.addListener(_calculateFromChange);
    // ✅ Editing keeps the transaction's original wallet; new transactions
    // default to whatever wallet was passed in (falls back to Cash).
    _selectedWalletId = widget.initialTransaction?.walletId ??
        widget.defaultWalletId ??
        Wallet.cashWalletId;
    if (widget.initialTransaction != null) {
      final raw = widget.initialTransaction!.amount;
      // ✅ Format with commas on load
      _amountController.text = formatAmount(raw);
      _remarkController.text = widget.initialTransaction!.remark ?? '';
      _selectedCategory =
          widget.initialTransaction!.category ?? Category.others;
    }
  }

  @override
  void dispose() {
    _cashGivenController.removeListener(_calculateFromChange);
    _cashReceivedController.removeListener(_calculateFromChange);
    _tabController.dispose();
    _amountController.dispose();
    _remarkController.dispose();
    _cashGivenController.dispose();
    _cashReceivedController.dispose();
    super.dispose();
  }

  void _calculateFromChange() {
    // ✅ Use parseAmount so commas from the AmountTextField formatting
    // don't break the parse (double.tryParse chokes on "6,464,646").
    final given = parseAmount(_cashGivenController.text) ?? 0;
    final received = parseAmount(_cashReceivedController.text) ?? 0;
    final spent = given - received;
    _amountController.text = spent > 0 ? formatAmount(spent) : '0.00';
    setState(() {});
  }

  void _save() {
    // ✅ Use parseAmount directly
    final rawAmount = parseAmount(_amountController.text);
    if (rawAmount == null || rawAmount <= 0) return;
    final txn = Transaction(
      id: widget.initialTransaction?.id,
      type: TransactionType.expense,
      amount: rawAmount,
      category: _selectedCategory,
      remark: _remarkController.text.trim().isEmpty
          ? null
          : _remarkController.text.trim(),
      date: widget.initialTransaction?.date ?? DateTime.now(),
      walletId: _selectedWalletId,
    );
    widget.onSave(txn);
    Navigator.pop(context);
  }

  Widget _buildWalletDropdown(ThemeData theme) {
    return Consumer<WalletProvider>(
      builder: (ctx, walletProvider, _) {
        final wallets = walletProvider.wallets;
        // Guard against the selected wallet having just been deleted.
        final validId = wallets.any((w) => w.id == _selectedWalletId)
            ? _selectedWalletId
            : Wallet.cashWalletId;
        return DropdownButtonFormField<int>(
          initialValue: validId,
          items: wallets.map((w) {
            return DropdownMenuItem<int>(
              value: w.id,
              child: Text('${w.icon} ${w.name}'),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedWalletId = val!),
          decoration: InputDecoration(
            labelText: 'Wallet',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<SettingsProvider>(context).currencySymbol;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.remove_circle_outline, color: Colors.red.shade400),
                const SizedBox(width: 8),
                Text(
                  widget.initialTransaction == null
                      ? 'Add Expense'
                      : 'Edit Expense',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: theme.colorScheme.onPrimaryContainer,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'Direct'),
                  Tab(text: 'Change Calculator'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 420, // was 320
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDirectTab(currency, theme),
                  _buildCalculatorTab(currency, theme),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectTab(String currency, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AmountTextField(
          controller: _amountController,
          labelText: 'Amount',
          currencySymbol: currency,
        ),
        const SizedBox(height: 12),
        _buildWalletDropdown(theme),
        const SizedBox(height: 12),
        _buildCategoryDropdown(theme),
        const SizedBox(height: 12),
        TextField(
          controller: _remarkController,
          decoration: InputDecoration(
            labelText: 'Remark (optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculatorTab(String currency, ThemeData theme) {
    final computedValue = parseAmount(_amountController.text) ?? 0.0;
    final formattedComputed = formatAmount(computedValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AmountTextField(
          controller: _cashGivenController,
          labelText: 'Cash given',
          currencySymbol: currency,
        ),
        const SizedBox(height: 10),
        AmountTextField(
          controller: _cashReceivedController,
          labelText: 'Cash received back',
          currencySymbol: currency,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Computed amount:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '$currency$formattedComputed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _buildWalletDropdown(theme),
        const SizedBox(height: 12),
        _buildCategoryDropdown(theme),
        const SizedBox(height: 12),
        TextField(
          controller: _remarkController,
          decoration: InputDecoration(
            labelText: 'Remark (optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(ThemeData theme) {
    return DropdownButtonFormField<Category>(
      initialValue: _selectedCategory,
      items: Category.values.map((cat) {
        return DropdownMenuItem<Category>(
          value: cat,
          child:
              Text('${_categoryEmoji(cat)} ${cat.toString().split('.').last}'),
        );
      }).toList(),
      onChanged: (val) => setState(() => _selectedCategory = val!),
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }

  String _categoryEmoji(Category category) {
    switch (category) {
      case Category.food:
        return '🍔';
      case Category.commute:
        return '🚌';
      case Category.bills:
        return '📄';
      case Category.shopping:
        return '🛍️';
      case Category.others:
        return '📦';
    }
  }
}
