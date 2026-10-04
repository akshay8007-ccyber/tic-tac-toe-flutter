import 'package:flutter/material.dart';

import '../models/match_history.dart';
import '../models/player.dart';
import 'match_replay_dialog.dart';

class MatchHistoryModalSheet extends StatelessWidget {
  final List<MatchRecord> history;

  const MatchHistoryModalSheet({super.key, required this.history});

  static void show(BuildContext context, List<MatchRecord> history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MatchHistoryModalSheet(history: history),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1D1B26) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Match History',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Total Recorded: ${history.length}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 24, indent: 24, endIndent: 24),

          // History List
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 48,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Matches Played Yet',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Play a match to see history & replays here!',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    itemCount: history.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = history.reversed.toList()[index];
                      final isXWin = item.winner == Player.x;
                      final isOWin = item.winner == Player.o;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? colorScheme.surfaceContainer
                              : colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isXWin
                                    ? item.symbolTheme.xColor
                                        .withValues(alpha: 0.2)
                                    : (isOWin
                                        ? item.symbolTheme.oColor
                                            .withValues(alpha: 0.2)
                                        : Colors.grey.withValues(alpha: 0.2)),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isXWin || isOWin
                                    ? Icons.emoji_events_rounded
                                    : Icons.balance_rounded,
                                color: isXWin
                                    ? item.symbolTheme.xColor
                                    : (isOWin
                                        ? item.symbolTheme.oColor
                                        : Colors.grey),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.winner != null
                                        ? 'Winner: ${item.winner == Player.x ? item.playerXName : item.playerOName}'
                                        : 'Draw Game',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.gameMode.title} • ${item.totalMoves} Moves',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: () {
                                MatchReplayModalSheet.show(context, item);
                              },
                              icon: const Icon(Icons.play_arrow_rounded,
                                  size: 18),
                              label: const Text('Replay'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
