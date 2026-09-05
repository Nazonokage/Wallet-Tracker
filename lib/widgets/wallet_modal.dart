import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/wallet.dart';
import '../models/wallet_preset.dart';
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
  final _subtitleController = TextEditingController();

  String _icon = '👛';
  String _category = 'Bank Accounts';
  int _colorValue = 0xFF007DFF; // Default GCash Blue

  static const _iconOptions = [
    '👛', '📱', '🏛️', '🏦', '💳', '🟢', '⚡', '💎', '🌊', '💵', '🐷', '🟠'
  ];

  static const _categories = [
    'E-wallets',
    'Bank Accounts',
    'Savings & Investments',
    'Cash',
    'Other'
  ];

  static const List<int> _presetColors = [
    0xFF007DFF, // GCash Blue
    0xFF00D632, // Maya Green
    0xFFD32F2F, // BPI Red
    0xFF0B3C5D, // BDO Navy
    0xFF8EDE27, // Wise Lime
    0xFF00B4D8, // GoTyme Cyan
    0xFFF57C00, // SeaBank Orange
    0xFF003087, // PayPal Dark Blue
    0xFF7B1FA2, // Purple
    0xFF388E3C, // Cash Green
    0xFF37474F, // Dark Slate
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialWallet != null) {
      _nameController.text = widget.initialWallet!.name;
      _balanceController.text =
          formatAmount(widget.initialWallet!.initialBalance);
      _icon = widget.initialWallet!.icon;
      _category = widget.initialWallet!.category;
      _colorValue = widget.initialWallet!.colorValue;
      _subtitleController.text = widget.initialWallet!.subtitle ?? '';
    } else {
      _balanceController.text = '0.00';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _applyPreset(WalletPreset preset) {
    setState(() {
      _nameController.text = preset.name;
      _category = preset.category;
      _icon = preset.icon;
      _colorValue = preset.colorValue;
      _subtitleController.text = preset.defaultSubtitle;
    });
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final balance = parseAmount(_balanceController.text) ?? 0.0;
    final subtitle = _subtitleController.text.trim();

    final wallet = Wallet(
      id: widget.initialWallet?.id,
      name: name,
      icon: _icon,
      initialBalance: balance,
      createdAt: widget.initialWallet?.createdAt,
      category: _category,
      colorValue: _colorValue,
      subtitle: subtitle.isNotEmpty ? subtitle : null,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initialWallet == null ? 'Add Wallet' : 'Edit Wallet',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (!isDefault)
                  PopupMenuButton<WalletPreset>(
                    tooltip: 'Quick Presets',
                    onSelected: _applyPreset,
                    itemBuilder: (ctx) => WalletPreset.presets.map((p) {
                      return PopupMenuItem<WalletPreset>(
                        value: p,
                        child: Row(
                          children: [
                            Text(p.icon, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(p.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    '${p.category} • ${p.defaultSubtitle}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Color(p.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt,
                              size: 16,
                              color: theme.colorScheme.onPrimaryContainer),
                          const SizedBox(width: 4),
                          Text(
                            'Presets',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Card Color Swatches
            Text('Card Accent Color',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _presetColors.map((colorVal) {
                  final isSelected = _colorValue == colorVal;
                  return GestureDetector(
                    onTap: () => setState(() => _colorValue = colorVal),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Color(colorVal),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(colorVal).withValues(alpha: 0.6),
                                  blurRadius: 6,
                                  spreadRadius: 2,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 18, color: Colors.white)
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Category Selection
            Text('Wallet Category',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue:
                  _categories.contains(_category) ? _category : 'Bank Accounts',
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _category = val);
              },
            ),
            const SizedBox(height: 16),

            // Icon Chips
            Text('Icon',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _iconOptions.map((emoji) {
                  final selected = emoji == _icon;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(emoji, style: const TextStyle(fontSize: 18)),
                      selected: selected,
                      onSelected: (_) => setState(() => _icon = emoji),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Name Field
            TextField(
              controller: _nameController,
              enabled: !isDefault,
              decoration: InputDecoration(
                labelText: 'Wallet Name (e.g. GCash, BPI Savings)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle Field
            TextField(
              controller: _subtitleController,
              decoration: InputDecoration(
                labelText: 'Subtitle / Details (e.g. Debit • PHP, 1.25% yearly)',
                hintText: 'Optional label under name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 12),

            // Initial Balance Field
            AmountTextField(
              controller: _balanceController,
              labelText: 'Starting balance',
              currencySymbol: currency,
            ),
            const SizedBox(height: 20),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Color(_colorValue),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Save Wallet',
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
