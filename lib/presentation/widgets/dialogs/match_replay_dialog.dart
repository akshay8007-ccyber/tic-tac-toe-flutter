import 'dart:async';
import 'package:flutter/material.dart';

import '../../../data/models/cell_model.dart';
import '../../../data/models/match_history_model.dart';
import '../../../data/models/player_model.dart';
import '../board/cell_widget.dart';

class MatchReplayModalSheet extends StatefulWidget {
  final MatchRecord match;

  const MatchReplayModalSheet({super.key, required this.match});

  static void show(BuildContext context, MatchRecord match) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MatchReplayModalSheet(match: match),
    );
  }

  @override
  State<MatchReplayModalSheet> createState() => _MatchReplayModalSheetState();
}

class _MatchReplayModalSheetState extends State<MatchReplayModalSheet> {
  int _currentMoveStep = 0;
  bool _isPlaying = false;
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    if (widget.match.moves.isNotEmpty) {
      _currentMoveStep = widget.match.moves.length;
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      if (_currentMoveStep >= widget.match.moves.length) {
        _currentMoveStep = 0;
      }
      _playbackTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
        if (_currentMoveStep < widget.match.moves.length) {
          setState(() {
            _currentMoveStep++;
          });
        } else {
          timer.cancel();
          setState(() {
            _isPlaying = false;
          });
        }
      });
    } else {
      _playbackTimer?.cancel();
    }
  }

  List<CellData> _getBoardState() {
    if (_currentMoveStep == 0 || widget.match.moves.isEmpty) {
      return List.generate(9, (_) => const CellData());
    }
    final moveIndex = (_currentMoveStep - 1).clamp(0, widget.match.moves.length - 1);
    return widget.match.moves[moveIndex].boardStateSnapshot;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boardCells = _getBoardState();
    final totalSteps = widget.match.moves.length;

    MoveRecord? currentMoveRecord = (_currentMoveStep > 0 && totalSteps > 0)
        ? widget.match.moves[(_currentMoveStep - 1).clamp(0, totalSteps - 1)]
        : null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
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
                        Icons.slow_motion_video_rounded,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Match Replay',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Step $_currentMoveStep of $totalSteps',
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

          // Replay Grid Board
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: AspectRatio(
              aspectRatio: 1,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surfaceContainer
                      : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 9,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final cell = boardCells[index];
                    final isLastTarget = currentMoveRecord?.toIndex == index;

                    return CellWidget(
                      cell: cell,
                      isWinningCell:
                          _currentMoveStep == totalSteps &&
                          (widget.match.winningLine?.contains(index) ?? false),
                      isSelected: isLastTarget,
                      symbolTheme: widget.match.symbolTheme,
                      onTap: () {},
                    );
                  },
                ),
              ),
            ),
          ),

          const Spacer(),

          // Status & Player Banner
          if (currentMoveRecord != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: currentMoveRecord.player == Player.x
                    ? widget.match.symbolTheme.xColor.withValues(alpha: 0.15)
                    : widget.match.symbolTheme.oColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Move #${currentMoveRecord.moveNumber}: '
                'Player ${currentMoveRecord.player.label} '
                '${currentMoveRecord.fromIndex != null ? "moved mark" : "placed mark"}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: currentMoveRecord.player == Player.x
                      ? widget.match.symbolTheme.xColor
                      : widget.match.symbolTheme.oColor,
                ),
              ),
            ),

          // Playback Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: _currentMoveStep > 0
                      ? () {
                          _playbackTimer?.cancel();
                          setState(() {
                            _isPlaying = false;
                            _currentMoveStep--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.skip_previous_rounded),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: _togglePlayback,
                  backgroundColor: colorScheme.primary,
                  elevation: 2,
                  child: Icon(
                    _isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton.filledTonal(
                  onPressed: _currentMoveStep < totalSteps
                      ? () {
                          _playbackTimer?.cancel();
                          setState(() {
                            _isPlaying = false;
                            _currentMoveStep++;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.skip_next_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
