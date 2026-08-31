import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/utils/formatter.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import '../providers/settings_provider.dart';
import '../providers/wallet_provider.dart';
import '../widgets/amount_text_field.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';

class IncomeModal extends StatefulWidget {
  final Transaction? initialTransaction;
  final Function(Transaction) onSave;
  // ✅ Which wallet this should default to (e.g. whatever's selected on
  // the dashboard). Falls back to Cash if omitted.
  final int? defaultWalletId;

  const IncomeModal({
    super.key,
    this.initialTransaction,
    required this.onSave,
    this.defaultWalletId,
  });

  @override
  State<IncomeModal> createState() => _IncomeModalState();
}

class _IncomeModalState extends State<IncomeModal> {
  final _amountController = TextEditingController();
  final _remarkController = TextEditingController();
  late int _selectedWalletId;

  @override
  void initState() {
    super.initState();
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
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  void _save() {
    final rawAmount = parseAmount(_amountController.text);
    if (rawAmount == null || rawAmount <= 0) return;
    final txn = Transaction(
      id: widget.initialTransaction?.id,
      type: TransactionType.income,
      amount: rawAmount,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add_circle_outline, color: Colors.green.shade400),
              const SizedBox(width: 8),
              Text(
                widget.initialTransaction == null
                    ? AppLocalizations.of(context).addIncome
                    : AppLocalizations.of(context).editIncome,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AmountTextField(
            controller: _amountController,
            labelText: AppLocalizations.of(context).amount,
            currencySymbol: currency,
          ),
          const SizedBox(height: 12),
          _buildWalletDropdown(theme),
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
              child: Text(
                AppLocalizations.of(context).save,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
