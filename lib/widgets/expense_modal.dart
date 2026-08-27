import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/settings_provider.dart';

class ExpenseModal extends StatefulWidget {
  final Transaction? initialTransaction;
  final Function(Transaction) onSave;

  const ExpenseModal({
    super.key,
    this.initialTransaction,
    required this.onSave,
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

  final _cashGivenController = TextEditingController();
  final _cashReceivedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.initialTransaction != null) {
      _amountController.text = widget.initialTransaction!.amount.toString();
      _remarkController.text = widget.initialTransaction!.remark ?? '';
      _selectedCategory =
          widget.initialTransaction!.category ?? Category.others;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _remarkController.dispose();
    _cashGivenController.dispose();
    _cashReceivedController.dispose();
    super.dispose();
  }

  void _calculateFromChange() {
    final given = double.tryParse(_cashGivenController.text) ?? 0;
    final received = double.tryParse(_cashReceivedController.text) ?? 0;
    final spent = given - received;
    if (spent > 0) {
      _amountController.text = spent.toStringAsFixed(2);
    }
  }

  void _save() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;
    final txn = Transaction(
      id: widget.initialTransaction?.id,
      type: TransactionType.expense,
      amount: amount,
      category: _selectedCategory,
      remark: _remarkController.text.trim().isEmpty
          ? null
          : _remarkController.text.trim(),
      date: widget.initialTransaction?.date ?? DateTime.now(),
    );
    widget.onSave(txn);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<SettingsProvider>(context).currencySymbol;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.initialTransaction == null
                  ? 'Add Expense'
                  : 'Edit Expense',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Direct'),
                Tab(text: 'Change Calculator'),
              ],
            ),
            // ✅ FIX: give the TabBarView a fixed height
            SizedBox(
              height: 280,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDirectTab(currency),
                  _buildCalculatorTab(currency),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectTab(String currency) {
    return Column(
      children: [
        TextField(
          controller: _amountController,
          decoration: InputDecoration(
            labelText: 'Amount',
            prefixText: '$currency ',
          ),
          keyboardType: TextInputType.number,
        ),
        _buildCategoryDropdown(),
        TextField(
          controller: _remarkController,
          decoration: const InputDecoration(labelText: 'Remark (optional)'),
        ),
      ],
    );
  }

  Widget _buildCalculatorTab(String currency) {
    return Column(
      children: [
        TextField(
          controller: _cashGivenController,
          decoration: const InputDecoration(labelText: 'Cash given'),
          keyboardType: TextInputType.number,
          onChanged: (_) => _calculateFromChange(),
        ),
        TextField(
          controller: _cashReceivedController,
          decoration: const InputDecoration(labelText: 'Cash received back'),
          keyboardType: TextInputType.number,
          onChanged: (_) => _calculateFromChange(),
        ),
        const SizedBox(height: 8),
        Text(
          'Computed amount: $currency${_amountController.text.isEmpty ? '0.00' : _amountController.text}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        _buildCategoryDropdown(),
        TextField(
          controller: _remarkController,
          decoration: const InputDecoration(labelText: 'Remark (optional)'),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
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
      decoration: const InputDecoration(labelText: 'Category'),
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
