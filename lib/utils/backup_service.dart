import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' as sql;
import '../db/database_helper.dart';
import '../models/debt.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';
import 'import_export_helper.dart';

// All encoding/decoding happens on an isolate, only when explicitly requested.
List<List<String>> _readRows(Map<String, Object?> args) {
  final path = args['path'] as String;
  if (p.extension(path).toLowerCase() == '.csv') {
    return const CsvToListConverter(shouldParseNumbers: false, eol: '\n')
        .convert(File(path).readAsStringSync().replaceAll('\r\n', '\n'))
        .map((r) => r.map((c) => c.toString()).toList())
        .toList();
  }
  final workbook = Excel.decodeBytes(File(path).readAsBytesSync());
  final sheet = workbook.tables['WalletBackup'];
  if (sheet == null) return [];
  return sheet.rows
      .map((r) => r.map((c) => c?.value?.toString() ?? '').toList())
      .toList();
}

String _writeBackup(Map<String, Object?> args) {
  final path = args['path'] as String;
  final data = args['data'] as Map<String, List<Map<String, Object?>>>;
  final rows = <List<String>>[
    ['RecordType', 'Payload'],
    ['version', '2'],
  ];
  for (final entry in data.entries) {
    for (final row in entry.value) {
      rows.add([entry.key, jsonEncode(row)]);
    }
  }
  if (p.extension(path) == '.csv') {
    File(path).writeAsStringSync(const ListToCsvConverter().convert(rows));
  } else {
    final book = Excel.createExcel();
    final sheet = book['WalletBackup'];
    book.delete('Sheet1');
    for (final row in rows) {
      sheet.appendRow(row.map(TextCellValue.new).toList());
    }
    File(path).writeAsBytesSync(book.encode()!);
  }
  return path;
}

class BackupService {
  static Future<String> export(
    String directory,
    String format, {
    sql.Database? database,
  }) async {
    final db = database ?? await DatabaseHelper().database;
    // A consistent snapshot, even if a transaction changes during export.
    final data = await db.transaction(
      (tx) async => <String, List<Map<String, Object?>>>{
        'wallets': await tx.query('wallets', where: 'is_system = 0'),
        'debts': await tx.query('debts'),
        'debt_repayments': await tx.query('debt_repayments'),
        'transactions': await tx.query('transactions'),
        'contacts': await tx.query('contacts'),
      },
    );
    final path = p.join(
      directory,
      'wallet_backup_${DateTime.now().millisecondsSinceEpoch}.$format',
    );
    return compute(_writeBackup, {'path': path, 'data': data});
  }

