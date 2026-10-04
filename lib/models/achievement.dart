import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  static List<Achievement> getDefaultList() => [
        Achievement(
          id: 'first_win',
          title: 'First Victory',
          description: 'Win your very first Tic Tac Toe match',
          icon: Icons.emoji_events_rounded,
          color: const Color(0xFFFFD700),
        ),
        Achievement(
          id: 'ai_slayer',
          title: 'AI Slayer',
          description: 'Defeat the Unbeatable AI Bot',
          icon: Icons.smart_toy_rounded,
          color: const Color(0xFF7C4DFF),
        ),
        Achievement(
          id: 'streak_3',
          title: 'Hat Trick',
          description: 'Achieve a 3-match win streak',
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFFF5722),
        ),
        Achievement(
          id: 'streak_5',
          title: 'On Fire',
          description: 'Achieve a 5-match win streak',
          icon: Icons.whatshot_rounded,
          color: const Color(0xFFFF1744),
        ),
        Achievement(
          id: 'tactician',
          title: 'Master Tactician',
          description: 'Win a game during the Movement Phase',
          icon: Icons.touch_app_rounded,
          color: const Color(0xFF00E676),
        ),
        Achievement(
          id: 'blitz_master',
          title: 'Speed Demon',
          description: 'Win a match playing in Blitz Speed Mode',
          icon: Icons.timer_rounded,
          color: const Color(0xFF00E5FF),
        ),
        Achievement(
          id: 'style_icon',
          title: 'Style Icon',
          description: 'Play matches using 3 different symbol themes',
          icon: Icons.palette_rounded,
          color: const Color(0xFFFF4081),
        ),
      ];
}
