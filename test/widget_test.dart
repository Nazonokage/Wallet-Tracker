import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/widgets/animated_count_text.dart';
import 'package:expense_tracker/widgets/particle_background.dart';
import 'package:expense_tracker/widgets/fade_in_slide.dart';

void main() {
  testWidgets('Content and balances render immediately without tickers',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: ParticleBackground(
        child: FadeInSlide(
          delayMilliseconds: 500,
          child: AnimatedCountText(value: 1234.50),
        ),
      ),
    ));
    expect(find.text('1,234.50'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(FadeInSlide),
            matching: find.byType(FadeTransition)),
        findsNothing);
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(const MaterialApp(
      home: AnimatedCountText(value: 2000),
    ));
    expect(find.text('2,000.00'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
