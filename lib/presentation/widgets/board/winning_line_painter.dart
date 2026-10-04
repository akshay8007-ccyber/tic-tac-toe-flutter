import 'dart:math';
import 'package:flutter/material.dart';

/// Animated neon line overlay drawn over winning cell combinations.
class WinningLinePainterWidget extends StatefulWidget {
  final List<int> winningLine;
  final Color lineColor;

  const WinningLinePainterWidget({
    super.key,
    required this.winningLine,
    required this.lineColor,
  });

  @override
  State<WinningLinePainterWidget> createState() =>
      _WinningLinePainterWidgetState();
}

class _WinningLinePainterWidgetState extends State<WinningLinePainterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(WinningLinePainterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.winningLine != widget.winningLine) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _WinningLinePainter(
            winningIndices: widget.winningLine,
            progress: _progressAnimation.value,
            lineColor: widget.lineColor,
          ),
        );
      },
    );
  }
}

class _WinningLinePainter extends CustomPainter {
  final List<int> winningIndices;
  final double progress;
  final Color lineColor;

  _WinningLinePainter({
    required this.winningIndices,
    required this.progress,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (winningIndices.length < 3) return;

    final cellWidth = size.width / 3;
    final cellHeight = size.height / 3;

    final startCell = winningIndices.first;
    final endCell = winningIndices.last;

    final startX = (startCell % 3) * cellWidth + cellWidth / 2;
    final startY = (startCell ~/ 3) * cellHeight + cellHeight / 2;

    final endX = (endCell % 3) * cellWidth + cellWidth / 2;
    final endY = (endCell ~/ 3) * cellHeight + cellHeight / 2;

    final currentX = startX + (endX - startX) * progress;
    final currentY = startY + (endY - startY) * progress;

    final start = Offset(startX, startY);
    final current = Offset(currentX, currentY);

    final glowPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.5)
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawLine(start, current, glowPaint);

    final corePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, current, corePaint);

    final mainPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, current, mainPaint);

    if (progress > 0.05) {
      final sparkPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(current, 8 * min(1.0, progress * 2), sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WinningLinePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.winningIndices != winningIndices;
  }
}
