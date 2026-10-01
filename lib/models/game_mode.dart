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
      id: 'elemental',
      name: 'Fire & Ice',
      xSymbol: '🔥',
      oSymbol: '❄️',
      xColor: Color(0xFFFF5722),
      oColor: Color(0xFF03A9F4),
      isEmoji: true,
    ),
    SymbolTheme(
      id: 'celestial',
      name: 'Sun & Moon',
      xSymbol: '☀️',
      oSymbol: '🌙',
      xColor: Color(0xFFFFC107),
      oColor: Color(0xFF7E57C2),
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
