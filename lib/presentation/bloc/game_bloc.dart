import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/haptic_utility.dart';
import '../../data/models/achievement_model.dart';
import '../../data/models/cell_model.dart';
import '../../data/models/game_mode_model.dart';
import '../../data/models/match_history_model.dart';
import '../../data/models/player_model.dart';
import '../../domain/ai/ai_bot_engine.dart';
import '../../domain/logic/game_rules.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  Timer? _blitzTimer;
  static const int blitzTimeLimit = 5;

  GameBloc() : super(GameState.initial()) {
    on<CellTappedEvent>(_onCellTapped);
    on<UndoRequestedEvent>(_onUndoRequested);
    on<GameRestartedEvent>(_onGameRestarted);
    on<GameModeChangedEvent>(_onGameModeChanged);
    on<AiDifficultyChangedEvent>(_onAiDifficultyChanged);
    on<SymbolThemeChangedEvent>(_onSymbolThemeChanged);
    on<DarkModeToggledEvent>(_onDarkModeToggled);
    on<HapticsToggledEvent>(_onHapticsToggled);
    on<BlitzModeToggledEvent>(_onBlitzModeToggled);
    on<HintRequestedEvent>(_onHintRequested);
    on<ScoresResetEvent>(_onScoresReset);
    on<PlayerProfileUpdatedEvent>(_onPlayerProfileUpdated);
    on<BlitzTimerTickedEvent>(_onBlitzTimerTicked);
    on<AiMoveCalculatedEvent>(_onAiMoveCalculated);
  }

  void _triggerHaptic({bool heavy = false, bool selection = false}) {
    if (!state.isHapticFeedbackEnabled) return;
    if (selection) {
      HapticUtility.selection(enabled: true);
    } else if (heavy) {
      HapticUtility.heavy(enabled: true);
    } else {
      HapticUtility.light(enabled: true);
    }
  }

  void _onCellTapped(CellTappedEvent event, Emitter<GameState> emit) {
    if (state.isGameOver || state.isAiThinking) return;

    final playerMarks = state.markPositions[state.currentPlayer] ?? [];
    final index = event.index;

    if (playerMarks.length < GameRules.maxMarksPerPlayer) {
      // Placement Phase
      if (state.cells[index].isEmpty) {
        _triggerHaptic();
        final updatedState = _saveSnapshot(state);
        _executePlacement(index, updatedState, emit);
      }
    } else {
      // Movement Phase
      if (state.cells[index].player == state.currentPlayer) {
        _triggerHaptic(selection: true);
        if (state.selectedCellIndex == index) {
          emit(state.copyWith(clearSelectedCell: true, clearCurrentHint: true));
        } else {
          emit(state.copyWith(
            selectedCellIndex: index,
            clearCurrentHint: true,
          ));
        }
      } else if (state.cells[index].isEmpty && state.selectedCellIndex != null) {
        _triggerHaptic();
        final updatedState = _saveSnapshot(state);
        _executeMove(state.selectedCellIndex!, index, updatedState, emit);
      }
    }
  }

  void _executePlacement(int targetIndex, GameState currentState, Emitter<GameState> emit) {
    final moveCounter = currentState.moveCounter + 1;

    final newPositions = Map<Player, List<int>>.from({
      Player.x: List<int>.from(currentState.markPositions[Player.x]!),
      Player.o: List<int>.from(currentState.markPositions[Player.o]!),
    });
    newPositions[currentState.currentPlayer]!.add(targetIndex);

    final newCells = List<CellData>.from(currentState.cells);
    newCells[targetIndex] = CellData(player: currentState.currentPlayer, moveId: moveCounter);

    final newMoves = List<MoveRecord>.from(currentState.currentMatchMoves)
      ..add(MoveRecord(
        moveNumber: moveCounter,
        player: currentState.currentPlayer,
        fromIndex: null,
        toIndex: targetIndex,
        boardStateSnapshot: newCells,
      ));

    final nextState = currentState.copyWith(
      cells: newCells,
      markPositions: newPositions,
      moveCounter: moveCounter,
      currentMatchMoves: newMoves,
      clearCurrentHint: true,
      isAiThinking: false,
    );

    _checkGameResultAndSwitchTurn(nextState, emit);
  }

  void _executeMove(int fromIndex, int toIndex, GameState currentState, Emitter<GameState> emit) {
    final moveCounter = currentState.moveCounter + 1;

    final newPositions = Map<Player, List<int>>.from({
      Player.x: List<int>.from(currentState.markPositions[Player.x]!),
      Player.o: List<int>.from(currentState.markPositions[Player.o]!),
    });
    newPositions[currentState.currentPlayer]!.remove(fromIndex);
    newPositions[currentState.currentPlayer]!.add(toIndex);

    final newCells = List<CellData>.from(currentState.cells);
    newCells[fromIndex] = const CellData();
    newCells[toIndex] = CellData(player: currentState.currentPlayer, moveId: moveCounter);

    final newMoves = List<MoveRecord>.from(currentState.currentMatchMoves)
      ..add(MoveRecord(
        moveNumber: moveCounter,
        player: currentState.currentPlayer,
        fromIndex: fromIndex,
        toIndex: toIndex,
        boardStateSnapshot: newCells,
      ));

    final nextState = currentState.copyWith(
      cells: newCells,
      markPositions: newPositions,
      moveCounter: moveCounter,
      currentMatchMoves: newMoves,
      clearSelectedCell: true,
      clearCurrentHint: true,
      isAiThinking: false,
    );

    _checkGameResultAndSwitchTurn(nextState, emit);
  }

  void _checkGameResultAndSwitchTurn(GameState currentState, Emitter<GameState> emit) {
    final positions = currentState.markPositions[currentState.currentPlayer]!;
    final result = GameRules.checkWinner(positions, currentState.currentPlayer);

    if (result.hasWinner) {
      _stopBlitzTimer();
      _triggerHaptic(heavy: true);

      final winner = result.winner;
      final newXWins = winner == Player.x ? currentState.xWins + 1 : currentState.xWins;
      final newOWins = winner == Player.o ? currentState.oWins + 1 : currentState.oWins;
      final newXStreak = winner == Player.x ? currentState.xStreak + 1 : 0;
      final newOStreak = winner == Player.o ? currentState.oStreak + 1 : 0;
      final totalGames = currentState.totalGamesPlayed + 1;

      final matchRecord = MatchRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        gameMode: currentState.gameMode,
        aiDifficulty: currentState.aiDifficulty,
        winner: winner,
        winningLine: result.winningLine,
        playerXName: currentState.playerXProfile.name,
        playerOName: currentState.gameMode == GameMode.vsAi
            ? 'AI Bot (${currentState.aiDifficulty.label})'
            : currentState.playerOProfile.name,
        moves: currentState.currentMatchMoves,
        symbolTheme: currentState.selectedSymbolTheme,
      );

      final newMatchHistory = List<MatchRecord>.from(currentState.matchHistory)..add(matchRecord);
      final newAchievements = _checkAchievements(currentState, winner, moveCounter: currentState.moveCounter, xStreak: newXStreak, oStreak: newOStreak);

      emit(currentState.copyWith(
        winner: winner,
        winningLine: result.winningLine,
        clearSelectedCell: true,
        xWins: newXWins,
        oWins: newOWins,
        xStreak: newXStreak,
        oStreak: newOStreak,
        totalGamesPlayed: totalGames,
        matchHistory: newMatchHistory,
        achievements: newAchievements,
        isAiThinking: false,
      ));
    } else {
      final nextPlayer = currentState.currentPlayer.opponent;
      final nextState = currentState.copyWith(
        currentPlayer: nextPlayer,
        clearSelectedCell: true,
      );

      emit(nextState);
      _resetBlitzTimer();

      if (nextState.gameMode == GameMode.vsAi && nextPlayer == Player.o) {
        _scheduleAiTurn(nextState, emit);
      }
    }
  }

  void _scheduleAiTurn(GameState currentState, Emitter<GameState> emit) {
    emit(currentState.copyWith(isAiThinking: true));

    Future.delayed(const Duration(milliseconds: 380), () {
      if (state.isGameOver || state.currentPlayer != Player.o) return;

      final board = state.cells.map((c) => c.player).toList();
      final moveChoice = AiBotEngine.findBestMove(
        board: board,
        markPositions: state.markPositions,
        aiPlayer: Player.o,
        isHardMode: state.aiDifficulty == AiDifficulty.hard,
      );

      if (moveChoice != null) {
        add(AiMoveCalculatedEvent(moveChoice));
      }
    });
  }

  void _onAiMoveCalculated(AiMoveCalculatedEvent event, Emitter<GameState> emit) {
    if (state.isGameOver || state.currentPlayer != Player.o) {
      emit(state.copyWith(isAiThinking: false));
      return;
    }

    final snapState = _saveSnapshot(state);
    if (event.moveChoice.fromIndex != null) {
      _executeMove(event.moveChoice.fromIndex!, event.moveChoice.toIndex, snapState, emit);
    } else {
      _executePlacement(event.moveChoice.toIndex, snapState, emit);
    }
  }

  List<Achievement> _checkAchievements(GameState currentState, Player? winner, {required int moveCounter, required int xStreak, required int oStreak}) {
    final list = List<Achievement>.from(currentState.achievements);

    void unlock(String id) {
      final idx = list.indexWhere((a) => a.id == id);
      if (idx != -1 && !list[idx].isUnlocked) {
        list[idx].isUnlocked = true;
        list[idx].unlockedAt = DateTime.now();
      }
    }

    if (winner != null) unlock('first_win');
    if (currentState.gameMode == GameMode.vsAi && winner == Player.x && currentState.aiDifficulty == AiDifficulty.hard) unlock('ai_slayer');
    if (xStreak >= 3 || oStreak >= 3) unlock('streak_3');
    if (xStreak >= 5 || oStreak >= 5) unlock('streak_5');
    if (moveCounter > 6 && winner != null) unlock('tactician');
    if (currentState.isBlitzModeEnabled && winner != null) unlock('blitz_master');

    return list;
  }

  GameState _saveSnapshot(GameState currentState) {
    final snapshot = GameStateSnapshot(
      cells: List.from(currentState.cells),
      markPositions: {
        Player.x: List.from(currentState.markPositions[Player.x]!),
        Player.o: List.from(currentState.markPositions[Player.o]!),
      },
      currentPlayer: currentState.currentPlayer,
      selectedCellIndex: currentState.selectedCellIndex,
      winner: currentState.winner,
      winningLine: currentState.winningLine,
      moveCounter: currentState.moveCounter,
    );

    return currentState.copyWith(
      history: List<GameStateSnapshot>.from(currentState.history)..add(snapshot),
    );
  }

  void _onUndoRequested(UndoRequestedEvent event, Emitter<GameState> emit) {
    if (state.history.isEmpty || state.isAiThinking) return;

    _triggerHaptic(selection: true);
    int stepsToUndo = (state.gameMode == GameMode.vsAi && state.history.length >= 2) ? 2 : 1;

    final newHistory = List<GameStateSnapshot>.from(state.history);
    final newMoves = List<MoveRecord>.from(state.currentMatchMoves);

    GameStateSnapshot? snapshot;
    while (stepsToUndo > 0 && newHistory.isNotEmpty) {
      snapshot = newHistory.removeLast();
      if (newMoves.isNotEmpty) newMoves.removeLast();
      stepsToUndo--;
    }

    if (snapshot != null) {
      emit(state.copyWith(
        cells: snapshot.cells,
        markPositions: snapshot.markPositions,
        currentPlayer: snapshot.currentPlayer,
        selectedCellIndex: snapshot.selectedCellIndex,
        clearSelectedCell: snapshot.selectedCellIndex == null,
        winner: snapshot.winner,
        clearWinner: snapshot.winner == null,
        winningLine: snapshot.winningLine,
        clearWinningLine: snapshot.winningLine == null,
        moveCounter: snapshot.moveCounter,
        history: newHistory,
        currentMatchMoves: newMoves,
        clearCurrentHint: true,
        isAiThinking: false,
      ));
      _resetBlitzTimer();
    }
  }

  void _onGameRestarted(GameRestartedEvent event, Emitter<GameState> emit) {
    _triggerHaptic(selection: true);
    _stopBlitzTimer();

    emit(state.copyWith(
      cells: List.generate(9, (_) => const CellData()),
      markPositions: const {Player.x: [], Player.o: []},
      currentPlayer: Player.x,
      clearSelectedCell: true,
      clearWinner: true,
      clearWinningLine: true,
      moveCounter: 0,
      isAiThinking: false,
      clearCurrentHint: true,
      history: const [],
      currentMatchMoves: const [],
    ));

    _resetBlitzTimer();
  }

  void _onGameModeChanged(GameModeChangedEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(gameMode: event.mode));
    add(const GameRestartedEvent());
  }

  void _onAiDifficultyChanged(AiDifficultyChangedEvent event, Emitter<GameState> emit) {
    emit(state.copyWith(aiDifficulty: event.difficulty));
    if (state.gameMode == GameMode.vsAi) {
      add(const GameRestartedEvent());
    }
  }

  void _onSymbolThemeChanged(SymbolThemeChangedEvent event, Emitter<GameState> emit) {
    _triggerHaptic(selection: true);
    final newUsedThemes = Set<String>.from(state.usedThemeIds)..add(event.theme.id);
    var updatedAchievements = state.achievements;
    if (newUsedThemes.length >= 3) {
      updatedAchievements = _checkAchievements(state, state.winner, moveCounter: state.moveCounter, xStreak: state.xStreak, oStreak: state.oStreak);
    }

    emit(state.copyWith(
      selectedSymbolTheme: event.theme,
      usedThemeIds: newUsedThemes,
      achievements: updatedAchievements,
    ));
  }

  void _onDarkModeToggled(DarkModeToggledEvent event, Emitter<GameState> emit) {
    _triggerHaptic(selection: true);
    emit(state.copyWith(isDarkMode: !state.isDarkMode));
  }

  void _onHapticsToggled(HapticsToggledEvent event, Emitter<GameState> emit) {
    _triggerHaptic(selection: true);
    emit(state.copyWith(isHapticFeedbackEnabled: !state.isHapticFeedbackEnabled));
  }

  void _onBlitzModeToggled(BlitzModeToggledEvent event, Emitter<GameState> emit) {
    _triggerHaptic(selection: true);
    emit(state.copyWith(isBlitzModeEnabled: !state.isBlitzModeEnabled));
    add(const GameRestartedEvent());
  }

  void _onHintRequested(HintRequestedEvent event, Emitter<GameState> emit) {
    if (state.isGameOver || state.isAiThinking) return;

    final board = state.cells.map((c) => c.player).toList();
    final moveChoice = AiBotEngine.findBestMove(
      board: board,
      markPositions: state.markPositions,
      aiPlayer: state.currentPlayer,
      isHardMode: true,
    );

    if (moveChoice != null) {
      _triggerHaptic(selection: true);
      emit(state.copyWith(
        currentHint: HintMove(
          fromIndex: moveChoice.fromIndex,
          toIndex: moveChoice.toIndex,
        ),
      ));
    }
  }

  void _onScoresReset(ScoresResetEvent event, Emitter<GameState> emit) {
    _triggerHaptic(selection: true);
    emit(state.copyWith(
      xWins: 0,
      oWins: 0,
      draws: 0,
      xStreak: 0,
      oStreak: 0,
      totalGamesPlayed: 0,
    ));
  }

  void _onPlayerProfileUpdated(PlayerProfileUpdatedEvent event, Emitter<GameState> emit) {
    if (event.player == Player.x) {
      final p = state.playerXProfile;
      p.name = event.name;
      p.avatarEmoji = event.avatarEmoji;
      emit(state.copyWith(playerXProfile: p));
    } else {
      final p = state.playerOProfile;
      p.name = event.name;
      p.avatarEmoji = event.avatarEmoji;
      emit(state.copyWith(playerOProfile: p));
    }
  }

  void _onBlitzTimerTicked(BlitzTimerTickedEvent event, Emitter<GameState> emit) {
    if (!state.isBlitzModeEnabled || state.isGameOver) return;

    if (state.blitzTimeRemaining > 1) {
      emit(state.copyWith(blitzTimeRemaining: state.blitzTimeRemaining - 1));
    } else {
      _triggerHaptic(heavy: true);
      _stopBlitzTimer();

      final nextPlayer = state.currentPlayer.opponent;
      final nextState = state.copyWith(
        currentPlayer: nextPlayer,
        clearSelectedCell: true,
        blitzTimeRemaining: blitzTimeLimit,
      );

      emit(nextState);
      _resetBlitzTimer();

      if (nextState.gameMode == GameMode.vsAi && nextPlayer == Player.o) {
        _scheduleAiTurn(nextState, emit);
      }
    }
  }

  void _resetBlitzTimer() {
    _stopBlitzTimer();
    if (state.isBlitzModeEnabled && !state.isGameOver) {
      _blitzTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        add(const BlitzTimerTickedEvent());
      });
    }
  }

  void _stopBlitzTimer() {
    _blitzTimer?.cancel();
    _blitzTimer = null;
  }

  @override
  Future<void> close() {
    _stopBlitzTimer();
    return super.close();
  }
}
