import 'package:flutter/material.dart';

import '../models/cell.dart';
import '../models/game_mode.dart';
import '../models/player.dart';

/// Represents a single board cell with spring animation, haptics, selection badge,
/// hint highlight, and symbol theme styling.
class CellWidget extends StatelessWidget {
  final CellData cell;
  final bool isWinningCell;
  final bool isSelected;
  final bool isHinted;
  final SymbolTheme symbolTheme;
  final VoidCallback onTap;

  const CellWidget({
    super.key,
    required this.cell,
    required this.isWinningCell,
    required this.isSelected,
    this.isHinted = false,
    required this.symbolTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isX = cell.player == Player.x;
    final markColor = isX ? symbolTheme.xColor : symbolTheme.oColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isWinningCell
        ? colorScheme.tertiaryContainer
        : (isSelected
            ? markColor.withValues(alpha: 0.2)
            : (isHinted
                ? Colors.amber.withValues(alpha: 0.2)
                : (isDark
                    ? colorScheme.surfaceContainerHigh
                    : Colors.white)));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: isSelected || isHinted
            ? Matrix4.diagonal3Values(1.05, 1.05, 1.0)
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isWinningCell
                ? colorScheme.tertiary
                : (isSelected
                    ? markColor
                    : (isHinted
                        ? Colors.amber
                        : colorScheme.outlineVariant.withValues(alpha: 0.4))),
            width: isWinningCell ? 3.2 : (isSelected || isHinted ? 3.0 : 1.2),
          ),
          boxShadow: [
            if (isWinningCell)
              BoxShadow(
                color: colorScheme.tertiary.withValues(alpha: 0.45),
                blurRadius: 16,
                spreadRadius: 2,
              )
            else if (isSelected)
              BoxShadow(
                color: markColor.withValues(alpha: 0.35),
                blurRadius: 14,
                spreadRadius: 2,
              )
            else if (isHinted)
              BoxShadow(
                color: Colors.amber.withValues(alpha: 0.5),
                blurRadius: 16,
                spreadRadius: 3,
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Symbol Mark Animation
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutBack,
                  ),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: cell.isEmpty
                    ? (isHinted
                        ? const Icon(
                            Icons.lightbulb_rounded,
                            color: Colors.amber,
                            size: 32,
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')))
                    : Text(
                        isX ? symbolTheme.xSymbol : symbolTheme.oSymbol,
                        key: ValueKey('mark_${cell.moveId}'),
                        style: TextStyle(
                          fontSize: symbolTheme.isEmoji ? 40 : 46,
                          fontWeight: FontWeight.w800,
                          color: markColor,
                          shadows: [
                            Shadow(
                              color: markColor.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            // "Moving" Badge on Selected Cell
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: markColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: markColor.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded,
                          size: 10, color: Colors.white),
                      SizedBox(width: 3),
                      Text(
                        'Moving',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // AI Coach Hint Badge
            if (isHinted)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          size: 10, color: Colors.white),
                      SizedBox(width: 2),
                      Text(
                        'Best Move',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
