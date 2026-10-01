import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../models/game_mode.dart';

class SettingsModalSheet extends StatelessWidget {
  final GameController controller;

  const SettingsModalSheet({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SettingsModalSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Game Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          // Game Mode Selector
          Text(
            'Game Mode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<GameMode>(
            segments: GameMode.values.map((mode) {
              return ButtonSegment<GameMode>(
                value: mode,
                label: Text(mode.title),
                icon: Icon(mode.icon),
              );
            }).toList(),
            selected: {controller.gameMode},
            onSelectionChanged: (selected) {
              controller.setGameMode(selected.first);
            },
          ),

          if (controller.gameMode == GameMode.vsAi) ...[
            const SizedBox(height: 16),
            Text(
              'AI Difficulty',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<AiDifficulty>(
              segments: AiDifficulty.values.map((diff) {
                return ButtonSegment<AiDifficulty>(
                  value: diff,
                  label: Text(diff.label),
                  icon: Icon(diff.icon),
                );
              }).toList(),
              selected: {controller.aiDifficulty},
              onSelectionChanged: (selected) {
                controller.setAiDifficulty(selected.first);
              },
            ),
          ],

          const SizedBox(height: 20),
          Text(
            'Symbol Style & Theme',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),

          // Symbol Themes grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SymbolTheme.themes.map((theme) {
              final isSelected = controller.selectedSymbolTheme.id == theme.id;
              return ChoiceChip(
                label: Text('${theme.name} (${theme.xSymbol} / ${theme.oSymbol})'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    controller.setSymbolTheme(theme);
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    controller.resetScores();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cleaning_services_rounded),
                  label: const Text('Reset Scoreboard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
