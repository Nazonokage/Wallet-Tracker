import 'package:flutter/material.dart';
import '../utils/formatter.dart';

/// Displays balances immediately without a count-up ticker.
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
    this.duration = Duration.zero,
  });

  @override
  Widget build(BuildContext context) =>
      Text('$prefix${formatAmount(value)}', style: style);
}
