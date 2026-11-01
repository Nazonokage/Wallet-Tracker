import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/transaction.dart';
import '../providers/settings_provider.dart';
import '../providers/wallet_provider.dart';
import '../utils/formatter.dart';

enum TransactionRecordAction { edit, delete, openDebt }

class TransactionDetails extends StatelessWidget {
  final Transaction transaction;
  const TransactionDetails({super.key, required this.transaction});

  String _category(AppLocalizations l, Category category) => switch (category) {
    Category.food => l.food,
    Category.commute => l.commute,
    Category.bills => l.bills,
    Category.shopping => l.shopping,
    Category.others => l.others,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = transaction;
    final settings = context.watch<SettingsProvider>();
    final wallet = context
        .read<WalletProvider>()
        .wallets
        .where((w) => w.id == t.walletId)
        .firstOrNull;
    final locale = Localizations.localeOf(context).toString();
    final date = t.date.toLocal();
    final minutes = date.timeZoneOffset.inMinutes;
    final zone =
        'UTC${minutes < 0 ? '−' : '+'}${(minutes.abs() ~/ 60).toString().padLeft(2, '0')}:${(minutes.abs() % 60).toString().padLeft(2, '0')}';
    final theme = Theme.of(context);
    Widget field(String label, String value) => Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          SelectableText(value, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.recordDetails, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              '${t.type == TransactionType.income ? '+' : '−'} ${settings.currencySymbol}${formatAmount(t.amount)}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            field(
              l.transactionType,
              t.type == TransactionType.income ? l.incomeLabel : l.expenseLabel,
            ),
            field(
              l.recordedAt,
              '${DateFormat.yMMMMEEEEd(locale).add_Hms().format(date)}\n$zone',
            ),
            field(l.wallet, wallet?.name ?? '#${t.walletId}'),
            if (t.category != null)
              field(l.transactionCategory, _category(l, t.category!)),
            if (t.remark?.isNotEmpty ?? false) field(l.remarkLabel, t.remark!),
            const SizedBox(height: 24),
            if (t.isDebtManaged) ...[
              Text(l.managedDebtRecord),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () =>
                    Navigator.pop(context, TransactionRecordAction.openDebt),
                icon: const Icon(Icons.handshake_outlined),
                label: Text(l.openDebt),
              ),
            ] else
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: () =>
                        Navigator.pop(context, TransactionRecordAction.edit),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(l.edit),
                  ),
                  OutlinedButton.icon(
                    onPressed: () =>
                        Navigator.pop(context, TransactionRecordAction.delete),
                    icon: const Icon(Icons.delete_outline),
                    label: Text(l.delete),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
