import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/debt.dart';
import '../providers/debt_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/wallet_provider.dart';
import '../utils/formatter.dart';

enum DebtDirectionFilter { lent, borrowed }

String debtMoney(BuildContext context, int minor) =>
    '${context.read<SettingsProvider>().currencySymbol}${formatAmount(minor / 100)}';

Future<void> refreshDebtMovements(BuildContext context) async {
  await context.read<TransactionProvider>().loadTransactions();
}

Future<void> showDebtForm(BuildContext context, {Debt? debt}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      sheetAnimationStyle: AnimationStyle.noAnimation,
      builder: (_) => DebtForm(debt: debt),
    );

class DebtsScreen extends StatefulWidget {
  final DebtDirectionFilter? directionFilter;
  const DebtsScreen({super.key, this.directionFilter});
  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

class _DebtsScreenState extends State<DebtsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DebtProvider>().load(filter: DebtStatus.outstanding);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<DebtProvider>();
    context.watch<SettingsProvider>();
    final rows = provider.debts
        .where(
          (d) =>
              widget.directionFilter == null ||
              d.direction.name == widget.directionFilter!.name,
        )
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(l.debts)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDebtForm(context),
        icon: const Icon(Icons.add),
        label: Text(l.iou),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.owedToYou),
                    Flexible(
                      child: Text(
                        debtMoney(
                          context,
                          provider.totals[DebtDirection.lent] ?? 0,
                        ),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l.youOwe),
                    Text(
                      debtMoney(
                        context,
                        provider.totals[DebtDirection.borrowed] ?? 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final s in DebtStatus.values)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        s == DebtStatus.outstanding
                            ? l.outstanding
                            : s == DebtStatus.partial
                            ? l.partial
                            : l.archived,
                      ),
                      selected: provider.status == s,
                      onSelected: (_) => provider.load(filter: s),
                    ),
                  ),
              ],
            ),
          ),
          if (provider.failed)
            TextButton(
              onPressed: () => provider.load(),
              child: Text(l.loadError),
            ),
          Expanded(
            child: provider.loading && rows.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : rows.isEmpty && !provider.hasMore
                ? Center(child: Text(l.noDebts, textAlign: TextAlign.center))
                : NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n.metrics.extentAfter < 250) {
                        provider.load(more: true);
                      }
                      return false;
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 90),
                      itemCount: rows.length + (provider.hasMore ? 1 : 0),
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (_, index) {
                        if (index == rows.length) {
                          return TextButton(
                            onPressed: () => provider.load(more: true),
                            child: Text(l.loadMore),
                          );
                        }
                        final debt = rows[index];
                        final days = debt.overdueDays(DateTime.now());
                        final names = debt.personName.trim().split(
                          RegExp(r'\s+'),
                        );
                        final initials = names
                            .take(2)
                            .map((n) => n.characters.first)
                            .join()
                            .toUpperCase();
                        return Material(
                          color: index.isOdd
                              ? Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLow
                              : Theme.of(context).colorScheme.surface,
                          child: ListTile(
                            leading: CircleAvatar(child: Text(initials)),
                            title: Text(
                              debt.personName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${debt.direction == DebtDirection.lent ? l.lent : l.borrowed}${debt.dueDate == null ? '' : ' · ${days > 0 ? l.debtOverdue(days) : l.debtDue(MaterialLocalizations.of(context).formatCompactDate(debt.dueDate!))}'}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: days > 0
                                        ? Theme.of(context).colorScheme.error
                                        : null,
                                  ),
                                ),
                                if (debt.status == DebtStatus.partial) ...[
                                  LinearProgressIndicator(
                                    value:
                                        (debt.totalDueMinor -
                                            debt.remainingMinor) /
                                        debt.totalDueMinor,
                                  ),
                                  Text(
                                    l.debtPaid(
                                      debtMoney(
                                        context,
                                        debt.totalDueMinor -
                                            debt.remainingMinor,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: Text(
                              '${debt.direction == DebtDirection.lent ? '+' : '−'} ${debtMoney(context, debt.remainingMinor)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () => showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              sheetAnimationStyle: AnimationStyle.noAnimation,
                              builder: (_) => DebtDetail(debt: debt),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class DebtForm extends StatefulWidget {
  final Debt? debt;
  const DebtForm({super.key, this.debt});
  @override
  State<DebtForm> createState() => _DebtFormState();
}

class _DebtFormState extends State<DebtForm> {
  late final TextEditingController _person, _amount, _rate, _note;
  DebtDirection _direction = DebtDirection.lent;
  DateTime? _due;
  int? _wallet;
  bool _interest = false, _saving = false, _failed = false;
  bool get _locked => (widget.debt?.principalPaidMinor ?? 0) > 0;
  int get _minor {
    final n = double.tryParse(_amount.text);
    return n == null || !n.isFinite || n <= 0 || n > 100000000000
        ? 0
        : toMinor(n);
  }

  double get _percent =>
      _interest ? double.tryParse(_rate.text) ?? double.nan : 0;
  bool get _valid =>
      _person.text.trim().isNotEmpty &&
      _minor > 0 &&
      _percent.isFinite &&
      _percent >= 0 &&
      _percent <= 100000 &&
      _wallet != null &&
      context.read<WalletProvider>().wallets.any((w) => w.id == _wallet);
  @override
  void initState() {
    super.initState();
    final d = widget.debt;
    _person = TextEditingController(text: d?.personName ?? '');
    _amount = TextEditingController(
      text: d?.principal.toStringAsFixed(2) ?? '',
    );
    _rate = TextEditingController(text: d?.interestRate.toString() ?? '0');
    _note = TextEditingController(text: d?.note ?? '');
    _direction = d?.direction ?? DebtDirection.lent;
    _due = d?.dueDate;
    _interest = (d?.interestRate ?? 0) > 0;
    _wallet =
        d?.walletId ??
        context.read<WalletProvider>().selectedWalletId ??
        context.read<WalletProvider>().wallets.firstOrNull?.id;
    for (final c in [_person, _amount, _rate, _note]) {
      c.addListener(_changed);
    }
    context.read<DebtProvider>().store.contacts().then<void>((rows) {
      if (mounted) setState(() => _contacts = rows);
    }, onError: (Object _, StackTrace __) {});
  }

  List<Contact> _contacts = [];
  void _changed() {
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in [_person, _amount, _rate, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_valid || _saving) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      final old = widget.debt;
      final due = Debt.totalDue(_minor, _percent);
      await context.read<DebtProvider>().save(
        Debt(
          id: old?.id,
          personName: _person.text,
          direction: _direction,
          principalMinor: _minor,
          interestRate: _percent,
          totalDueMinor: due,
          remainingMinor: old?.remainingMinor ?? due,
          principalPaidMinor: old?.principalPaidMinor ?? 0,
          dueDate: _due,
          note: _note.text.trim(),
          walletId: _wallet!,
          createdAt: old?.createdAt ?? DateTime.now(),
        ),
      );
      if (!mounted) return;
      await refreshDebtMovements(context);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).debtSaved)),
      );
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final wallets = context.watch<WalletProvider>().wallets;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.iou, style: Theme.of(context).textTheme.titleLarge),
            TextField(
              controller: _person,
              decoration: InputDecoration(labelText: l.person),
              enabled: !_saving,
            ),
            if (_contacts.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final c in _contacts)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          label: Text(c.name),
                          onPressed: _saving
                              ? null
                              : () => _person.text = c.name,
                        ),
                      ),
                  ],
                ),
              ),
            DropdownButtonFormField<DebtDirection>(
              initialValue: _direction,
              items: [
                DropdownMenuItem(
                  value: DebtDirection.lent,
                  child: Text(l.lent),
                ),
                DropdownMenuItem(
                  value: DebtDirection.borrowed,
                  child: Text(l.borrowed),
                ),
              ],
              onChanged: _locked || _saving
                  ? null
                  : (v) => setState(() => _direction = v!),
            ),
            TextField(
              controller: _amount,
              enabled: !_locked && !_saving,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l.amount),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.interest),
              value: _interest,
              onChanged: _locked || _saving
                  ? null
                  : (v) => setState(() => _interest = v),
            ),
            if (_interest)
              TextField(
                controller: _rate,
                enabled: !_locked && !_saving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: l.interestRate),
              ),
            Text(
              '${l.totalDue}: ${debtMoney(context, _minor > 0 && _percent.isFinite && _percent >= 0 && _percent <= 100000 ? Debt.totalDue(_minor, _percent) : 0)}',
            ),
            if (_locked) Text(l.debtLocked),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.dueDate),
              subtitle: _due == null
                  ? null
                  : Text(
                      MaterialLocalizations.of(
                        context,
                      ).formatCompactDate(_due!),
                    ),
              trailing: _due == null
                  ? null
                  : IconButton(
                      onPressed: _saving
                          ? null
                          : () => setState(() => _due = null),
                      icon: const Icon(Icons.clear),
                    ),
              onTap: _saving
                  ? null
                  : () async {
                      final day = await showDatePicker(
                        context: context,
                        initialDate: _due ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (mounted && day != null) setState(() => _due = day);
                    },
            ),
            DropdownButtonFormField<int>(
              initialValue: _wallet,
              decoration: InputDecoration(labelText: l.wallet),
              items: [
                for (final w in wallets)
                  DropdownMenuItem(value: w.id, child: Text(w.name)),
              ],
              onChanged: _locked || _saving
                  ? null
                  : (v) => setState(() => _wallet = v),
            ),
            TextField(
              controller: _note,
              enabled: !_saving,
              decoration: InputDecoration(labelText: l.note),
            ),
            if (_failed)
              Text(
                l.debtError,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _valid && !_saving ? _save : null,
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}

