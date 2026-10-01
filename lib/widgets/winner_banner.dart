import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../models/player.dart';

/// Animated banner displayed when a game is won.
class WinnerBanner extends StatelessWidget {
  final Player? winner;
  final SymbolTheme symbolTheme;
  final GameMode gameMode;

  const WinnerBanner({
    super.key,
    required this.winner,
    required this.symbolTheme,
    required this.gameMode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: winner == null
          ? const SizedBox(height: 0, key: ValueKey('no_winner'))
          : Container(
              key: const ValueKey('winner'),
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.tertiaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.amber,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _getWinnerText(),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _getWinnerText() {
    if (winner == null) return '';
    if (gameMode == GameMode.vsAi) {
      return winner == Player.x ? '🎉 You Beat the AI!' : '🤖 AI Won this round!';
    }
    final symbol = winner == Player.x ? symbolTheme.xSymbol : symbolTheme.oSymbol;
    return 'Player ${winner!.label} ($symbol) Wins!';
  }
}
