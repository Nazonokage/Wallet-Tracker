import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../utils/formatter.dart'; // ✅ import the formatter

/// ✅ Formats digits with thousands commas *live*, while preserving cursor
/// position by tracking how many digits are to the left of the cursor
/// (instead of raw character offset, which breaks when commas shift).
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // How many digits sit before the cursor in the new (unformatted) input.
    final selectionIndex = newValue.selection.end < 0
        ? newValue.text.length
        : newValue.selection.end;
    final beforeCursor = newValue.text.substring(0, selectionIndex);
    final digitsBeforeCursor =
        beforeCursor.replaceAll(RegExp(r'[^0-9]'), '').length;

    // Strip everything except digits and dots.
    String cleaned = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Keep only the first decimal point, cap decimals at 2 digits (centavos).
    final dotIndex = cleaned.indexOf('.');
    if (dotIndex != -1) {
      final intSection = cleaned.substring(0, dotIndex);
      var decSection = cleaned.substring(dotIndex + 1).replaceAll('.', '');
      if (decSection.length > 2) decSection = decSection.substring(0, 2);
      cleaned = '$intSection.$decSection';
    }

    // Split into integer / decimal parts.
    String intPart;
    String? decPart;
    if (cleaned.contains('.')) {
      final split = cleaned.split('.');
      intPart = split[0];
      decPart = split.length > 1 ? split[1] : '';
    } else {
      intPart = cleaned;
      decPart = null;
    }

    // Strip leading zeros (but allow a single leading 0 before a decimal).
    intPart = intPart.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    final formattedInt = _addCommas(intPart);
    final formatted = decPart != null ? '$formattedInt.$decPart' : formattedInt;

    // Walk the formatted string, counting digits, to find where the cursor
    // should land so it stays "attached" to the same digit the user typed.
    int newCursor = formatted.length;
    int digitsSeen = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (digitsSeen >= digitsBeforeCursor) {
        newCursor = i;
        break;
      }
      if (RegExp(r'[0-9]').hasMatch(formatted[i])) {
        digitsSeen++;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursor),
    );
  }

  String _addCommas(String intPart) {
    if (intPart.isEmpty) return intPart;
    final reversed = intPart.split('').reversed.toList();
    final buffer = StringBuffer();
    for (int i = 0; i < reversed.length; i++) {
      buffer.write(reversed[i]);
      if ((i + 1) % 3 == 0 && i + 1 != reversed.length) {
        buffer.write(',');
      }
    }
    return buffer.toString().split('').reversed.join();
  }
}

class AmountTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String currencySymbol;
  final String? Function(String?)? validator;

  const AmountTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.currencySymbol,
    this.validator,
  });

  @override
  State<AmountTextField> createState() => _AmountTextFieldState();
}

class _AmountTextFieldState extends State<AmountTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    // ✅ On blur, normalize to always show 2 decimal places (centavos),
    // e.g. "16,166,166" -> "16,166,166.00".
    if (!_focusNode.hasFocus) {
      _formatAmount();
    }
  }

  void _formatAmount() {
    final text = widget.controller.text;
    if (text.isEmpty) return;
    final double? raw = parseAmount(text);
    if (raw == null) return;
    final formatted = NumberFormat('#,##0.00').format(raw);
    widget.controller.text = formatted;
    widget.controller.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.controller.text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixText: '${widget.currencySymbol} ',
        prefixStyle: const TextStyle(fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      // ✅ Live comma formatting + max 2 decimal places, cursor-safe.
      inputFormatters: [ThousandsSeparatorInputFormatter()],
      // No onChanged here anymore — all formatting happens inside the
      // TextInputFormatter above, which is the cursor-safe way to do it.
    );
  }
}
