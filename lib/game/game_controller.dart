import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/cell.dart';
import '../models/game_mode.dart';
import '../models/player.dart';
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

/// Game controller managing state, movement selection, AI bot, scores, and themes.
class GameController extends ChangeNotifier {
  GameController() {
    _reset();
  }

  late List<CellData> _cells;
  late Map<Player, List<int>> _markPositions;
  late Player _currentPlayer;
  int? _selectedCellIndex;
  Player? _winner;
  List<int>? _winningLine;
  int _moveCounter = 0;

  // Settings & Scores
  GameMode _gameMode = GameMode.pvp;
  AiDifficulty _aiDifficulty = AiDifficulty.hard;
  SymbolTheme _selectedSymbolTheme = SymbolTheme.themes.first;
  bool _isDarkMode = false;
  bool _isAiThinking = false;

  int _xWins = 0;
  int _oWins = 0;
  int _draws = 0;

  final List<GameStateSnapshot> _history = [];

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

  int get xWins => _xWins;
  int get oWins => _oWins;
  int get draws => _draws;
  bool get canUndo => _history.isNotEmpty && !isGameOver && !_isAiThinking;

  int marksCountFor(Player player) => _markPositions[player]!.length;

  /// Handles taps on the board.
  /// - In Placement Phase (marks < 3): tapping empty cell drops a mark.
  /// - In Movement Phase (marks == 3): tapping player's own mark selects it;
  ///   then tapping an empty cell moves the selected mark there.
  void onCellTap(int index) {
    if (isGameOver || _isAiThinking) return;

    final playerMarks = _markPositions[_currentPlayer]!;

    if (playerMarks.length < GameLogic.maxMarksPerPlayer) {
      // --- Placement Phase ---
      if (_cells[index].isEmpty) {
        _saveSnapshot();
        _executePlacement(index);
      }
    } else {
      // --- Movement Phase ---
      if (_cells[index].player == _currentPlayer) {
        // Select or toggle selection of player's own mark
        if (_selectedCellIndex == index) {
          _selectedCellIndex = null; // deselect
        } else {
          _selectedCellIndex = index; // select new tile
        }
        notifyListeners();
      } else if (_cells[index].isEmpty && _selectedCellIndex != null) {
        // Move selected mark to empty tile
        _saveSnapshot();
        _executeMove(_selectedCellIndex!, index);
      }
    }
  }

  void _executePlacement(int targetIndex) {
    _moveCounter++;
    _markPositions[_currentPlayer]!.add(targetIndex);
    _cells[targetIndex] = CellData(player: _currentPlayer, moveId: _moveCounter);

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

    _checkGameResultAndSwitchTurn();
  }

  void _checkGameResultAndSwitchTurn() {
    final positions = _markPositions[_currentPlayer]!;
    final result = GameLogic.checkWinner(positions, _currentPlayer);

    if (result.hasWinner) {
      _winner = result.winner;
      _winningLine = result.winningLine;
      _selectedCellIndex = null;

      if (_winner == Player.x) {
        _xWins++;
      } else if (_winner == Player.o) {
        _oWins++;
      }
    } else {
      _currentPlayer = _currentPlayer.opponent;
      _selectedCellIndex = null;

      if (_gameMode == GameMode.vsAi && _currentPlayer == Player.o) {
        _triggerAiTurn();
      }
    }

    notifyListeners();
  }

  void _triggerAiTurn() {
    _isAiThinking = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 400), () {
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

  void undo() {
    if (_history.isEmpty || _isAiThinking) return;

    int stepsToUndo = (_gameMode == GameMode.vsAi && _history.length >= 2) ? 2 : 1;

    GameStateSnapshot? snapshot;
    while (stepsToUndo > 0 && _history.isNotEmpty) {
      snapshot = _history.removeLast();
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
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void resetScores() {
    _xWins = 0;
    _oWins = 0;
    _draws = 0;
    notifyListeners();
  }

  void restart() {
    _history.clear();
    _reset();
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
  }
}
