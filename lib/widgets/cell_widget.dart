import 'package:flutter/material.dart';

import '../models/cell.dart';
import '../models/game_mode.dart';
import '../models/player.dart';

/// Represents a single tappable board cell with support for selection highlighting,
/// custom symbol themes, and win animations.
class CellWidget extends StatelessWidget {
  final CellData cell;
  final bool isWinningCell;
  final bool isSelected;
  final SymbolTheme symbolTheme;
  final VoidCallback onTap;

  const CellWidget({
    super.key,
    required this.cell,
    required this.isWinningCell,
    required this.isSelected,
    required this.symbolTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isX = cell.player == Player.x;
    final markColor = isX ? symbolTheme.xColor : symbolTheme.oColor;

    final backgroundColor = isWinningCell
        ? colorScheme.tertiaryContainer
        : (isSelected
            ? markColor.withValues(alpha: 0.18)
            : (Theme.of(context).brightness == Brightness.dark
                ? colorScheme.surfaceContainerHigh
                : Colors.white));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: isSelected
            ? (Matrix4.identity()..scale(1.05))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isWinningCell
                ? colorScheme.tertiary
                : (isSelected
                    ? markColor
                    : colorScheme.outlineVariant.withValues(alpha: 0.4)),
            width: isWinningCell ? 3.0 : (isSelected ? 2.8 : 1.2),
          ),
          boxShadow: [
            if (isWinningCell)
              BoxShadow(
                color: colorScheme.tertiary.withValues(alpha: 0.35),
                blurRadius: 14,
                spreadRadius: 2,
              )
            else if (isSelected)
              BoxShadow(
                color: markColor.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cell Mark Content
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
                    ? const SizedBox.shrink(key: ValueKey('empty'))
                    : Text(
                        isX ? symbolTheme.xSymbol : symbolTheme.oSymbol,
                        key: ValueKey('mark_${cell.moveId}'),
                        style: TextStyle(
                          fontSize: symbolTheme.isEmoji ? 42 : 48,
                          fontWeight: FontWeight.w800,
                          color: markColor,
                        ),
                      ),
              ),
            ),

            // "Selected to Move" indicator badge
            if (isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: markColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded, size: 10, color: Colors.white),
                      SizedBox(width: 2),
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
          ],
        ),
      ),
    );
  }
}
