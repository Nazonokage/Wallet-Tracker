import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../utils/formatter.dart';

/// Live thousands-separator formatter that:
/// - Allows typing "." to enter centavos immediately
/// - Caps decimals at 2 digits
/// - Keeps the cursor in the right place when commas appear/disappear
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Raw selection in the incoming (pre-format) text
    final selectionIndex = newValue.selection.end < 0
        ? newValue.text.length
        : newValue.selection.end;

    // Keep only digits and a single '.'
    String cleaned = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Only one decimal point, max 2 digits after it
    final firstDot = cleaned.indexOf('.');
    if (firstDot != -1) {
      final intSection = cleaned.substring(0, firstDot);
      var decSection = cleaned.substring(firstDot + 1).replaceAll('.', '');
      if (decSection.length > 2) {
        decSection = decSection.substring(0, 2);
      }
      cleaned = '$intSection.$decSection';
    }

    // Did the user just type / keep a trailing decimal point?
    // (e.g. "12." so they can type centavos next)
    final endsWithDot = cleaned.endsWith('.');
    final hasDot = cleaned.contains('.');

    String intPart;
    String? decPart;
    if (hasDot) {
      final split = cleaned.split('.');
      intPart = split[0];
      decPart = split.length > 1 ? split[1] : '';
    } else {
      intPart = cleaned;
      decPart = null;
    }

    // Strip leading zeros, but allow "0" and "0.xx"
    if (intPart.isEmpty) {
      intPart = '0';
    } else {
      intPart = intPart.replaceFirst(RegExp(r'^0+(?=\d)'), '');
      if (intPart.isEmpty) intPart = '0';
    }

    final formattedInt = _addCommas(intPart);

    String formatted;
    if (decPart != null) {
      // Preserve trailing "." so user can type ".50" etc.
      formatted = endsWithDot && decPart.isEmpty
          ? '$formattedInt.'
          : '$formattedInt.$decPart';
    } else {
      formatted = formattedInt;
    }

    // --- Cursor placement ---
    // Count how many *significant* characters (digits + the decimal point)
    // sit before the cursor in the cleaned input, then map that onto
    // the formatted string.
    final beforeCursorRaw = newValue.text.substring(0, selectionIndex);
    final cleanedBefore = beforeCursorRaw.replaceAll(RegExp(r'[^0-9.]'), '');
    // Cap to one dot in the before-cursor slice too
    String significantBefore = cleanedBefore;
    final dotInBefore = significantBefore.indexOf('.');
    if (dotInBefore != -1) {
      significantBefore = significantBefore.substring(0, dotInBefore + 1) +
          significantBefore.substring(dotInBefore + 1).replaceAll('.', '');
    }

    int targetSignificant = significantBefore.length;
    // If user typed only ".", significantBefore is "." → length 1
    int newCursor = formatted.length;
    int seen = 0;
    for (int i = 0; i < formatted.length; i++) {
      final ch = formatted[i];
      if (ch == ',') continue; // commas are visual only
      seen++;
      if (seen >= targetSignificant) {
        newCursor = i + 1;
        break;
      }
    }

    // Clamp
    if (newCursor > formatted.length) newCursor = formatted.length;
    if (newCursor < 0) newCursor = 0;

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
    // On blur, normalize to always show 2 decimal places (centavos),
    // e.g. "16,166,166" -> "16,166,166.00" or "12." -> "12.00".
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
      inputFormatters: [ThousandsSeparatorInputFormatter()],
    );
  }
}
