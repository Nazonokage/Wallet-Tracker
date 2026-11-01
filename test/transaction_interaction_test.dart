import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/models/wallet.dart';
import 'package:expense_tracker/providers/settings_provider.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/providers/wallet_provider.dart';
import 'package:expense_tracker/screens/dashboard_screen.dart';
import 'package:expense_tracker/widgets/amount_text_field.dart';
import 'package:expense_tracker/widgets/income_modal.dart';
import 'package:expense_tracker/widgets/expense_modal.dart';
import 'package:expense_tracker/widgets/transaction_list_item.dart';
import 'package:expense_tracker/widgets/transaction_details.dart';

class _Wallets extends WalletProvider {
  @override
  List<Wallet> get wallets => [Wallet(id: 1, name: 'Cash')];
}

class _Transactions extends TransactionProvider {
  List<Transaction> rows = [
    Transaction(
      id: 1,
      type: TransactionType.income,
      amount: 150,
      remark: 'Salary',
      date: DateTime(2026, 11, 2, 13, 45, 6),
    ),
    Transaction(
      id: 2,
      type: TransactionType.expense,
      amount: 20,
      remark: 'Lunch',
      date: DateTime(2026, 11, 2, 12),
    ),
  ];
  Transaction? deleted;
  @override
  List<Transaction> get filteredTransactions => rows;
  @override
  Future<void> updateTransaction(Transaction transaction) async {
    rows = [
      for (final row in rows) row.id == transaction.id ? transaction : row,
    ];
    notifyListeners();
  }

  @override
  Future<void> softDelete(int id) async {
    deleted = rows.firstWhere((r) => r.id == id);
    rows = rows.where((r) => r.id != id).toList();
    notifyListeners();
  }

  @override
  Future<void> undoDelete() async {
    rows = [deleted!, ...rows];
    notifyListeners();
  }
}

Widget _app(Widget home, {_Transactions? transactions}) => MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
    ChangeNotifierProvider<WalletProvider>(create: (_) => _Wallets()),
    ChangeNotifierProvider<TransactionProvider>(
      create: (_) => transactions ?? _Transactions(),
    ),
  ],
  child: MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  ),
);

void main() {
  testWidgets(
    'Debt-managed record opens its debt instead of editing a movement',
    (tester) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: TransactionDetails(
              transaction: Transaction(
                id: 1,
                debtRepaymentId: 8,
                type: TransactionType.income,
                amount: 5,
                date: DateTime(2026),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Open debt'), findsOneWidget);
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Delete'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Alternating records open timestamp, edit, confirm delete and undo',
    (tester) async {
      tester.view.physicalSize = const Size(400, 850);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final transactions = _Transactions();
      await tester.pumpWidget(
        _app(const DashboardScreen(), transactions: transactions),
      );
      await tester.pumpAndSettle();
      final materials = find.descendant(
        of: find.byType(TransactionListItem),
        matching: find.byType(Material),
      );
      expect(
        tester.widget<Material>(materials.at(0)).color,
        isNot(tester.widget<Material>(materials.at(1)).color),
      );
      await tester.tap(find.text('Salary'));
      await tester.pumpAndSettle();
      expect(find.text('Record details'), findsOneWidget);
      expect(find.textContaining('13:45:06'), findsOneWidget);
      expect(find.text('Cash'), findsWidgets);
      await tester.tap(find.text('Edit').last);
      await tester.pumpAndSettle();
      expect(find.byType(IncomeModal), findsOneWidget);
      final amount = find.descendant(
        of: find.byType(AmountTextField),
        matching: find.byType(TextField),
      );
      await tester.enterText(amount, '250');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(transactions.rows.first.amount, 250);
      await tester.tap(find.text('Salary'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(find.text('Delete Transaction?'), findsOneWidget);
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(transactions.rows.length, 1);
      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();
      expect(transactions.rows.length, 2);
      expect(tester.takeException(), isNull);
    },
  );
  for (final income in [true, false]) {
    testWidgets(
      '${income ? 'Income' : 'Expense'} focuses numeric keyboard and fits keyboard inset',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpWidget(
          _app(
            Scaffold(
              body: Dialog(
                child: income
                    ? IncomeModal(onSave: (_) {})
                    : ExpenseModal(onSave: (_) {}),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final fields = tester.widgetList<EditableText>(
          find.byType(EditableText),
        );
        expect(fields.first.focusNode.hasFocus, isTrue);
        expect(
          fields.first.keyboardType,
          const TextInputType.numberWithOptions(decimal: true),
        );
        expect(tester.testTextInput.isVisible, isTrue);
        tester.view.viewInsets = const FakeViewPadding(bottom: 260);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
