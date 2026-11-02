import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_localizations.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction txn;
  final bool alternate;
  final VoidCallback? onTap;

  const TransactionListItem({
    super.key,
    required this.txn,
    this.alternate = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = txn.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final currency = context.select<SettingsProvider, String>(
      (s) => s.currencySymbol,
    );
    final l = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: alternate
          ? Color.alphaBlend(
              Colors.white.withValues(
                alpha: colors.brightness == Brightness.dark ? 0.06 : 0.65,
              ),
              colors.surface,
            )
          : colors.surface,
      child: ListTile(
        onTap: onTap,
        leading: Text(txn.categoryEmoji, style: const TextStyle(fontSize: 24)),
        title: Text(
          txn.remark ?? (isIncome ? l.incomeLabel : l.expenseLabel),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${txn.isDebtManaged ? '${AppLocalizations.of(context).debts} · ' : ''}${txn.date.toString().split(' ')[0]}',
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'} $currency${txn.amount.toStringAsFixed(2)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
