import 'package:sqflite/sqflite.dart' as sql;
import '../models/transaction.dart';

class TransactionQueries {
  static Future<List<Transaction>> page(
    sql.Database db, {
    int? walletId,
    Category? category,
    String search = '',
    Transaction? before,
  }) async {
    final conditions = <String>[];
    final args = <Object?>[];
    if (walletId != null) {
      conditions.add('wallet_id = ?');
      args.add(walletId);
    }
    if (category != null) {
      conditions.add('category = ?');
      args.add(category.index);
    }
    if (search.isNotEmpty) {
      conditions.add("instr(lower(COALESCE(remark,'')), lower(?)) > 0");
      args.add(search);
    }
    if (before != null) {
      conditions.add('(date < ? OR (date = ? AND id < ?))');
      args.addAll([
        before.date.toIso8601String(),
        before.date.toIso8601String(),
        before.id,
      ]);
    }
    return (await db.query(
      'transactions',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args,
      orderBy: 'date DESC, id DESC',
      limit: 50,
    )).map(Transaction.fromMap).toList();
  }

  static Future<List<Map<String, Object?>>> totals(
    sql.Database db,
    DateTime now,
  ) {
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(Duration(days: now.weekday - 1));
    return db.rawQuery(
      '''SELECT wallet_id,
      SUM(CASE WHEN type='income' THEN amount ELSE -amount END) AS balance,
      SUM(CASE WHEN type='income' AND debt_id IS NULL THEN amount ELSE 0 END) AS income,
      SUM(CASE WHEN type='expense' AND debt_id IS NULL THEN amount ELSE 0 END) AS expense,
      SUM(CASE WHEN type='income' AND debt_id IS NULL AND date >= ? AND date < ? THEN amount ELSE 0 END) AS weekly_income,
      SUM(CASE WHEN type='expense' AND debt_id IS NULL AND date >= ? AND date < ? THEN amount ELSE 0 END) AS weekly_expense
      FROM transactions GROUP BY wallet_id''',
      [
        start.toIso8601String(),
        start.add(const Duration(days: 7)).toIso8601String(),
        start.toIso8601String(),
        start.add(const Duration(days: 7)).toIso8601String(),
      ],
    );
  }

  static Future<Map<Category, double>> categories(
    sql.Database db, {
    DateTime? start,
    DateTime? end,
  }) async {
    final rows = await db.rawQuery(
      '''SELECT category, SUM(amount) AS total FROM transactions
      WHERE type='expense' AND debt_id IS NULL ${start == null ? '' : 'AND date >= ?'}
      ${end == null ? '' : 'AND date < ?'} GROUP BY category''',
      [
        if (start != null) start.toIso8601String(),
        if (end != null) end.toIso8601String(),
      ],
    );
    final result = <Category, double>{};
    for (final r in rows) {
      final c = r['category'] as int?;
      final category = c == null ? Category.others : Category.values[c];
      result[category] =
          (result[category] ?? 0) + (r['total'] as num).toDouble();
    }
    return result;
  }
}
