import 'package:flutter/foundation.dart';

import '../models/game_mode.dart';
import '../models/player.dart';

@immutable
abstract class GameEvent {
  const GameEvent();
}

class CellTappedEvent extends GameEvent {
  final int index;
  const CellTappedEvent(this.index);
}

class UndoRequestedEvent extends GameEvent {
  const UndoRequestedEvent();
}

class GameRestartedEvent extends GameEvent {
  const GameRestartedEvent();
}

class GameModeChangedEvent extends GameEvent {
  final GameMode mode;
  const GameModeChangedEvent(this.mode);
}

class AiDifficultyChangedEvent extends GameEvent {
  final AiDifficulty difficulty;
  const AiDifficultyChangedEvent(this.difficulty);
}

class SymbolThemeChangedEvent extends GameEvent {
  final SymbolTheme theme;
  const SymbolThemeChangedEvent(this.theme);
}

class DarkModeToggledEvent extends GameEvent {
  const DarkModeToggledEvent();
}

class HapticsToggledEvent extends GameEvent {
  const HapticsToggledEvent();
}

class BlitzModeToggledEvent extends GameEvent {
  const BlitzModeToggledEvent();
}

class HintRequestedEvent extends GameEvent {
  const HintRequestedEvent();
}

class ScoresResetEvent extends GameEvent {
  const ScoresResetEvent();
}

class PlayerProfileUpdatedEvent extends GameEvent {
  final Player player;
  final String name;
  final String avatarEmoji;

  const PlayerProfileUpdatedEvent({
    required this.player,
    required this.name,
    required this.avatarEmoji,
  });
}

class BlitzTimerTickedEvent extends GameEvent {
  const BlitzTimerTickedEvent();
}
