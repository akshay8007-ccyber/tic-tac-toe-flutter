import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../models/game_mode.dart';

class ScoreBoardWidget extends StatelessWidget {
  final GameController controller;

  const ScoreBoardWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final symbolTheme = controller.selectedSymbolTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainer
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreColumn(
            context: context,
            label: 'Player X (${symbolTheme.xSymbol})',
            score: controller.xWins,
            streak: controller.xStreak,
            color: symbolTheme.xColor,
          ),
          Container(
            height: 38,
            width: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          _buildScoreColumn(
            context: context,
            label: controller.gameMode == GameMode.vsAi
                ? 'AI Bot (${symbolTheme.oSymbol})'
                : 'Player O (${symbolTheme.oSymbol})',
            score: controller.oWins,
            streak: controller.oStreak,
            color: symbolTheme.oColor,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreColumn({
    required BuildContext context,
    required String label,
    required int score,
    required int streak,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (streak > 1) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        size: 12, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      'x$streak',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
