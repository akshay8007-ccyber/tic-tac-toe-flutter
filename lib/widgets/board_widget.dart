// Board Widget displaying 3x3 grid with selected cell highlighting
import 'package:flutter/material.dart';

import '../models/cell.dart';
import '../models/game_mode.dart';
import 'cell_widget.dart';

/// Renders the 3x3 grid with support for selected tile highlighting, winning lines,
/// and symbol themes.
class BoardWidget extends StatelessWidget {
  final List<CellData> cells;
  final List<int>? winningLine;
  final int? selectedCellIndex;
  final SymbolTheme symbolTheme;
  final ValueChanged<int> onCellTap;

  const BoardWidget({
    super.key,
    required this.cells,
    required this.winningLine,
    required this.selectedCellIndex,
    required this.symbolTheme,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Theme.of(context).colorScheme.surfaceContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
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

            return CellWidget(
              cell: cells[index],
              isWinningCell: isWinningCell,
              isSelected: isSelected,
              symbolTheme: symbolTheme,
              onTap: () => onCellTap(index),
            );
          },
        ),
      ),
    );
  }
}
