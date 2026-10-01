import 'dart:math';
import 'package:flutter/material.dart';

class VictoryConfettiWidget extends StatefulWidget {
  final bool isPlaying;

  const VictoryConfettiWidget({super.key, required this.isPlaying});

  @override
  State<VictoryConfettiWidget> createState() => _VictoryConfettiWidgetState();
}

class _VictoryConfettiWidgetState extends State<VictoryConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {
          for (final particle in _particles) {
            particle.update();
          }
        });
      });

    if (widget.isPlaying) {
      _spawnParticles();
      _controller.forward(from: 0);
    }
  }

  @override
  void didUpdateWidget(VictoryConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _spawnParticles();
      _controller.forward(from: 0);
    }
  }

  void _spawnParticles() {
    _particles.clear();
    final colors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.amber,
      Colors.purpleAccent,
      Colors.greenAccent,
      Colors.orangeAccent,
    ];

    for (int i = 0; i < 70; i++) {
      _particles.add(
        _ConfettiParticle(
          x: 0.5 + (_random.nextDouble() - 0.5) * 0.4,
          y: 0.4,
          vx: (_random.nextDouble() - 0.5) * 0.03,
          vy: -_random.nextDouble() * 0.02 - 0.01,
          size: _random.nextDouble() * 8 + 6,
          color: colors[_random.nextInt(colors.length)],
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
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
    if (!widget.isPlaying && !_controller.isAnimating) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        size: Size.infinite,
        painter: _ConfettiPainter(_particles, _controller.value),
      ),
    );
  }
}

class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;
  double rotation;
  double rotationSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.rotation,
    required this.rotationSpeed,
  });

  void update() {
    x += vx;
    y += vy;
    vy += 0.0008; // gravity
    rotation += rotationSpeed;
  }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      final px = particle.x * size.width;
      final py = particle.y * size.height;

      canvas.translate(px, py);
      canvas.rotate(particle.rotation);

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
