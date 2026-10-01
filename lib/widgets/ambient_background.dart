import 'dart:math';
import 'package:flutter/material.dart';

/// Ambient animated floating particle & radial mesh background widget
/// providing modern visual polish for splash, home, and game screens.
class AmbientParticleBackground extends StatefulWidget {
  final Widget child;
  final bool enableParticles;

  const AmbientParticleBackground({
    super.key,
    required this.child,
    this.enableParticles = true,
  });

  @override
  State<AmbientParticleBackground> createState() =>
      _AmbientParticleBackgroundState();
}

class _AmbientParticleBackgroundState extends State<AmbientParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _initParticles();
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < 25; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          radius: _random.nextDouble() * 30 + 10,
          speedX: (_random.nextDouble() - 0.5) * 0.0008,
          speedY: (_random.nextDouble() - 0.5) * 0.0008,
          opacity: _random.nextDouble() * 0.25 + 0.05,
          color: _random.nextBool()
              ? const Color(0xFF6750A4)
              : const Color(0xFFE8873A),
        ),
      );
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
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Background Base Gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF0F0C1B),
                      const Color(0xFF19122C),
                      const Color(0xFF141218),
                    ]
                  : [
                      const Color(0xFFF8F6FF),
                      const Color(0xFFEEECFA),
                      const Color(0xFFF3F0FA),
                    ],
            ),
          ),
        ),

        // Animated Particle Canvas
        if (widget.enableParticles)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _ParticlePainter(
                  particles: _particles,
                  primaryColor: colorScheme.primary,
                  secondaryColor: colorScheme.tertiary,
                  isDark: isDark,
                ),
              );
            },
          ),

        // Screen Content
        widget.child,
      ],
    );
  }
}

class _Particle {
  double x;
  double y;
  double radius;
  double speedX;
  double speedY;
  double opacity;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedX,
    required this.speedY,
    required this.opacity,
    required this.color,
  });

  void update() {
    x += speedX;
    y += speedY;

    if (x < 0) x = 1;
    if (x > 1) x = 0;
    if (y < 0) y = 1;
    if (y > 1) y = 0;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDark;

  _ParticlePainter({
    required this.particles,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      p.update();

      final center = Offset(p.x * size.width, p.y * size.height);
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            p.color.withValues(alpha: p.opacity),
            p.color.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: p.radius));

      canvas.drawCircle(center, p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
