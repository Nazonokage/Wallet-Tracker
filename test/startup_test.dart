import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/providers/transaction_provider.dart';
import 'package:expense_tracker/providers/wallet_provider.dart';
import 'package:expense_tracker/utils/first_run_guide.dart';

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
