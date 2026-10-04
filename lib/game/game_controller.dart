import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/achievement.dart';
import '../models/cell.dart';
import '../models/game_mode.dart';
import '../models/match_history.dart';
import '../models/player.dart';
import '../models/player_profile.dart';
import 'ai_bot.dart';
import 'game_logic.dart';

/// Snapshot for undo functionality.
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

/// Hint representation for AI Coach mode.
class HintMove {
  final int? fromIndex;
  final int toIndex;

  HintMove({this.fromIndex, required this.toIndex});
}

/// Complete Game Controller managing board state, AI bot, Blitz turn timer,
/// AI Coach hints, achievements, match history, and player profiles.
class GameController extends ChangeNotifier {
  GameController() {
    _achievements = Achievement.getDefaultList();
    _reset();
  }

  late List<CellData> _cells;
  late Map<Player, List<int>> _markPositions;
  late Player _currentPlayer;
  int? _selectedCellIndex;
  Player? _winner;
  List<int>? _winningLine;
  int _moveCounter = 0;

  // Profiles
  final PlayerProfile _playerXProfile = PlayerProfile.defaultX();
  final PlayerProfile _playerOProfile = PlayerProfile.defaultO();

  // Settings & Options
  GameMode _gameMode = GameMode.pvp;
  AiDifficulty _aiDifficulty = AiDifficulty.hard;
  SymbolTheme _selectedSymbolTheme = SymbolTheme.themes.first;
  bool _isDarkMode = false;
  bool _isAiThinking = false;
  bool _isHapticFeedbackEnabled = true;

  // Blitz Mode Settings
  bool _isBlitzModeEnabled = false;
  static const int blitzTimeLimit = 5; // seconds per turn
  int _blitzTimeRemaining = blitzTimeLimit;
  Timer? _blitzTimer;

  // AI Coach Hint State
  HintMove? _currentHint;

  // Scoreboard & Streaks
  int _xWins = 0;
  int _oWins = 0;
  int _draws = 0;
  int _xStreak = 0;
  int _oStreak = 0;
  int _totalGamesPlayed = 0;

  final Set<String> _usedThemeIds = {};
  final List<GameStateSnapshot> _history = [];
  final List<MoveRecord> _currentMatchMoves = [];
  final List<MatchRecord> _matchHistory = [];
  late List<Achievement> _achievements;

  // Getters
  List<CellData> get cells => List.unmodifiable(_cells);
  Player get currentPlayer => _currentPlayer;
  int? get selectedCellIndex => _selectedCellIndex;
  Player? get winner => _winner;
  List<int>? get winningLine => _winningLine;
  bool get isGameOver => _winner != null;
  bool get isAiThinking => _isAiThinking;

  GameMode get gameMode => _gameMode;
  AiDifficulty get aiDifficulty => _aiDifficulty;
  SymbolTheme get selectedSymbolTheme => _selectedSymbolTheme;
  bool get isDarkMode => _isDarkMode;
  bool get isHapticFeedbackEnabled => _isHapticFeedbackEnabled;

  bool get isBlitzModeEnabled => _isBlitzModeEnabled;
  int get blitzTimeRemaining => _blitzTimeRemaining;
  HintMove? get currentHint => _currentHint;

  PlayerProfile get playerXProfile => _playerXProfile;
  PlayerProfile get playerOProfile => _playerOProfile;

  int get xWins => _xWins;
  int get oWins => _oWins;
  int get draws => _draws;
  int get xStreak => _xStreak;
  int get oStreak => _oStreak;
  int get totalGamesPlayed => _totalGamesPlayed;

  List<Achievement> get achievements => List.unmodifiable(_achievements);
  List<MatchRecord> get matchHistory => List.unmodifiable(_matchHistory);

  bool get canUndo => _history.isNotEmpty && !isGameOver && !_isAiThinking;

  int marksCountFor(Player player) => _markPositions[player]!.length;