  static Future<int> import(String path, {sql.Database? database}) async {
    final rows = await compute(_readRows, {'path': path});
    final db = database ?? await DatabaseHelper().database;
    if (rows.isEmpty || rows.first.first != 'RecordType') {
      final wallets = (await db.query(
        'wallets',
        where: 'is_system = 0',
      )).map(Wallet.fromMap).toList();
      final transactions = await ImportExportHelper.parseImportFile(
        path,
        wallets: wallets,
      );
      await db.transaction((tx) async {
        for (final t in transactions) {
          await tx.insert('transactions', t.toMap()..remove('id'));
        }
      });
      return transactions.length;
    }
    if (rows.length < 2 ||
        rows[1].length < 2 ||
        rows[1][0] != 'version' ||
        rows[1][1] != '2') {
      throw const FormatException('Unsupported backup');
    }
    final data = <String, List<Map<String, Object?>>>{
      for (final t in [
        'wallets',
        'debts',
        'debt_repayments',
        'transactions',
        'contacts',
      ])
        t: [],
    };
    for (final row in rows.skip(2)) {
      if (row.every((c) => c.trim().isEmpty)) continue;
      if (row.length != 2 || !data.containsKey(row.first)) {
        throw const FormatException('Invalid record');
      }
      data[row.first]!.add(
        Map<String, Object?>.from(jsonDecode(row[1]) as Map),
      );
    }
    return db.transaction((tx) async {
      final walletIds = <int, int>{},
          debtIds = <int, int>{},
          repaymentIds = <int, int>{};
      for (final row in data['wallets']!) {
        final oldId = row['id'] as int;
        if (walletIds.containsKey(oldId) || row['is_system'] != 0) {
          throw const FormatException('Invalid wallet');
        }
        final existing = await tx.query(
          'wallets',
          where: 'name = ? AND is_system = 0',
          whereArgs: [row['name']],
          limit: 1,
        );
        walletIds[oldId] = existing.isNotEmpty
            ? existing.single['id'] as int
            : await tx.insert('wallets', Map.of(row)..remove('id'));
        if (existing.isNotEmpty) {
          await tx.rawUpdate(
            'UPDATE wallets SET initialBalance = initialBalance + ? WHERE id = ?',
            [row['initialBalance'], walletIds[oldId]],
          );
        }
      }
      for (final row in data['debts']!) {
        final debt = Debt.fromMap(row);
        if (debtIds.containsKey(debt.id) ||
            debt.personName.trim().isEmpty ||
            debt.totalDueMinor !=
                Debt.totalDue(debt.principalMinor, debt.interestRate) ||
            debt.remainingMinor < 0 ||
            debt.remainingMinor > debt.totalDueMinor ||
            debt.principalPaidMinor < 0 ||
            debt.principalPaidMinor > debt.principalMinor ||
            (debt.remainingMinor == 0 && debt.status != DebtStatus.archived)) {
          throw const FormatException('Invalid debt');
        }
        final mapped = walletIds[debt.walletId];
        if (mapped == null) throw const FormatException('Missing wallet');
        debtIds[debt.id!] = await tx.insert(
          'debts',
          Map.of(row)
            ..remove('id')
            ..['wallet_id'] = mapped,
        );
      }
      for (final row in data['debt_repayments']!) {
        final mapped = debtIds[row['debt_id']];
        final id = row['id'] as int;
        if (mapped == null ||
            repaymentIds.containsKey(id) ||
            (row['amount_minor'] as int) <= 0) {
          throw const FormatException('Invalid repayment');
        }
        repaymentIds[id] = await tx.insert(
          'debt_repayments',
          Map.of(row)
            ..remove('id')
            ..['debt_id'] = mapped,
        );
      }
      for (final row in data['transactions']!) {
        final t = Transaction.fromMap(row);
        final wallet = walletIds[t.walletId];
        if (wallet == null ||
            !t.amount.isFinite ||
            t.amount <= 0 ||
            (t.debtId != null && !debtIds.containsKey(t.debtId)) ||
            (t.debtRepaymentId != null &&
                !repaymentIds.containsKey(t.debtRepaymentId))) {
          throw const FormatException('Invalid transaction');
        }
        await tx.insert(
          'transactions',
          t.toMap()
            ..remove('id')
            ..['wallet_id'] = wallet
            ..['debt_id'] = debtIds[t.debtId]
            ..['debt_repayment_id'] = repaymentIds[t.debtRepaymentId],
        );
      }
      for (final row in data['contacts']!) {
        await tx.rawInsert(
          'INSERT INTO contacts(name,last_used) VALUES(?,?) ON CONFLICT(name) DO UPDATE SET last_used=MAX(COALESCE(last_used,\'\'),excluded.last_used)',
          [row['name'], row['last_used']],
        );
      }
      for (final id in debtIds.values) {
        final debt = Debt.fromMap(
          (await tx.query('debts', where: 'id = ?', whereArgs: [id])).single,
        );
        final paid =
            (await tx.rawQuery(
                  'SELECT COALESCE(SUM(amount_minor),0) AS paid FROM debt_repayments WHERE debt_id = ?',
                  [id],
                )).single['paid']
                as int;
        if (debt.remainingMinor != debt.totalDueMinor - paid ||
            debt.principalPaidMinor !=
                (paid < debt.principalMinor ? paid : debt.principalMinor)) {
          throw const FormatException('Inconsistent repayment totals');
        }
      }
      return data['transactions']!.length;
    });
  }
}
