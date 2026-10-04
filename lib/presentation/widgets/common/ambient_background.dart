import 'dart:math';
import 'package:flutter/material.dart';

import '../../../data/models/game_mode_model.dart';

/// Ambient dynamic theme particle canvas background widget providing
/// unique particle visuals for each active symbol theme (Cyberpunk, Space, Fire&Ice, etc.).
class AmbientParticleBackground extends StatefulWidget {
  final Widget child;
  final bool enableParticles;
  final SymbolTheme? symbolTheme;

  const AmbientParticleBackground({
    super.key,
    required this.child,
    this.enableParticles = true,
    this.symbolTheme,
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

  @override
  void didUpdateWidget(AmbientParticleBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbolTheme?.id != widget.symbolTheme?.id) {
      _initParticles();
    }
  }

  void _initParticles() {
    _particles.clear();
    final themeId = widget.symbolTheme?.id ?? 'classic';

    int count = 30;
    for (int i = 0; i < count; i++) {
      _particles.add(
        _Particle.createForTheme(
          themeId: themeId,
          random: _random,
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
                  themeId: widget.symbolTheme?.id ?? 'classic',
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
  bool isSquare;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedX,
    required this.speedY,
    required this.opacity,
    required this.color,
    this.isSquare = false,
  });

  factory _Particle.createForTheme({
    required String themeId,
    required Random random,
  }) {
    double x = random.nextDouble();
    double y = random.nextDouble();

    if (themeId == 'cyberpunk') {
      return _Particle(
        x: x,
        y: y,
        radius: random.nextDouble() * 3 + 2,
        speedX: 0,
        speedY: random.nextDouble() * 0.002 + 0.001,
        opacity: random.nextDouble() * 0.6 + 0.2,
        color: random.nextBool()
            ? const Color(0xFF00E5FF)
            : const Color(0xFFFF007F),
        isSquare: true,
      );
    } else if (themeId == 'elemental') {
      bool isFire = random.nextBool();
      return _Particle(
        x: x,
        y: y,
        radius: random.nextDouble() * 8 + 4,
        speedX: (random.nextDouble() - 0.5) * 0.001,
        speedY: isFire
            ? -random.nextDouble() * 0.0015 - 0.0005
            : random.nextDouble() * 0.001 + 0.0003,
        opacity: random.nextDouble() * 0.4 + 0.1,
        color: isFire ? const Color(0xFFFF5722) : const Color(0xFF03A9F4),
      );
    } else if (themeId == 'scifi') {
      return _Particle(
        x: x,
        y: y,
        radius: random.nextDouble() * 3 + 1,
        speedX: (random.nextDouble() - 0.5) * 0.0004,
        speedY: (random.nextDouble() - 0.5) * 0.0004,
        opacity: random.nextDouble() * 0.7 + 0.2,
        color: random.nextBool()
            ? const Color(0xFF7C4DFF)
            : const Color(0xFF00E676),
      );
    } else if (themeId == 'royal') {
      return _Particle(
        x: x,
        y: y,
        radius: random.nextDouble() * 5 + 3,
        speedX: (random.nextDouble() - 0.5) * 0.0008,
        speedY: (random.nextDouble() - 0.5) * 0.0008,
        opacity: random.nextDouble() * 0.5 + 0.2,
        color: random.nextBool()
            ? const Color(0xFFFFD700)
            : const Color(0xFF00B0FF),
      );
    }

    // Classic / Fallback
    return _Particle(
      x: x,
      y: y,
      radius: random.nextDouble() * 25 + 10,
      speedX: (random.nextDouble() - 0.5) * 0.0008,
      speedY: (random.nextDouble() - 0.5) * 0.0008,
      opacity: random.nextDouble() * 0.25 + 0.05,
      color: random.nextBool()
          ? const Color(0xFF6750A4)
          : const Color(0xFFE8873A),
    );
  }

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
  final String themeId;
  final bool isDark;

  _ParticlePainter({
    required this.particles,
    required this.primaryColor,
    required this.secondaryColor,
    required this.themeId,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      p.update();

      final center = Offset(p.x * size.width, p.y * size.height);

      if (p.isSquare) {
        final paint = Paint()
          ..color = p.color.withValues(alpha: p.opacity)
          ..style = PaintingStyle.fill;
        canvas.drawRect(
          Rect.fromCenter(center: center, width: p.radius, height: p.radius * 2),
          paint,
        );
      } else {
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
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
