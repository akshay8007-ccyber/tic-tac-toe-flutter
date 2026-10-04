import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../models/game_mode.dart';
import '../widgets/achievements_dialog.dart';
import '../widgets/ambient_background.dart';
import '../widgets/history_dialog.dart';
import '../widgets/how_to_play_dialog.dart';
import '../widgets/mode_selector_widget.dart';

/// Modern Dashboard Home Screen using BLoC state management for game launching,
/// achievements, match history, and theme settings.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _launchGame(BuildContext context, GameMode mode) {
    HapticFeedback.mediumImpact();
    context.read<GameBloc>().add(GameModeChangedEvent(mode));
    Navigator.of(context).pushNamed('/game');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        return Scaffold(
          body: AmbientParticleBackground(
            symbolTheme: state.selectedSymbolTheme,
            child: SafeArea(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.tertiary,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.grid_3x3_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tic Tac Toe',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  'Select & Move Edition',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Actions: Theme & Settings
                        Row(
                          children: [
                            IconButton(
                              tooltip: 'Toggle Theme',
                              style: IconButton.styleFrom(
                                backgroundColor: colorScheme
                                    .surfaceContainerHigh
                                    .withValues(alpha: 0.5),
                              ),
                              icon: Icon(
                                state.isDarkMode
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                              ),
                              onPressed: () => context
                                  .read<GameBloc>()
                                  .add(const DarkModeToggledEvent()),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Settings',
                              style: IconButton.styleFrom(
                                backgroundColor: colorScheme
                                    .surfaceContainerHigh
                                    .withValues(alpha: 0.5),
                              ),
                              icon: const Icon(Icons.settings_rounded),
                              onPressed: () =>
                                  SettingsModalSheet.show(context),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Rule Highlight Banner
                    GestureDetector(
                      onTap: () => HowToPlayModal.show(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primaryContainer
                                  .withValues(alpha: 0.7),
                              colorScheme.tertiaryContainer
                                  .withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.touch_app_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '3-Mark Select & Move',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Place 3 marks, then select & slide marks to empty tiles to win!',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onPrimaryContainer
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'SELECT GAME MODE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Game Mode 1: Play vs AI
                    _buildModeCard(
                      context: context,
                      title: 'Single Player',
                      subtitle: 'Challenge smart AI Bot',
                      icon: Icons.smart_toy_rounded,
                      accentColor: colorScheme.primary,
                      badgeText: state.aiDifficulty.label,
                      onTap: () => _launchGame(context, GameMode.vsAi),
                      extraWidget: Row(
                        children: AiDifficulty.values.map((diff) {
                          final isSelected = state.aiDifficulty == diff;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(diff.label),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  context.read<GameBloc>().add(
                                      AiDifficultyChangedEvent(diff));
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Game Mode 2: Pass & Play
                    _buildModeCard(
                      context: context,
                      title: 'Pass & Play',
                      subtitle: '2 Players on the same device',
                      icon: Icons.people_alt_rounded,
                      accentColor: colorScheme.tertiary,
                      badgeText: 'Local PvP',
                      onTap: () => _launchGame(context, GameMode.pvp),
                    ),

                    const SizedBox(height: 24),

                    // Quick Feature Hub Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            icon: Icons.emoji_events_rounded,
                            iconColor: Colors.amber,
                            label: 'Achievements',
                            onTap: () => AchievementsModalSheet.show(
                                context, state.achievements),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            icon: Icons.history_rounded,
                            iconColor: colorScheme.primary,
                            label: 'Replays',
                            onTap: () => MatchHistoryModalSheet.show(
                                context, state.matchHistory),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            icon: Icons.menu_book_rounded,
                            label: 'How to Play',
                            onTap: () => HowToPlayModal.show(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            context: context,
                            icon: Icons.palette_rounded,
                            label: 'Themes',
                            onTap: () => SettingsModalSheet.show(context),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Current Theme & Stats Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? colorScheme.surfaceContainer
                            : colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.stars_rounded,
                                color: state.selectedSymbolTheme.xColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Active Style: ${state.selectedSymbolTheme.name}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Total Played: ${state.totalGamesPlayed}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String badgeText,
    required VoidCallback onTap,
    Widget? extraWidget,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      icon,
                      color: accentColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                badgeText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (extraWidget != null) ...[
                const SizedBox(height: 14),
                extraWidget,
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.play_arrow_rounded, size: 20),
                  label: const Text('Play Now'),
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    Color? iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: iconColor),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        backgroundColor: isDark ? colorScheme.surfaceContainer : Colors.white,
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
