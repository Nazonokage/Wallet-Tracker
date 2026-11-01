import 'package:flutter/material.dart';

/// Shows content immediately, retaining the existing call-site API.
class FadeInSlide extends StatelessWidget {
  final Widget child;
  final int delayMilliseconds;
  final Duration duration;
  final double slideOffset;

  const FadeInSlide({
    super.key,
    required this.child,
    this.delayMilliseconds = 0,
    this.duration = Duration.zero,
    this.slideOffset = 0,
  });

  @override
  Widget build(BuildContext context) => child;
}
