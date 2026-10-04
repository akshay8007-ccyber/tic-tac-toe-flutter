import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../models/cell.dart';
import '../models/game_mode.dart';
import 'cell_widget.dart';
import 'winning_line_painter.dart';

/// Renders the 3x3 grid with selected tile highlights, symbol themes,
/// AI Coach hints, and animated winning line overlays.
class BoardWidget extends StatelessWidget {
  final List<CellData> cells;
  final List<int>? winningLine;
  final int? selectedCellIndex;
  final HintMove? hintMove;
  final SymbolTheme symbolTheme;
  final ValueChanged<int> onCellTap;

  const BoardWidget({
    super.key,
    required this.cells,
    required this.winningLine,
    required this.selectedCellIndex,
    this.hintMove,
    required this.symbolTheme,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          // Main Board Grid Container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainer
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cells.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final isWinningCell = winningLine?.contains(index) ?? false;
                final isSelected = selectedCellIndex == index;
                final isHinted = hintMove != null &&
                    (hintMove!.toIndex == index ||
                        hintMove!.fromIndex == index);

                return CellWidget(
                  cell: cells[index],
                  isWinningCell: isWinningCell,
                  isSelected: isSelected,
                  isHinted: isHinted,
                  symbolTheme: symbolTheme,
                  onTap: () => onCellTap(index),
                );
              },
            ),
          ),

          // Winning Laser Line Overlay
          if (winningLine != null && winningLine!.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: WinningLinePainterWidget(
                    winningLine: winningLine!,
                    lineColor: colorScheme.tertiary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
