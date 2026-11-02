import 'package:flutter/foundation.dart';
import '../db/debt_store.dart';
import '../models/debt.dart';

class DebtProvider extends ChangeNotifier {
  final DebtStore store;
  DebtProvider({DebtStore? store}) : store = store ?? DebtStore();
  List<Debt> debts = [];
  List<Contact> contacts = [];
  Map<DebtDirection, int> totals = {};
  DebtStatus? status;
  bool loading = false, hasMore = false;
  bool failed = false;
  int _generation = 0;
  Future<void>? _summaryLoad;

  Future<void> loadSummary() => _summaryLoad ??= _loadSummary();
  Future<void> _loadSummary() async {
    try {
      totals = await store.totals();
      notifyListeners();
    } catch (_) {
      failed = true;
      notifyListeners();
    } finally {
      _summaryLoad = null;
    }
  }

  Future<void> load({
    DebtStatus? filter,
    bool all = false,
    bool more = false,
  }) async {
    if (more && (loading || !hasMore)) return;
    final generation = ++_generation;
    status = all ? null : filter ?? status;
    loading = true;
    failed = false;
    if (!more) debts = [];
    notifyListeners();
    try {
      final rows = await store.list(
        status,
        beforeId: more && debts.isNotEmpty ? debts.last.id : null,
      );
      if (generation != _generation) return;
      debts = more ? [...debts, ...rows] : rows;
      hasMore = rows.length == 30;
      if (!more) {
        final summary = await store.totals();
        final people = await store.contacts();
        if (generation != _generation) return;
        totals = summary;
        contacts = people;
      }
    } catch (_) {
      if (generation == _generation) failed = true;
    } finally {
      if (generation == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> save(Debt debt) async {
    await store.save(debt);
    await load();
  }

  Future<void> repay(Debt debt, int amount, {String? note}) async {
    await store.repay(debt.id!, amount, note: note);
    await load();
  }

  Future<void> archive(Debt debt) async {
    await store.archive(debt.id!);
    await load();
  }
}
