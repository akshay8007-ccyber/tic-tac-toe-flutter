import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../game/game_logic.dart';
import '../models/game_mode.dart';
import '../models/player.dart';
import '../widgets/ambient_background.dart';
import '../widgets/board_widget.dart';
import '../widgets/confetti_widget.dart';
import '../widgets/how_to_play_dialog.dart';
import '../widgets/mode_selector_widget.dart';
import '../widgets/player_info_widget.dart';
import '../widgets/score_board_widget.dart';
import '../widgets/winner_banner.dart';

/// Main screen featuring interactive "Select & Move" mechanics for 3-mark Tic Tac Toe,
/// Blitz Mode turn timer, and AI Coach Hints.
class GameScreen extends StatelessWidget {
  final GameController controller;

  const GameScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isGameOver = controller.isGameOver;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back to Home',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          controller.gameMode == GameMode.vsAi
              ? 'vs AI (${controller.aiDifficulty.label})'
              : '2 Players Mode',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          // AI Coach Hint Button
          if (!isGameOver)
            IconButton(
              tooltip: 'AI Coach Hint',
              icon: const Icon(Icons.lightbulb_rounded, color: Colors.amber),
              onPressed: controller.requestHint,
            ),
          IconButton(
            tooltip: 'How to Play',
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => HowToPlayModal.show(context),
          ),
          IconButton(
            tooltip: 'Game Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => SettingsModalSheet.show(context, controller),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: AmbientParticleBackground(
        symbolTheme: controller.selectedSymbolTheme,
        child: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxBoardWidth = constraints.maxWidth < 500
                      ? constraints.maxWidth
                      : 440.0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 24),
                      child: Column(
                        children: [
                          // Dynamic Rule Banner
                          _buildRuleHelpChip(context, colorScheme),
                          const SizedBox(height: 10),

                          // Blitz Speed Mode Countdown Bar
                          if (controller.isBlitzModeEnabled && !isGameOver)
                            _buildBlitzCountdownBar(context, colorScheme),

                          const SizedBox(height: 10),

                          // Scoreboard
                          ScoreBoardWidget(controller: controller),
                          const SizedBox(height: 16),

                          // Winner Banner or Turn Action Guidance
                          WinnerBanner(
                            winner: controller.winner,
                            symbolTheme: controller.selectedSymbolTheme,
                            gameMode: controller.gameMode,
                          ),

                          if (!isGameOver)
                            _buildTurnIndicator(context, colorScheme),

                          const SizedBox(height: 16),

                          // 3x3 Game Board
                          Center(
                            child: SizedBox(
                              width: maxBoardWidth,
                              child: BoardWidget(
                                cells: controller.cells,
                                winningLine: controller.winningLine,
                                selectedCellIndex: controller.selectedCellIndex,
                                hintMove: controller.currentHint,
                                symbolTheme: controller.selectedSymbolTheme,
                                onCellTap: controller.onCellTap,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Player Info & Active Mark Counters
                          Row(
                            children: [
                              Expanded(
                                child: PlayerInfoWidget(
                                  player: Player.x,
                                  count: controller.marksCountFor(Player.x),
                                  maxCount: GameLogic.maxMarksPerPlayer,
                                  isActive: !isGameOver &&
                                      controller.currentPlayer == Player.x,
                                  isWinner: controller.winner == Player.x,
                                  symbolTheme: controller.selectedSymbolTheme,
                                  customTitle: controller.playerXProfile.name,
                                  avatarEmoji: controller.playerXProfile.avatarEmoji,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: PlayerInfoWidget(
                                  player: Player.o,
                                  count: controller.marksCountFor(Player.o),
                                  maxCount: GameLogic.maxMarksPerPlayer,
                                  isActive: !isGameOver &&
                                      controller.currentPlayer == Player.o,
                                  isWinner: controller.winner == Player.o,
                                  symbolTheme: controller.selectedSymbolTheme,
                                  customTitle: controller.gameMode == GameMode.vsAi
                                      ? 'AI Bot (${controller.aiDifficulty.label})'
                                      : controller.playerOProfile.name,
                                  avatarEmoji: controller.gameMode == GameMode.vsAi
                                      ? '🤖'
                                      : controller.playerOProfile.avatarEmoji,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Action Buttons: Undo, Hint & Restart
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: OutlinedButton.icon(
                                  onPressed: controller.canUndo
                                      ? controller.undo
                                      : null,
                                  icon: const Icon(Icons.undo_rounded),
                                  label: const Text('Undo'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: OutlinedButton.icon(
                                  onPressed: !isGameOver
                                      ? controller.requestHint
                                      : null,
                                  icon: const Icon(Icons.lightbulb_rounded,
                                      color: Colors.amber),
                                  label: const Text('Hint'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 3,
                                child: FilledButton.icon(
                                  onPressed: controller.restart,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Restart'),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Victory Celebration Overlay
            VictoryConfettiWidget(isPlaying: controller.winner != null),
          ],
        ),
      ),
    );
  }

  Widget _buildBlitzCountdownBar(
      BuildContext context, ColorScheme colorScheme) {
    final remaining = controller.blitzTimeRemaining;
    final double progress = remaining / GameController.blitzTimeLimit;
    final isUrgent = remaining <= 2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isUrgent
            ? Colors.red.withValues(alpha: 0.15)
            : Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUrgent ? Colors.red : Colors.amber,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.timer_rounded,
            color: isUrgent ? Colors.red : Colors.amber,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: isUrgent
                    ? Colors.red.withValues(alpha: 0.2)
                    : Colors.amber.withValues(alpha: 0.2),
                color: isUrgent ? Colors.red : Colors.amber,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${remaining}s',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isUrgent ? Colors.red : Colors.amber,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleHelpChip(BuildContext context, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () => HowToPlayModal.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Place 3 marks • Then tap any of your marks to select & move it',
                style: TextStyle(
                  color: colorScheme.onSecondaryContainer,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTurnIndicator(BuildContext context, ColorScheme colorScheme) {
    if (controller.isAiThinking) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
          border:
              Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'AI Bot is making a move...',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    }

    final player = controller.currentPlayer;
    final symbolTheme = controller.selectedSymbolTheme;
    final isX = player == Player.x;
    final accent = isX ? symbolTheme.xColor : symbolTheme.oColor;
    final symbol = isX ? symbolTheme.xSymbol : symbolTheme.oSymbol;

    final playerLabel = controller.gameMode == GameMode.vsAi && !isX
        ? 'AI Bot'
        : (isX ? controller.playerXProfile.name : controller.playerOProfile.name);

    final playerMarks = controller.marksCountFor(player);

    String statusText;
    if (playerMarks < GameLogic.maxMarksPerPlayer) {
      statusText = "$playerLabel's turn ($symbol): Tap empty cell";
    } else if (controller.selectedCellIndex == null) {
      statusText = "$playerLabel's turn ($symbol): Tap one of your marks";
    } else {
      statusText = "$playerLabel's turn ($symbol): Tap empty cell to move";
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey(
            '${player}_${symbolTheme.id}_${controller.selectedCellIndex}'),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: accent.withValues(alpha: 0.4)),
        ),
        child: Text(
          statusText,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: accent,
          ),
        ),
      ),
    );
  }
}
