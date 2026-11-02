import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/providers/wallet_provider.dart';
import 'package:expense_tracker/utils/first_run_guide.dart';
import 'package:expense_tracker/providers/settings_provider.dart';

class _Transactions extends TransactionProvider {
  int loads = 0;
  @override
  Future<void> loadTransactions({bool refreshTotals = true}) async {
    loads++;
  }
}

class _Wallets extends WalletProvider {
  int loads = 0;
  @override
  Future<void> loadWallets() async {
    loads++;
  }
}

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'Refreshed dashboard and settings fit 320px in ${dark ? 'dark' : 'light'}',
      (tester) async {
        tester.view.physicalSize = const Size(320, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({
          FirstRunGuide.key: true,
          'darkMode': dark,
        });
        final settings = SettingsProvider();
        await settings.loadSettings();
        final boundaryKey = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundaryKey,
            child: MyApp(
              settings: settings,
              transactions: _Transactions(),
              wallets: _Wallets(),
              dataReady: Future<void>.value(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final folder = Directory('build/ui-review');
          await folder.create(recursive: true);
          await File(
            '${folder.path}/settings-${dark ? 'dark' : 'light'}.png',
          ).writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
  testWidgets('First frame does not wait for data or restart startup reads', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({FirstRunGuide.key: true});
    final dataReady = Completer<void>();
    final transactions = _Transactions();
    final wallets = _Wallets();
    await tester.pumpWidget(
      MyApp(
        transactions: transactions,
        wallets: wallets,
        dataReady: dataReady.future,
      ),
    );
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    final navigation = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(navigation.currentIndex, 1);
    expect(navigation.items[1].label, 'Dashboard');
    expect(navigation.items.length, 4);
    expect(transactions.loads, 0);
    expect(wallets.loads, 0);
    dataReady.complete();
    await tester.pumpAndSettle();
    expect(transactions.loads, 0);
    expect(wallets.loads, 0);

    // Brief focus loss (e.g. notification shade) should not scan history again.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(transactions.loads, 0);
    // Returning from the background still refreshes dates and totals.
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(transactions.loads, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
