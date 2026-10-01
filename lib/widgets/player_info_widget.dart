import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../models/player.dart';

/// Shows player badge, custom label, active turn status, and active mark count (e.g. 3/3).
class PlayerInfoWidget extends StatelessWidget {
  final Player player;
  final int count;
  final int maxCount;
  final bool isActive;
  final bool isWinner;
  final SymbolTheme symbolTheme;
  final String? customTitle;

  const PlayerInfoWidget({
    super.key,
    required this.player,
    required this.count,
    required this.maxCount,
    required this.isActive,
    required this.isWinner,
    required this.symbolTheme,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isX = player == Player.x;
    final accent = isX ? symbolTheme.xColor : symbolTheme.oColor;
    final symbol = isX ? symbolTheme.xSymbol : symbolTheme.oSymbol;
    final title = customTitle ?? 'Player ${player.label}';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? accent.withValues(alpha: 0.14)
            : (Theme.of(context).brightness == Brightness.dark
                ? colorScheme.surfaceContainer
                : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? accent : colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: isActive ? 2.2 : 1,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: accent.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  symbolTheme.isEmoji ? symbol : player.label,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: symbolTheme.isEmoji ? 16 : 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (isWinner) ...[
                const SizedBox(width: 6),
                Icon(Icons.emoji_events, color: accent, size: 18),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Marks: $count/$maxCount',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: accent,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
