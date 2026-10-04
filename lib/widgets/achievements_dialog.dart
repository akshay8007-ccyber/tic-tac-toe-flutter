import 'package:flutter/material.dart';

import '../models/achievement.dart';

class AchievementsModalSheet extends StatelessWidget {
  final List<Achievement> achievements;

  const AchievementsModalSheet({super.key, required this.achievements});

  static void show(BuildContext context, List<Achievement> achievements) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AchievementsModalSheet(achievements: achievements),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final unlockedCount = achievements.where((a) => a.isUnlocked).length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                        color: Colors.amber.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.amber,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Achievements',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Unlocked: $unlockedCount / ${achievements.length}',
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

          // Achievement List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: achievements.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = achievements[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: item.isUnlocked
                        ? item.color.withValues(alpha: 0.12)
                        : (isDark
                            ? colorScheme.surfaceContainer
                            : Colors.grey.withValues(alpha: 0.08)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: item.isUnlocked
                          ? item.color.withValues(alpha: 0.4)
                          : colorScheme.outlineVariant.withValues(alpha: 0.3),
                      width: item.isUnlocked ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: item.isUnlocked
                              ? item.color
                              : Colors.grey.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (item.isUnlocked)
                              BoxShadow(
                                color: item.color.withValues(alpha: 0.4),
                                blurRadius: 10,
                              ),
                          ],
                        ),
                        child: Icon(
                          item.isUnlocked
                              ? item.icon
                              : Icons.lock_outline_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: item.isUnlocked
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (item.isUnlocked)
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                          size: 20,
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