class DebtDetail extends StatefulWidget {
  final Debt debt;
  const DebtDetail({super.key, required this.debt});
  @override
  State<DebtDetail> createState() => _DebtDetailState();
}

class _DebtDetailState extends State<DebtDetail> {
  late Future<List<DebtRepayment>> _repayments;
  bool _busy = false, _failed = false;
  @override
  void initState() {
    super.initState();
    _repayments = context.read<DebtProvider>().store.repayments(
      widget.debt.id!,
    );
  }

  Future<bool> _confirm(String title, String body) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(ctx).cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(title),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _perform(Future<void> Function() action, String message) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failed = false;
    });
    try {
      await action();
      if (!mounted) return;
      await refreshDebtMovements(context);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() {
          _failed = true;
          _busy = false;
        });
      }
    }
  }

  Future<void> _repay() async {
    final l = AppLocalizations.of(context);
    final amount = TextEditingController();
    int minor = 0;
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: Text(l.recordRepayment),
          content: TextField(
            controller: amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l.repaymentAmount,
              helperText: debtMoney(context, widget.debt.remainingMinor),
            ),
            onChanged: (v) {
              final n = double.tryParse(v);
              update(
                () => minor =
                    n == null ||
                        !n.isFinite ||
                        n <= 0 ||
                        n > widget.debt.remaining
                    ? 0
                    : toMinor(n),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: minor > 0 && minor <= widget.debt.remainingMinor
                  ? () => Navigator.pop(ctx, minor)
                  : null,
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
    // The dialog's route may still own its field during the closing frame.
    WidgetsBinding.instance.addPostFrameCallback((_) => amount.dispose());
    if (!mounted || result == null) return;
    await _perform(
      () => context.read<DebtProvider>().repay(widget.debt, result),
      l.repaymentRecorded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = widget.debt;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(d.personName, style: Theme.of(context).textTheme.titleLarge),
          Text(
            '${d.direction == DebtDirection.lent ? l.lent : l.borrowed} · ${debtMoney(context, d.remainingMinor)}',
          ),
          Text(
            '${l.recordedAt}: ${DateFormat.yMd(Localizations.localeOf(context).toString()).add_Hms().format(d.createdAt.toLocal())}',
          ),
          if (d.note?.isNotEmpty ?? false) Text(d.note!),
          if (_failed) Text(l.debtError),
          if (d.active) ...[
            TextButton(
              onPressed: _busy
                  ? null
                  : () async {
                      final host = Navigator.of(context).context;
                      Navigator.pop(context);
                      await showDebtForm(host, debt: d);
                    },
              child: Text(l.edit),
            ),
            FilledButton(
              onPressed: _busy ? null : _repay,
              child: Text(l.recordRepayment),
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () async {
                      if (await _confirm(l.markAsPaid, l.paidConfirmation) &&
                          mounted) {
                        await _perform(
                          () => context.read<DebtProvider>().repay(
                            d,
                            d.remainingMinor,
                          ),
                          l.markedAsPaid,
                        );
                      }
                    },
              child: Text(l.markAsPaid),
            ),
            TextButton(
              onPressed: _busy
                  ? null
                  : () async {
                      if (await _confirm(l.archive, l.archiveConfirmation) &&
                          mounted) {
                        await _perform(
                          () => context.read<DebtProvider>().archive(d),
                          l.archived,
                        );
                      }
                    },
              child: Text(l.archive),
            ),
          ],
          TextButton(
            onPressed: _busy
                ? null
                : () async {
                    if (await _confirm(
                          l.debtDelete,
                          l.debtDeleteConfirmation,
                        ) &&
                        mounted) {
                      await _perform(() async {
                        final p = context.read<DebtProvider>();
                        await p.store.delete(d.id!);
                        await p.load();
                      }, l.debtDeleted);
                    }
                  },
            child: Text(l.debtDelete),
          ),
          Flexible(
            child: FutureBuilder<List<DebtRepayment>>(
              future: _repayments,
              builder: (ctx, snap) {
                if (snap.hasError) {
                  return TextButton(
                    onPressed: () => setState(
                      () => _repayments = context
                          .read<DebtProvider>()
                          .store
                          .repayments(d.id!),
                    ),
                    child: Text(l.loadError),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snap.data!.length,
                  itemBuilder: (_, i) {
                    final r = snap.data![i];
                    return ListTile(
                      title: Text(debtMoney(context, r.amountMinor)),
                      subtitle: Text(
                        MaterialLocalizations.of(
                          context,
                        ).formatCompactDate(r.date),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
