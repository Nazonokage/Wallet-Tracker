import 'package:flutter/material.dart';

/// Compatibility wrapper: decorative particles are disabled for performance.
class ParticleBackground extends StatelessWidget {
  final Widget child;
  const ParticleBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}

class GradientBackground extends StatelessWidget {
  final List<Color> colors;
  final Widget? child;
  const GradientBackground({
    super.key,
    this.colors = const [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
    this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        )),
        child: child,
      );
}