  void triggerHaptic({bool heavy = false, bool selection = false}) {
    if (!_isHapticFeedbackEnabled) return;
    if (selection) {
      HapticFeedback.selectionClick();
    } else if (heavy) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  /// Calculates AI Coach Hint move for current player.
  void requestHint() {
    if (isGameOver || _isAiThinking) return;

    final board = _cells.map((c) => c.player).toList();
    final moveChoice = AiBot.findBestMove(
      board: board,
      markPositions: _markPositions,
      aiPlayer: _currentPlayer,
      isHardMode: true,
    );

    if (moveChoice != null) {
      triggerHaptic(selection: true);
      _currentHint = HintMove(
        fromIndex: moveChoice.fromIndex,
        toIndex: moveChoice.toIndex,
      );
      notifyListeners();
    }
  }

  void clearHint() {
    _currentHint = null;
  }

  /// Handles taps on the board.
  void onCellTap(int index) {
    if (isGameOver || _isAiThinking) return;

    _currentHint = null; // Clear active hint on tap
    final playerMarks = _markPositions[_currentPlayer]!;

    if (playerMarks.length < GameLogic.maxMarksPerPlayer) {
      if (_cells[index].isEmpty) {
        triggerHaptic();
        _saveSnapshot();
        _executePlacement(index);
      }
    } else {
      if (_cells[index].player == _currentPlayer) {
        triggerHaptic(selection: true);
        if (_selectedCellIndex == index) {
          _selectedCellIndex = null;
        } else {
          _selectedCellIndex = index;
        }
        notifyListeners();
      } else if (_cells[index].isEmpty && _selectedCellIndex != null) {
        triggerHaptic();
        _saveSnapshot();
        _executeMove(_selectedCellIndex!, index);
      }
    }
  }

  void _executePlacement(int targetIndex) {
    _moveCounter++;
    _markPositions[_currentPlayer]!.add(targetIndex);
    _cells[targetIndex] = CellData(player: _currentPlayer, moveId: _moveCounter);

    _recordMove(fromIndex: null, toIndex: targetIndex);
    _checkGameResultAndSwitchTurn();
  }

  void _executeMove(int fromIndex, int toIndex) {
    _moveCounter++;
    final positions = _markPositions[_currentPlayer]!;
    positions.remove(fromIndex);
    positions.add(toIndex);

    _cells[fromIndex] = const CellData();
    _cells[toIndex] = CellData(player: _currentPlayer, moveId: _moveCounter);
    _selectedCellIndex = null;

    _recordMove(fromIndex: fromIndex, toIndex: toIndex);
    _checkGameResultAndSwitchTurn();
  }

  void _recordMove({int? fromIndex, required int toIndex}) {
    _currentMatchMoves.add(
      MoveRecord(
        moveNumber: _moveCounter,
        player: _currentPlayer,
        fromIndex: fromIndex,
        toIndex: toIndex,
        boardStateSnapshot: List.from(_cells),
      ),
    );
  }

  void _checkGameResultAndSwitchTurn() {
    final positions = _markPositions[_currentPlayer]!;
    final result = GameLogic.checkWinner(positions, _currentPlayer);

    if (result.hasWinner) {
      _stopBlitzTimer();
      _winner = result.winner;
      _winningLine = result.winningLine;
      _selectedCellIndex = null;
      _totalGamesPlayed++;

      triggerHaptic(heavy: true);

      if (_winner == Player.x) {
        _xWins++;
        _xStreak++;
        _oStreak = 0;
      } else if (_winner == Player.o) {
        _oWins++;
        _oStreak++;
        _xStreak = 0;
      }

      _checkAndUnlockAchievements();
      _saveMatchHistory();
    } else {
      _currentPlayer = _currentPlayer.opponent;
      _selectedCellIndex = null;

      _resetBlitzTimer();

      if (_gameMode == GameMode.vsAi && _currentPlayer == Player.o) {
        _triggerAiTurn();
      }
    }

    notifyListeners();
  }

  void _resetBlitzTimer() {
    _stopBlitzTimer();
    if (_isBlitzModeEnabled && !isGameOver) {
      _blitzTimeRemaining = blitzTimeLimit;
      _blitzTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_blitzTimeRemaining > 1) {
          _blitzTimeRemaining--;
          notifyListeners();
        } else {
          // Timeout! Force turn switch or move
          triggerHaptic(heavy: true);
          _handleBlitzTimeout();
        }
      });
    }
  }

  void _handleBlitzTimeout() {
    _stopBlitzTimer();
    if (isGameOver) return;

    // Switch turn on timeout
    _currentPlayer = _currentPlayer.opponent;
    _selectedCellIndex = null;
    notifyListeners();

    if (_gameMode == GameMode.vsAi && _currentPlayer == Player.o) {
      _triggerAiTurn();
    } else {
      _resetBlitzTimer();
    }
  }

  void _stopBlitzTimer() {
    _blitzTimer?.cancel();
    _blitzTimer = null;
  }

  void _triggerAiTurn() {
    _isAiThinking = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 380), () {
      if (isGameOver) {
        _isAiThinking = false;
        notifyListeners();
        return;
      }

      final board = _cells.map((c) => c.player).toList();
      final moveChoice = AiBot.findBestMove(
        board: board,
        markPositions: _markPositions,
        aiPlayer: Player.o,
        isHardMode: _aiDifficulty == AiDifficulty.hard,
      );

      _isAiThinking = false;

      if (moveChoice != null) {
        _saveSnapshot();
        if (moveChoice.fromIndex != null) {
          _executeMove(moveChoice.fromIndex!, moveChoice.toIndex);
        } else {
          _executePlacement(moveChoice.toIndex);
        }
      } else {
        notifyListeners();
      }
    });
  }

  void _checkAndUnlockAchievements() {
    _unlock('first_win');

    if (_gameMode == GameMode.vsAi &&
        _winner == Player.x &&
        _aiDifficulty == AiDifficulty.hard) {
      _unlock('ai_slayer');
    }

    if (_xStreak >= 3 || _oStreak >= 3) _unlock('streak_3');
    if (_xStreak >= 5 || _oStreak >= 5) _unlock('streak_5');

    if (_moveCounter > 6 && _winner != null) {
      _unlock('tactician');
    }

    if (_isBlitzModeEnabled && _winner != null) {
      _unlock('blitz_master');
    }

    _usedThemeIds.add(_selectedSymbolTheme.id);
    if (_usedThemeIds.length >= 3) {
      _unlock('style_icon');
    }
  }

  void _unlock(String id) {
    final ach = _achievements.firstWhere((a) => a.id == id,
        orElse: () => _achievements.first);
    if (!ach.isUnlocked) {
      ach.isUnlocked = true;
      ach.unlockedAt = DateTime.now();
    }
  }

  void _saveMatchHistory() {
    _matchHistory.add(
      MatchRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        gameMode: _gameMode,
        aiDifficulty: _aiDifficulty,
        winner: _winner,
        winningLine: _winningLine,
        playerXName: _playerXProfile.name,
        playerOName: _gameMode == GameMode.vsAi
            ? 'AI Bot (${_aiDifficulty.label})'
            : _playerOProfile.name,
        moves: List.from(_currentMatchMoves),
        symbolTheme: _selectedSymbolTheme,
      ),
    );
  }

  void undo() {
    if (_history.isEmpty || _isAiThinking) return;

    triggerHaptic(selection: true);
    _currentHint = null;
    int stepsToUndo = (_gameMode == GameMode.vsAi && _history.length >= 2) ? 2 : 1;

    GameStateSnapshot? snapshot;
    while (stepsToUndo > 0 && _history.isNotEmpty) {
      snapshot = _history.removeLast();
      if (_currentMatchMoves.isNotEmpty) _currentMatchMoves.removeLast();
      stepsToUndo--;
    }

    if (snapshot != null) {
      _cells = List.from(snapshot.cells);
      _markPositions = {
        Player.x: List.from(snapshot.markPositions[Player.x]!),
        Player.o: List.from(snapshot.markPositions[Player.o]!),
      };
      _currentPlayer = snapshot.currentPlayer;
      _selectedCellIndex = snapshot.selectedCellIndex;
      _winner = snapshot.winner;
      _winningLine = snapshot.winningLine;
      _moveCounter = snapshot.moveCounter;
      _resetBlitzTimer();
      notifyListeners();
    }
  }

  void _saveSnapshot() {
    _history.add(
      GameStateSnapshot(
        cells: List.from(_cells),
        markPositions: {
          Player.x: List.from(_markPositions[Player.x]!),
          Player.o: List.from(_markPositions[Player.o]!),
        },
        currentPlayer: _currentPlayer,
        selectedCellIndex: _selectedCellIndex,
        winner: _winner,
        winningLine: _winningLine,
        moveCounter: _moveCounter,
      ),
    );
  }

  void setGameMode(GameMode mode) {
    if (_gameMode == mode) return;
    _gameMode = mode;
    restart();
  }

  void setAiDifficulty(AiDifficulty difficulty) {
    if (_aiDifficulty == difficulty) return;
    _aiDifficulty = difficulty;
    if (_gameMode == GameMode.vsAi) {
      restart();
    } else {
      notifyListeners();
    }
  }

  void setSymbolTheme(SymbolTheme theme) {
    _selectedSymbolTheme = theme;
    triggerHaptic(selection: true);
    notifyListeners();
  }

  void toggleBlitzMode() {
    _isBlitzModeEnabled = !_isBlitzModeEnabled;
    triggerHaptic(selection: true);
    restart();
  }

  void updatePlayerXProfile(String name, String avatar) {
    _playerXProfile.name = name;
    _playerXProfile.avatarEmoji = avatar;
    notifyListeners();
  }

  void updatePlayerOProfile(String name, String avatar) {
    _playerOProfile.name = name;
    _playerOProfile.avatarEmoji = avatar;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    triggerHaptic(selection: true);
    notifyListeners();
  }

  void toggleHaptics() {
    _isHapticFeedbackEnabled = !_isHapticFeedbackEnabled;
    triggerHaptic(selection: true);
    notifyListeners();
  }

  void resetScores() {
    _xWins = 0;
    _oWins = 0;
    _draws = 0;
    _xStreak = 0;
    _oStreak = 0;
    _totalGamesPlayed = 0;
    triggerHaptic(selection: true);
    notifyListeners();
  }

  void restart() {
    triggerHaptic(selection: true);
    _stopBlitzTimer();
    _history.clear();
    _currentMatchMoves.clear();
    _reset();
    _resetBlitzTimer();
    notifyListeners();
  }

  void _reset() {
    _cells = List.generate(GameLogic.boardSize, (_) => const CellData());
    _markPositions = {Player.x: [], Player.o: []};
    _currentPlayer = Player.x;
    _selectedCellIndex = null;
    _winner = null;
    _winningLine = null;
    _moveCounter = 0;
    _isAiThinking = false;
    _currentHint = null;
  }

  @override
  void dispose() {
    _stopBlitzTimer();
    super.dispose();
  }
}
