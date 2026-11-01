import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/db/debt_store.dart';
import 'package:expense_tracker/l10n/app_localizations.dart';
import 'package:expense_tracker/models/debt.dart';
import 'package:expense_tracker/providers/debt_provider.dart';
import 'package:expense_tracker/providers/settings_provider.dart';
import 'package:expense_tracker/screens/debts_screen.dart';

class _Store extends DebtStore {
  @override
  Future<List<Debt>> list(DebtStatus status, {int? beforeId}) async => [
    Debt(
      id: 1,
      personName: 'Juan Dela Cruz',
      direction: DebtDirection.lent,
      principalMinor: 100000,
      totalDueMinor: 100000,
      remainingMinor: 50000,
      principalPaidMinor: 50000,
      walletId: 1,
      createdAt: DateTime(2026),
      dueDate: DateTime(2026),
      status: DebtStatus.partial,
    ),
  ];
  @override
  Future<Map<DebtDirection, int>> totals() async => {DebtDirection.lent: 50000};
  @override
  Future<List<Contact>> contacts() async => [];
  @override
  Future<List<DebtRepayment>> repayments(int id) async => [];
}

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('Debt list and detail fit small screen in ${brightness.name}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => DebtProvider(store: _Store()),
            ),
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ],
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: brightness == Brightness.dark
                    ? Colors.purple
                    : Colors.teal,
                brightness: brightness,
              ),
            ),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const DebtsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Juan Dela Cruz'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Juan Dela Cruz'));
      await tester.pumpAndSettle();
      expect(find.text('Record repayment'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
