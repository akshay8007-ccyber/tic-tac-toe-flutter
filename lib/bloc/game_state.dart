import 'package:flutter/foundation.dart';

import '../models/achievement.dart';
import '../models/cell.dart';
import '../models/game_mode.dart';
import '../models/match_history.dart';
import '../models/player.dart';
import '../models/player_profile.dart';

class HintMove {
  final int? fromIndex;
  final int toIndex;

  HintMove({this.fromIndex, required this.toIndex});
}

class GameStateSnapshot {
  final List<CellData> cells;
  final Map<Player, List<int>> markPositions;
  final Player currentPlayer;
  final int? selectedCellIndex;
  final Player? winner;
  final List<int>? winningLine;
  final int moveCounter;

  GameStateSnapshot({
    required this.cells,
    required this.markPositions,
    required this.currentPlayer,
    required this.selectedCellIndex,
    required this.winner,
    required this.winningLine,
    required this.moveCounter,
  });
}

@immutable
class GameState {
  final List<CellData> cells;
  final Map<Player, List<int>> markPositions;
  final Player currentPlayer;
  final int? selectedCellIndex;
  final Player? winner;
  final List<int>? winningLine;
  final int moveCounter;

  // Profiles
  final PlayerProfile playerXProfile;
  final PlayerProfile playerOProfile;

  // Settings & Options
  final GameMode gameMode;
  final AiDifficulty aiDifficulty;
  final SymbolTheme selectedSymbolTheme;
  final bool isDarkMode;
  final bool isAiThinking;
  final bool isHapticFeedbackEnabled;

  // Blitz Mode Settings
  final bool isBlitzModeEnabled;
  final int blitzTimeRemaining;

  // AI Coach Hint
  final HintMove? currentHint;

  // Scoreboard & Streaks
  final int xWins;
  final int oWins;
  final int draws;
  final int xStreak;
  final int oStreak;
  final int totalGamesPlayed;

  final Set<String> usedThemeIds;
  final List<GameStateSnapshot> history;
  final List<MoveRecord> currentMatchMoves;
  final List<MatchRecord> matchHistory;
  final List<Achievement> achievements;

  const GameState({
    required this.cells,
    required this.markPositions,
    required this.currentPlayer,
    this.selectedCellIndex,
    this.winner,
    this.winningLine,
    required this.moveCounter,
    required this.playerXProfile,
    required this.playerOProfile,
    required this.gameMode,
    required this.aiDifficulty,
    required this.selectedSymbolTheme,
    required this.isDarkMode,
    required this.isAiThinking,
    required this.isHapticFeedbackEnabled,
    required this.isBlitzModeEnabled,
    required this.blitzTimeRemaining,
    this.currentHint,
    required this.xWins,
    required this.oWins,
    required this.draws,
    required this.xStreak,
    required this.oStreak,
    required this.totalGamesPlayed,
    required this.usedThemeIds,
    required this.history,
    required this.currentMatchMoves,
    required this.matchHistory,
    required this.achievements,
  });

  factory GameState.initial() {
    return GameState(
      cells: List.generate(9, (_) => const CellData()),
      markPositions: const {Player.x: [], Player.o: []},
      currentPlayer: Player.x,
      selectedCellIndex: null,
      winner: null,
      winningLine: null,
      moveCounter: 0,
      playerXProfile: PlayerProfile.defaultX(),
      playerOProfile: PlayerProfile.defaultO(),
      gameMode: GameMode.pvp,
      aiDifficulty: AiDifficulty.hard,
      selectedSymbolTheme: SymbolTheme.themes.first,
      isDarkMode: false,
      isAiThinking: false,
      isHapticFeedbackEnabled: true,
      isBlitzModeEnabled: false,
      blitzTimeRemaining: 5,
      currentHint: null,
      xWins: 0,
      oWins: 0,
      draws: 0,
      xStreak: 0,
      oStreak: 0,
      totalGamesPlayed: 0,
      usedThemeIds: const {},
      history: const [],
      currentMatchMoves: const [],
      matchHistory: const [],
      achievements: Achievement.getDefaultList(),
    );
  }

  bool get isGameOver => winner != null;
  bool get canUndo => history.isNotEmpty && !isGameOver && !isAiThinking;

  int marksCountFor(Player player) => markPositions[player]?.length ?? 0;

  GameState copyWith({
    List<CellData>? cells,
    Map<Player, List<int>>? markPositions,
    Player? currentPlayer,
    int? selectedCellIndex,
    bool clearSelectedCell = false,
    Player? winner,
    bool clearWinner = false,
    List<int>? winningLine,
    bool clearWinningLine = false,
    int? moveCounter,
    PlayerProfile? playerXProfile,
    PlayerProfile? playerOProfile,
    GameMode? gameMode,
    AiDifficulty? aiDifficulty,
    SymbolTheme? selectedSymbolTheme,
    bool? isDarkMode,
    bool? isAiThinking,
    bool? isHapticFeedbackEnabled,
    bool? isBlitzModeEnabled,
    int? blitzTimeRemaining,
    HintMove? currentHint,
    bool clearCurrentHint = false,
    int? xWins,
    int? oWins,
    int? draws,
    int? xStreak,
    int? oStreak,
    int? totalGamesPlayed,
    Set<String>? usedThemeIds,
    List<GameStateSnapshot>? history,
    List<MoveRecord>? currentMatchMoves,
    List<MatchRecord>? matchHistory,
    List<Achievement>? achievements,
  }) {
    return GameState(
      cells: cells ?? this.cells,
      markPositions: markPositions ?? this.markPositions,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      selectedCellIndex:
          clearSelectedCell ? null : (selectedCellIndex ?? this.selectedCellIndex),
      winner: clearWinner ? null : (winner ?? this.winner),
      winningLine:
          clearWinningLine ? null : (winningLine ?? this.winningLine),
      moveCounter: moveCounter ?? this.moveCounter,
      playerXProfile: playerXProfile ?? this.playerXProfile,
      playerOProfile: playerOProfile ?? this.playerOProfile,
      gameMode: gameMode ?? this.gameMode,
      aiDifficulty: aiDifficulty ?? this.aiDifficulty,
      selectedSymbolTheme: selectedSymbolTheme ?? this.selectedSymbolTheme,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isAiThinking: isAiThinking ?? this.isAiThinking,
      isHapticFeedbackEnabled:
          isHapticFeedbackEnabled ?? this.isHapticFeedbackEnabled,
      isBlitzModeEnabled: isBlitzModeEnabled ?? this.isBlitzModeEnabled,
      blitzTimeRemaining: blitzTimeRemaining ?? this.blitzTimeRemaining,
      currentHint:
          clearCurrentHint ? null : (currentHint ?? this.currentHint),
      xWins: xWins ?? this.xWins,
      oWins: oWins ?? this.oWins,
      draws: draws ?? this.draws,
      xStreak: xStreak ?? this.xStreak,
      oStreak: oStreak ?? this.oStreak,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      usedThemeIds: usedThemeIds ?? this.usedThemeIds,
      history: history ?? this.history,
      currentMatchMoves: currentMatchMoves ?? this.currentMatchMoves,
      matchHistory: matchHistory ?? this.matchHistory,
      achievements: achievements ?? this.achievements,
    );
  }
}
