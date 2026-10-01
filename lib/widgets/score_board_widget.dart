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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? colorScheme.surfaceContainer
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
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
            color: symbolTheme.xColor,
          ),
          Container(
            height: 32,
            width: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          _buildScoreColumn(
            context: context,
            label: controller.gameMode == GameMode.vsAi
                ? 'AI Bot (${symbolTheme.oSymbol})'
                : 'Player O (${symbolTheme.oSymbol})',
            score: controller.oWins,
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
        Text(
          '$score',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
