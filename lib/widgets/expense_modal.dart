import 'package:expense_tracker/l10n/app_localizations.dart';
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

class _ExpenseModalState extends State<ExpenseModal> {
  int _currentTab = 0; // 0: Direct, 1: Change Calculator
  final _amountController = TextEditingController();
  final _remarkController = TextEditingController();
  Category _selectedCategory = Category.others;
  late int _selectedWalletId;

  final _cashGivenController = TextEditingController();
  final _cashReceivedController = TextEditingController();

  static const Color _expenseAccent = Color(0xFFD32F2F);

  @override
  void initState() {
    super.initState();
    _cashGivenController.addListener(_calculateFromChange);
    _cashReceivedController.addListener(_calculateFromChange);
    _selectedWalletId = widget.initialTransaction?.walletId ??
        widget.defaultWalletId ??
        Wallet.cashWalletId;

    if (widget.initialTransaction != null) {
      final raw = widget.initialTransaction!.amount;
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
    _amountController.dispose();
    _remarkController.dispose();
    _cashGivenController.dispose();
    _cashReceivedController.dispose();
    super.dispose();
  }

  void _calculateFromChange() {
    final given = parseAmount(_cashGivenController.text) ?? 0;
    final received = parseAmount(_cashReceivedController.text) ?? 0;
    final spent = given - received;
    _amountController.text = spent > 0 ? formatAmount(spent) : '0.00';
    setState(() {});
  }

  double? _largeSpendThreshold(Category category) {
    switch (category) {
      case Category.food:
        return 100.0;
      case Category.bills:
        return 2000.0;
      case Category.shopping:
        return 500.0;
      case Category.others:
        return 300.0;
      case Category.commute:
        return null;
    }
  }

  Future<void> _save() async {
    final rawAmount = parseAmount(_amountController.text);
    if (rawAmount == null || rawAmount <= 0) return;

    final threshold = _largeSpendThreshold(_selectedCategory);
    if (threshold != null && rawAmount > threshold) {
      final l10n = AppLocalizations.of(context);
      final categoryName = _selectedCategory.name;
      final currency =
          Provider.of<SettingsProvider>(context, listen: false).currencySymbol;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.largeExpenseTitle),
          content: Text(
            l10n.largeExpenseBody(
              currency,
              formatAmount(rawAmount),
              categoryName,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: _expenseAccent),
              child: Text(l10n.yesSpendIt),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

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
    if (mounted) Navigator.pop(context);
  }

  Widget _buildWalletDropdown(ThemeData theme) {
    return Consumer<WalletProvider>(
      builder: (ctx, walletProvider, _) {
        final wallets = walletProvider.wallets;
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
            labelText: AppLocalizations.of(context).wallet,
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
              borderSide: const BorderSide(
                color: _expenseAccent,
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.remove_circle_outline, color: _expenseAccent),
                const SizedBox(width: 8),
                Text(
                  widget.initialTransaction == null
                      ? AppLocalizations.of(context).addExpense
                      : AppLocalizations.of(context).editExpense,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tab Selector (Direct vs Change Calculator)
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _currentTab == 0
                              ? _expenseAccent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context).direct,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _currentTab == 0
                                ? Colors.white
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _currentTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _currentTab == 1
                              ? _expenseAccent
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context).changeCalculator,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _currentTab == 1
                                ? Colors.white
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tab Content
            _currentTab == 0
                ? _buildDirectTab(currency, theme)
                : _buildCalculatorTab(currency, theme),

            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _expenseAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context).save,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectTab(String currency, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AmountTextField(
          controller: _amountController,
          labelText: AppLocalizations.of(context).amount,
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
            labelText: AppLocalizations.of(context).remarkOptional,
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
              borderSide: const BorderSide(
                color: _expenseAccent,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        AmountTextField(
          controller: _cashGivenController,
          labelText: AppLocalizations.of(context).cashGiven,
          currencySymbol: currency,
        ),
        const SizedBox(height: 10),
        AmountTextField(
          controller: _cashReceivedController,
          labelText: AppLocalizations.of(context).cashReceivedBack,
          currencySymbol: currency,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _expenseAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _expenseAccent.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).computedAmount,
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
            labelText: AppLocalizations.of(context).remarkOptional,
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
              borderSide: const BorderSide(
                color: _expenseAccent,
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
          borderSide: const BorderSide(
            color: _expenseAccent,
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
