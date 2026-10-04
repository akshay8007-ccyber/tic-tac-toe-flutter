import 'package:flutter/material.dart';

import '../../../data/models/game_mode_model.dart';
import '../../../data/models/player_model.dart';

/// Shows player badge, custom label, active turn status, avatar emoji, and active mark count (e.g. 3/3).
class PlayerInfoWidget extends StatelessWidget {
  final Player player;
  final int count;
  final int maxCount;
  final bool isActive;
  final bool isWinner;
  final SymbolTheme symbolTheme;
  final String? customTitle;
  final String? avatarEmoji;

  const PlayerInfoWidget({
    super.key,
    required this.player,
    required this.count,
    required this.maxCount,
    required this.isActive,
    required this.isWinner,
    required this.symbolTheme,
    this.customTitle,
    this.avatarEmoji,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isX = player == Player.x;
    final accent = isX ? symbolTheme.xColor : symbolTheme.oColor;
    final title = customTitle ?? 'Player ${player.label}';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? accent.withValues(alpha: 0.16)
            : (isDark ? colorScheme.surfaceContainer : Colors.white),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive ? accent : colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: isActive ? 2.5 : 1,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: accent.withValues(alpha: 0.25),
              blurRadius: 12,
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
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent, width: 1.5),
                ),
                child: Text(
                  avatarEmoji ?? (isX ? '⚡' : '🎯'),
                  style: const TextStyle(fontSize: 16),
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
                    fontSize: 13,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (isWinner) ...[
                const SizedBox(width: 6),
                Icon(Icons.emoji_events_rounded, color: accent, size: 18),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Marks: $count/$maxCount',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: accent,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
