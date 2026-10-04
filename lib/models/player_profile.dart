class PlayerProfile {
  String name;
  String avatarEmoji;

  PlayerProfile({
    required this.name,
    required this.avatarEmoji,
  });

  static const List<String> availableAvatars = [
    '⚡',
    '🤖',
    '🚀',
    '👑',
    '🔥',
    '🐉',
    '👽',
    '🦊',
    '🎮',
    '🎯',
    '🔮',
    '🌟',
  ];

  static PlayerProfile defaultX() =>
      PlayerProfile(name: 'Player X', avatarEmoji: '⚡');

  static PlayerProfile defaultO() =>
      PlayerProfile(name: 'Player O', avatarEmoji: '🎯');

  static PlayerProfile defaultAi() =>
      PlayerProfile(name: 'AI Maestro', avatarEmoji: '🤖');
}
