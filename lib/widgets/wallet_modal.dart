import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wallet.dart';
import '../providers/settings_provider.dart';
import '../utils/formatter.dart';
import 'amount_text_field.dart';

class WalletModal extends StatefulWidget {
  final Wallet? initialWallet;
  final Function(Wallet) onSave;

  const WalletModal({super.key, this.initialWallet, required this.onSave});

  @override
  State<WalletModal> createState() => _WalletModalState();
}

class _WalletModalState extends State<WalletModal> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  String _icon = '👛';

  static const _iconOptions = ['👛', '🏦', '💳', '📱', '💵', '🐷'];

  @override
  void initState() {
    super.initState();
    if (widget.initialWallet != null) {
      _nameController.text = widget.initialWallet!.name;
      _balanceController.text =
          formatAmount(widget.initialWallet!.initialBalance);
      _icon = widget.initialWallet!.icon;
    } else {
      _balanceController.text = '0.00';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final balance = parseAmount(_balanceController.text) ?? 0.0;
    final wallet = Wallet(
      id: widget.initialWallet?.id,
      name: name,
      icon: _icon,
      initialBalance: balance,
      createdAt: widget.initialWallet?.createdAt,
    );
    widget.onSave(wallet);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = Provider.of<SettingsProvider>(context).currencySymbol;
    final isDefault = widget.initialWallet?.isDefault ?? false;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.initialWallet == null ? 'Add Wallet' : 'Edit Wallet',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _iconOptions.map((emoji) {
                final selected = emoji == _icon;
                return ChoiceChip(
                  label: Text(emoji, style: const TextStyle(fontSize: 18)),
                  selected: selected,
                  onSelected: (_) => setState(() => _icon = emoji),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              // ✅ Cash's name is locked — it's the anchor wallet everything
              // else defaults to, so renaming it could get confusing.
              enabled: !isDefault,
              decoration: InputDecoration(
                labelText: 'Wallet name (e.g. BDO, GCash)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),
            AmountTextField(
              controller: _balanceController,
              labelText: 'Starting balance',
              currencySymbol: currency,
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
          ],
        ),
      ),
    );
  }
}
