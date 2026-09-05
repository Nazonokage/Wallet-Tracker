import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  final Widget child;

  const ParticleBackground({super.key, required this.child});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    for (int i = 0; i < 15; i++) {
      _particles.add(_Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: _random.nextDouble() * 25 + 15,
        speed: _random.nextDouble() * 0.08 + 0.02,
        opacity: _random.nextDouble() * 0.12 + 0.04,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: _ParticlePainter(
                particles: _particles,
                progress: _controller.value,
                color: primaryColor,
                isDark: isDark,
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  double radius;
  double speed;
  double opacity;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;
  final bool isDark;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in particles) {
      final currentY = (p.y - progress * p.speed) % 1.0;
      final offset = Offset(p.x * size.width, currentY * size.height);

      final paint = Paint()
        ..color = color.withValues(
            alpha: isDark ? p.opacity * 0.6 : p.opacity * 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(offset, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: child,
    );
  }
}
