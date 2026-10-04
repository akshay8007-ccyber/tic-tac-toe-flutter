import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/game_mode_model.dart';
import '../../../data/models/player_model.dart';
import '../../../data/models/player_profile_model.dart';
import '../../bloc/game_bloc.dart';
import '../../bloc/game_event.dart';
import '../../bloc/game_state.dart';

class SettingsModalSheet extends StatefulWidget {
  const SettingsModalSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => const SettingsModalSheet(),
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
    final blocState = context.read<GameBloc>().state;
    _nameXController =
        TextEditingController(text: blocState.playerXProfile.name);
    _nameOController =
        TextEditingController(text: blocState.playerOProfile.name);
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

    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final bloc = context.read<GameBloc>();

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
                        avatar: state.playerXProfile.avatarEmoji,
                        onAvatarSelected: (avatar) {
                          bloc.add(PlayerProfileUpdatedEvent(
                            player: Player.x,
                            name: _nameXController.text,
                            avatarEmoji: avatar,
                          ));
                        },
                        onNameChanged: (val) => bloc.add(PlayerProfileUpdatedEvent(
                          player: Player.x,
                          name: val,
                          avatarEmoji: state.playerXProfile.avatarEmoji,
                        )),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildProfileCard(
                        context: context,
                        label: 'Player O',
                        controller: _nameOController,
                        avatar: state.playerOProfile.avatarEmoji,
                        onAvatarSelected: (avatar) {
                          bloc.add(PlayerProfileUpdatedEvent(
                            player: Player.o,
                            name: _nameOController.text,
                            avatarEmoji: avatar,
                          ));
                        },
                        onNameChanged: (val) => bloc.add(PlayerProfileUpdatedEvent(
                          player: Player.o,
                          name: val,
                          avatarEmoji: state.playerOProfile.avatarEmoji,
                        )),
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
                  selected: {state.gameMode},
                  onSelectionChanged: (selected) {
                    bloc.add(GameModeChangedEvent(selected.first));
                  },
                ),

                if (state.gameMode == GameMode.vsAi) ...[
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
                    selected: {state.aiDifficulty},
                    onSelectionChanged: (selected) {
                      bloc.add(AiDifficultyChangedEvent(selected.first));
                    },
                  ),
                ],

                const SizedBox(height: 20),

                // Blitz Speed Mode
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Blitz Speed Mode (5s Timer)'),
                  subtitle: const Text('Fast-paced gameplay with a 5-second turn timer'),
                  value: state.isBlitzModeEnabled,
                  onChanged: (_) {
                    bloc.add(const BlitzModeToggledEvent());
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
                        state.selectedSymbolTheme.id == theme.id;
                    return ChoiceChip(
                      avatar: CircleAvatar(
                        backgroundColor: theme.xColor,
                        radius: 8,
                      ),
                      label: Text(
                          '${theme.name} (${theme.xSymbol} / ${theme.oSymbol})'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          bloc.add(SymbolThemeChangedEvent(theme));
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
                  value: state.isHapticFeedbackEnabled,
                  onChanged: (_) {
                    bloc.add(const HapticsToggledEvent());
                  },
                  secondary: const Icon(Icons.vibration_rounded),
                ),

                // Dark Mode Switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle app color scheme'),
                  value: state.isDarkMode,
                  onChanged: (_) {
                    bloc.add(const DarkModeToggledEvent());
                  },
                  secondary: Icon(
                    state.isDarkMode
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
                          bloc.add(const ScoresResetEvent());
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
      },
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
