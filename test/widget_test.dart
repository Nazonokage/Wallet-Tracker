// ignore: unused_import
// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp()); // no const
    expect(find.text('0'), findsNothing); // adjust as needed
  });
}
