import 'package:flutter/material.dart';

enum GameMode {
  pvp('2 Players', 'Pass & Play', Icons.people_alt_rounded),
  vsAi('vs AI Bot', 'Challenge AI', Icons.smart_toy_rounded);

  final String title;
  final String subtitle;
  final IconData icon;

  const GameMode(this.title, this.subtitle, this.icon);
}

enum AiDifficulty {
  easy('Easy', Icons.sentiment_satisfied_rounded),
  hard('Unbeatable', Icons.psychology_rounded);

  final String label;
  final IconData icon;

  const AiDifficulty(this.label, this.icon);
}

class SymbolTheme {
  final String id;
  final String name;
  final String xSymbol;
  final String oSymbol;
  final Color xColor;
  final Color oColor;
  final bool isEmoji;

  const SymbolTheme({
    required this.id,
    required this.name,
    required this.xSymbol,
    required this.oSymbol,
    required this.xColor,
    required this.oColor,
    this.isEmoji = false,
  });

  static const List<SymbolTheme> themes = [
    SymbolTheme(
      id: 'classic',
      name: 'Classic X & O',
      xSymbol: 'X',
      oSymbol: 'O',
      xColor: Color(0xFF6750A4),
      oColor: Color(0xFFE8873A),
      isEmoji: false,
    ),
    SymbolTheme(
      id: 'cyberpunk',
      name: 'Neon Cyber',
      xSymbol: '✕',
      oSymbol: '◯',
      xColor: Color(0xFF00E5FF),
      oColor: Color(0xFFFF007F),
      isEmoji: false,
    ),
    SymbolTheme(
      id: 'elemental',
      name: 'Fire & Ice',
      xSymbol: '🔥',
      oSymbol: '❄️',
      xColor: Color(0xFFFF5722),
      oColor: Color(0xFF03A9F4),
      isEmoji: true,
    ),
    SymbolTheme(
      id: 'scifi',
      name: 'Space Clash',
      xSymbol: '🚀',
      oSymbol: '👽',
      xColor: Color(0xFF7C4DFF),
      oColor: Color(0xFF00E676),
      isEmoji: true,
    ),
    SymbolTheme(
      id: 'royal',
      name: 'Crown & Gem',
      xSymbol: '👑',
      oSymbol: '💎',
      xColor: Color(0xFFFFD700),
      oColor: Color(0xFF00B0FF),
      isEmoji: true,
    ),
    SymbolTheme(
      id: 'magic',
      name: 'Star & Orb',
      xSymbol: '✨',
      oSymbol: '🔮',
      xColor: Color(0xFFFF4081),
      oColor: Color(0xFF7C4DFF),
      isEmoji: true,
    ),
    SymbolTheme(
      id: 'combat',
      name: 'Sword & Shield',
      xSymbol: '⚔️',
      oSymbol: '🛡️',
      xColor: Color(0xFFE91E63),
      oColor: Color(0xFF009688),
      isEmoji: true,
    ),
  ];
}
