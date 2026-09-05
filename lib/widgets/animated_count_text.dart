import 'package:flutter/material.dart';
import '../utils/formatter.dart';

class AnimatedCountText extends StatelessWidget {
  final double value;
  final String prefix;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCountText({
    super.key,
    required this.value,
    this.prefix = '',
    this.style,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return Text(
          '$prefix${formatAmount(animatedValue)}',
          style: style,
        );
      },
    );
  }
}
