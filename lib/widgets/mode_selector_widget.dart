import 'package:flutter/material.dart';

import '../game/game_controller.dart';
import '../models/game_mode.dart';
import '../models/player_profile.dart';

class SettingsModalSheet extends StatefulWidget {
  final GameController controller;

  const SettingsModalSheet({super.key, required this.controller});

  static void show(BuildContext context, GameController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => SettingsModalSheet(controller: controller),
    );
  }

  @override
  State<SettingsModalSheet> createState() => _SettingsModalSheetState();
}

class _SettingsModalSheetState extends State<SettingsModalSheet> {
  late TextEditingController _nameXController;
  late TextEditingController _nameOController;

  @override
  void initState() {
    super.initState();
    _nameXController =
        TextEditingController(text: widget.controller.playerXProfile.name);
    _nameOController =
        TextEditingController(text: widget.controller.playerOProfile.name);
  }

  @override
  void dispose() {
    _nameXController.dispose();
    _nameOController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = widget.controller;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Game Settings',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Player Profiles Editor
            Text(
              'Player Customization',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _buildProfileCard(
                    context: context,
                    label: 'Player X',
                    controller: _nameXController,
                    avatar: controller.playerXProfile.avatarEmoji,
                    onAvatarSelected: (avatar) {
                      controller.updatePlayerXProfile(
                          _nameXController.text, avatar);
                      setState(() {});
                    },
                    onNameChanged: (val) =>
                        controller.updatePlayerXProfile(
                            val, controller.playerXProfile.avatarEmoji),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProfileCard(
                    context: context,
                    label: 'Player O',
                    controller: _nameOController,
                    avatar: controller.playerOProfile.avatarEmoji,
                    onAvatarSelected: (avatar) {
                      controller.updatePlayerOProfile(
                          _nameOController.text, avatar);
                      setState(() {});
                    },
                    onNameChanged: (val) =>
                        controller.updatePlayerOProfile(
                            val, controller.playerOProfile.avatarEmoji),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Game Mode Selector
            Text(
              'Game Mode',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
                setState(() {});
              },
            ),

            if (controller.gameMode == GameMode.vsAi) ...[
              const SizedBox(height: 18),
              Text(
                'AI Difficulty',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
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
                  setState(() {});
                },
              ),
            ],

            const SizedBox(height: 20),

            // Blitz Speed Mode
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Blitz Speed Mode (5s Timer)'),
              subtitle: const Text('Fast-paced gameplay with a 5-second turn timer'),
              value: controller.isBlitzModeEnabled,
              onChanged: (_) {
                controller.toggleBlitzMode();
                setState(() {});
              },
              secondary: const Icon(Icons.timer_rounded, color: Colors.amber),
            ),

            const SizedBox(height: 16),
            Text(
              'Symbol Style & Theme',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),

            // Symbol Themes Wrap
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SymbolTheme.themes.map((theme) {
                final isSelected =
                    controller.selectedSymbolTheme.id == theme.id;
                return ChoiceChip(
                  avatar: CircleAvatar(
                    backgroundColor: theme.xColor,
                    radius: 8,
                  ),
                  label: Text('${theme.name} (${theme.xSymbol} / ${theme.oSymbol})'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.setSymbolTheme(theme);
                      setState(() {});
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 20),
            Text(
              'Feedback & Accessibility',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),

            // Haptic Feedback Switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Haptic Vibration'),
              subtitle: const Text('Vibrate on taps, selections & victories'),
              value: controller.isHapticFeedbackEnabled,
              onChanged: (_) {
                controller.toggleHaptics();
                setState(() {});
              },
              secondary: const Icon(Icons.vibration_rounded),
            ),

            // Dark Mode Switch
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle app color scheme'),
              value: controller.isDarkMode,
              onChanged: (_) {
                controller.toggleDarkMode();
                setState(() {});
              },
              secondary: Icon(
                controller.isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
              ),
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
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String avatar,
    required ValueChanged<String> onAvatarSelected,
    required ValueChanged<String> onNameChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PopupMenuButton<String>(
                initialValue: avatar,
                onSelected: onAvatarSelected,
                itemBuilder: (context) => PlayerProfile.availableAvatars
                    .map((av) => PopupMenuItem(
                          value: av,
                          child: Text(av, style: const TextStyle(fontSize: 22)),
                        ))
                    .toList(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(avatar, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onNameChanged,
                  decoration: InputDecoration(
                    labelText: label,
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
