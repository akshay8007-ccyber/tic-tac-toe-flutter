import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/haptic_utility.dart';
import '../../../data/models/game_mode_model.dart';
import '../../bloc/game_bloc.dart';
import '../../bloc/game_event.dart';
import '../../bloc/game_state.dart';
import '../../widgets/common/ambient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _gridDraw;
  late Animation<double> _textFade;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
    );

    _logoFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _gridDraw = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeInOutCubic),
    );

    _textFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
    );

    _buttonScale = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOutBack),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onStartPressed(BuildContext context, [GameMode? mode]) {
    HapticUtility.medium(enabled: true);
    if (mode != null) {
      context.read<GameBloc>().add(GameModeChangedEvent(mode));
    }
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return Scaffold(
          body: AmbientParticleBackground(
            symbolTheme: state.selectedSymbolTheme,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Animated Neon Tic Tac Toe Board Logo
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(
                            opacity: _logoFade.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 190,
                                  height: 190,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: colorScheme.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 36,
                                        spreadRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 170,
                                  height: 170,
                                  child: CustomPaint(
                                    painter: _SplashGridPainter(
                                      progress: _gridDraw.value,
                                      primaryColor: colorScheme.primary,
                                      secondaryColor: colorScheme.tertiary,
                                    ),
                                    child: Stack(
                                      children: [
                                        _buildFloatingMark(
                                          '✕',
                                          colorScheme.primary,
                                          const Alignment(-0.6, -0.6),
                                        ),
                                        _buildFloatingMark(
                                          '◯',
                                          colorScheme.tertiary,
                                          const Alignment(0.6, -0.6),
                                        ),
                                        _buildFloatingMark(
                                          '◯',
                                          colorScheme.tertiary,
                                          const Alignment(-0.6, 0.6),
                                        ),
                                        _buildFloatingMark(
                                          '✕',
                                          colorScheme.primary,
                                          const Alignment(0.6, 0.6),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Title & Subtitle Fade-In
                    FadeTransition(
                      opacity: _textFade,
                      child: Column(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.tertiary,
                                colorScheme.secondary,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'TIC TAC TOE',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer
                                  .withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: colorScheme.outlineVariant
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Interactive 3-Mark Mechanics',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Animated Play Button
                    ScaleTransition(
                      scale: _buttonScale,
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 58,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.tertiary,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary
                                      .withValues(alpha: 0.4),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _onStartPressed(context),
                              icon: const Icon(Icons.play_arrow_rounded,
                                  size: 28, color: Colors.white),
                              label: const Text(
                                'GET STARTED',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Quick Mode Row
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _onStartPressed(context, GameMode.vsAi),
                                  icon: const Icon(Icons.smart_toy_rounded,
                                      size: 18),
                                  label: const Text('vs AI Bot'),
                                  style: OutlinedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _onStartPressed(context, GameMode.pvp),
                                  icon: const Icon(Icons.people_alt_rounded,
                                      size: 18),
                                  label: const Text('2 Players'),
                                  style: OutlinedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingMark(String symbol, Color color, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Text(
        symbol,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: color,
          shadows: [
            Shadow(
              color: color.withValues(alpha: 0.6),
              blurRadius: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashGridPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color secondaryColor;

  _SplashGridPainter({
    required this.progress,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withValues(alpha: 0.6)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final stepX = size.width / 3;
    final stepY = size.height / 3;

    canvas.drawLine(
        Offset(stepX, 0), Offset(stepX, size.height * progress), paint);
    canvas.drawLine(Offset(stepX * 2, 0),
        Offset(stepX * 2, size.height * progress), paint);
    canvas.drawLine(
        Offset(0, stepY), Offset(size.width * progress, stepY), paint);
    canvas.drawLine(Offset(0, stepY * 2),
        Offset(size.width * progress, stepY * 2), paint);
  }

  @override
  bool shouldRepaint(covariant _SplashGridPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
