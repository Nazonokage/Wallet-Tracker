import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' hide Category; // ← important
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../db/database_helper.dart';
import '../models/transaction.dart';
import '../models/wallet.dart';

/// Shared helper for CSV / XLSX import & export.
/// Export columns: Date, Type, Category, Amount, Remark, Wallet
/// Import is tolerant of missing Wallet column and different casings.
class ImportExportHelper {
  static const List<String> headers = [
    'Date',
    'Type',
    'Category',
    'Amount',
    'Remark',
    'Wallet',
  ];

  // ---------------------------------------------------------------------------
  // EXPORT
  // ---------------------------------------------------------------------------

  /// Returns the full path of the written file, or null on cancel/error.
  static Future<String?> export({
    required List<Transaction> transactions,
    required List<Wallet> wallets,
    required String format, // 'csv' | 'xlsx'
    required String? directoryPath, // from FilePicker.getDirectoryPath()
  }) async {
    if (transactions.isEmpty) return null;
    if (directoryPath == null) return null;

    final walletMap = {for (var w in wallets) w.id: w.name};

    final rows = <List<dynamic>>[
      headers,
    ];

    for (final txn in transactions) {
      rows.add([
        txn.date.toIso8601String(),
        txn.type == TransactionType.income ? 'Income' : 'Expense',
        txn.category?.name ?? '',
        txn.amount,
        txn.remark ?? '',
        walletMap[txn.walletId] ?? 'Cash',
      ]);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'expense_tracker_$timestamp.$format';
    final filePath = p.join(directoryPath, fileName);

    if (format == 'csv') {
      final csvString = const ListToCsvConverter().convert(rows);
      final file = File(filePath);
      await file.writeAsString(csvString);
    } else if (format == 'xlsx') {
      final excel = Excel.createExcel();
      final sheet = excel['Transactions'];
      // Remove the default empty sheet if present
      if (excel.sheets.keys.contains('Sheet1')) {
        excel.delete('Sheet1');
      }

      for (var r = 0; r < rows.length; r++) {
        for (var c = 0; c < rows[r].length; c++) {
          final value = rows[r][c];
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r),
          );
          if (value is num) {
            cell.value = DoubleCellValue(value.toDouble());
          } else {
            cell.value = TextCellValue(value?.toString() ?? '');
          }
        }
      }

      // excel 4.x prefers save(); keep encode() as fallback for compatibility
      final bytes = excel.save() ?? excel.encode();
      if (bytes == null) return null;
      final file = File(filePath);
      await file.writeAsBytes(bytes);
    } else {
      return null;
    }

    return filePath;
  }

  // ---------------------------------------------------------------------------
  // IMPORT
  // ---------------------------------------------------------------------------

  /// Parses a CSV or XLSX file and returns a list of Transactions ready to insert.
  /// Unknown categories become `others`. Missing wallet → Cash.
  /// Throws a descriptive Exception on parse problems.
  static Future<List<Transaction>> parseImportFile(String filePath) async {
    final ext = p.extension(filePath).toLowerCase();
    List<List<dynamic>> rows;

    if (ext == '.csv') {
      final content = await File(filePath).readAsString();
      rows = const CsvToListConverter(eol: '\n').convert(content);
    } else if (ext == '.xlsx' || ext == '.xls') {
      final bytes = await File(filePath).readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables.values.first;
      rows = sheet.rows.map((row) {
        return row.map((cell) {
          final v = cell?.value;
          if (v == null) return null;
          // CellValue subtypes in excel 4.x
          if (v is TextCellValue) return v.value;
          if (v is IntCellValue) return v.value;
          if (v is DoubleCellValue) return v.value;
          if (v is BoolCellValue) return v.value;
          return v.toString();
        }).toList();
      }).toList();
    } else {
      throw Exception('Unsupported file type. Please use .csv or .xlsx');
    }

    if (rows.isEmpty) throw Exception('File is empty');

    // Normalise header row
    final headerRow = rows.first
        .map((e) => e?.toString().trim().toLowerCase() ?? '')
        .toList();
    final dataRows = rows
        .skip(1)
        .where((r) => r.any((c) => c != null && c.toString().trim().isNotEmpty))
        .toList();

    int col(String name) {
      final idx = headerRow.indexOf(name.toLowerCase());
      if (idx == -1) throw Exception('Missing required column: $name');
      return idx;
    }

    // Required columns
    final dateIdx = col('date');
    final typeIdx = col('type');
    final amountIdx = col('amount');

    // Optional
    final categoryIdx = headerRow.indexOf('category');
    final remarkIdx = headerRow.indexOf('remark');
    final walletIdx = headerRow.indexOf('wallet');

    // Load existing wallets so we can map by name
    final existingWallets = await DatabaseHelper().getAllWallets();
    final walletNameToId = {
      for (var w in existingWallets) w.name.toLowerCase(): w.id!,
    };

    final List<Transaction> result = [];

    for (var i = 0; i < dataRows.length; i++) {
      final row = dataRows[i];
      try {
        // Date
        final dateRaw = row[dateIdx]?.toString().trim() ?? '';
        DateTime date;
        try {
          date = DateTime.parse(dateRaw);
        } catch (_) {
          // Try common formats
          date =
              DateTime.tryParse(dateRaw.replaceAll('/', '-')) ?? DateTime.now();
        }

        // Type
        final typeStr = (row[typeIdx]?.toString() ?? '').trim().toLowerCase();
        final type = typeStr.contains('income') || typeStr == 'in'
            ? TransactionType.income
            : TransactionType.expense;

        // Amount
        final amountRaw = row[amountIdx]?.toString().replaceAll(',', '') ?? '0';
        final amount = double.tryParse(amountRaw) ?? 0.0;
        if (amount <= 0) continue; // skip zero / invalid

        // Category
        Category? category;
        if (type == TransactionType.expense && categoryIdx != -1) {
          final catStr =
              (row[categoryIdx]?.toString() ?? '').trim().toLowerCase();
          category = _parseCategory(catStr);
        }

        // Remark
        final remark = remarkIdx != -1
            ? (row[remarkIdx]?.toString().trim().isEmpty == true
                ? null
                : row[remarkIdx]?.toString().trim())
            : null;

        // Wallet
        int walletId = Wallet.cashWalletId;
        if (walletIdx != -1) {
          final walletName =
              (row[walletIdx]?.toString() ?? '').trim().toLowerCase();
          if (walletName.isNotEmpty && walletNameToId.containsKey(walletName)) {
            walletId = walletNameToId[walletName]!;
          }
        }

        result.add(Transaction(
          type: type,
          amount: amount,
          category: category,
          remark: remark,
          date: date,
          walletId: walletId,
        ));
      } catch (e) {
        debugPrint('Skipping row ${i + 2}: $e');
      }
    }

    return result;
  }

  static Category _parseCategory(String raw) {
    final s = raw.toLowerCase().trim();
    if (s.contains('food') || s == '🍔') return Category.food;
    if (s.contains('commute') || s.contains('transport') || s == '🚌') {
      return Category.commute;
    }
    if (s.contains('bill') || s == '📄') return Category.bills;
    if (s.contains('shop') || s == '🛍️') return Category.shopping;
    return Category.others;
  }

  /// Convenience: write a temp file (used when we only have bytes from picker on some platforms)
  static Future<String> writeTempFile(List<int> bytes, String extension) async {
    final dir = await getTemporaryDirectory();
    final path = p.join(
        dir.path, 'import_${DateTime.now().millisecondsSinceEpoch}.$extension');
    await File(path).writeAsBytes(bytes);
    return path;
  }
}
