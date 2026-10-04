import 'dart:math';

import '../../data/models/player_model.dart';
import '../logic/game_rules.dart';

class AiMoveChoice {
  final int? fromIndex;
  final int toIndex;

  AiMoveChoice({this.fromIndex, required this.toIndex});
}

/// Unbeatable Minimax AI Engine supporting 3-Mark Placement & Movement mechanics.
class AiBotEngine {
  AiBotEngine._();

  static final Random _random = Random();

  static AiMoveChoice? findBestMove({
    required List<Player?> board,
    required Map<Player, List<int>> markPositions,
    required Player aiPlayer,
    required bool isHardMode,
  }) {
    final aiPositions = markPositions[aiPlayer] ?? [];

    if (aiPositions.length < GameRules.maxMarksPerPlayer) {
      return _getPlacementMove(board, markPositions, aiPlayer, isHardMode);
    } else {
      return _getMovementMove(board, markPositions, aiPlayer, isHardMode);
    }
  }

  // --- Placement Phase Logic ---

  static AiMoveChoice? _getPlacementMove(
    List<Player?> board,
    Map<Player, List<int>> markPositions,
    Player aiPlayer,
    bool isHardMode,
  ) {
    final emptyIndices = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == null) emptyIndices.add(i);
    }

    if (emptyIndices.isEmpty) return null;

    if (!isHardMode) {
      final randomIndex = emptyIndices[_random.nextInt(emptyIndices.length)];
      return AiMoveChoice(toIndex: randomIndex);
    }

    final humanPlayer = aiPlayer.opponent;
    final aiPositions = markPositions[aiPlayer] ?? [];
    final humanPositions = markPositions[humanPlayer] ?? [];

    // 1. Immediate Win
    for (final emptyIdx in emptyIndices) {
      if (GameRules.checkWinner([...aiPositions, emptyIdx], aiPlayer).hasWinner) {
        return AiMoveChoice(toIndex: emptyIdx);
      }
    }

    // 2. Immediate Block
    for (final emptyIdx in emptyIndices) {
      if (GameRules.checkWinner([...humanPositions, emptyIdx], humanPlayer).hasWinner) {
        return AiMoveChoice(toIndex: emptyIdx);
      }
    }

    // 3. Minimax Placement Search
    int bestScore = -999;
    int bestMove = emptyIndices.first;

    for (final emptyIdx in emptyIndices) {
      final newAiPos = [...aiPositions, emptyIdx];
      final score = _minimaxPlacement(
        board: board,
        aiPositions: newAiPos,
        humanPositions: humanPositions,
        isAiTurn: false,
        depth: 0,
        alpha: -1000,
        beta: 1000,
        aiPlayer: aiPlayer,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMove = emptyIdx;
      }
    }

    return AiMoveChoice(toIndex: bestMove);
  }

  static int _minimaxPlacement({
    required List<Player?> board,
    required List<int> aiPositions,
    required List<int> humanPositions,
    required bool isAiTurn,
    required int depth,
    required int alpha,
    required int beta,
    required Player aiPlayer,
  }) {
    final humanPlayer = aiPlayer.opponent;

    if (GameRules.checkWinner(aiPositions, aiPlayer).hasWinner) {
      return 10 - depth;
    }
    if (GameRules.checkWinner(humanPositions, humanPlayer).hasWinner) {
      return depth - 10;
    }

    final occupied = {...aiPositions, ...humanPositions};
    final emptyIndices = [0, 1, 2, 3, 4, 5, 6, 7, 8]
        .where((idx) => !occupied.contains(idx))
        .toList();

    if (emptyIndices.isEmpty || depth >= 5) return 0;

    if (isAiTurn) {
      int maxEval = -1000;
      for (final idx in emptyIndices) {
        final eval = _minimaxPlacement(
          board: board,
          aiPositions: [...aiPositions, idx],
          humanPositions: humanPositions,
          isAiTurn: false,
          depth: depth + 1,
          alpha: alpha,
          beta: beta,
          aiPlayer: aiPlayer,
        );
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 1000;
      for (final idx in emptyIndices) {
        final eval = _minimaxPlacement(
          board: board,
          aiPositions: aiPositions,
          humanPositions: [...humanPositions, idx],
          isAiTurn: true,
          depth: depth + 1,
          alpha: alpha,
          beta: beta,
          aiPlayer: aiPlayer,
        );
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  // --- Movement Phase Logic ---

  static AiMoveChoice? _getMovementMove(
    List<Player?> board,
    Map<Player, List<int>> markPositions,
    Player aiPlayer,
    bool isHardMode,
  ) {
    final aiPositions = List<int>.from(markPositions[aiPlayer] ?? []);
    final humanPlayer = aiPlayer.opponent;
    final humanPositions = List<int>.from(markPositions[humanPlayer] ?? []);

    final emptyIndices = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == null) emptyIndices.add(i);
    }

    if (emptyIndices.isEmpty || aiPositions.isEmpty) return null;

    if (!isHardMode) {
      final fromIdx = aiPositions[_random.nextInt(aiPositions.length)];
      final toIdx = emptyIndices[_random.nextInt(emptyIndices.length)];
      return AiMoveChoice(fromIndex: fromIdx, toIndex: toIdx);
    }

    // 1. Immediate Win
    for (final fromIdx in aiPositions) {
      for (final toIdx in emptyIndices) {
        final testPositions = List<int>.from(aiPositions)
          ..remove(fromIdx)
          ..add(toIdx);
        if (GameRules.checkWinner(testPositions, aiPlayer).hasWinner) {
          return AiMoveChoice(fromIndex: fromIdx, toIndex: toIdx);
        }
      }
    }

    // 2. Block Opponent's Immediate Win
    for (final humanFrom in humanPositions) {
      for (final toIdx in emptyIndices) {
        final testHumanPos = List<int>.from(humanPositions)
          ..remove(humanFrom)
          ..add(toIdx);
        if (GameRules.checkWinner(testHumanPos, humanPlayer).hasWinner) {
          // Block by moving an AI piece into toIdx
          for (final aiFrom in aiPositions) {
            return AiMoveChoice(fromIndex: aiFrom, toIndex: toIdx);
          }
        }
      }
    }

    // 3. Minimax Movement Search
    int bestScore = -999;
    AiMoveChoice? bestChoice;

    for (final fromIdx in aiPositions) {
      for (final toIdx in emptyIndices) {
        final nextAiPos = List<int>.from(aiPositions)
          ..remove(fromIdx)
          ..add(toIdx);

        final score = _minimaxMovement(
          aiPositions: nextAiPos,
          humanPositions: humanPositions,
          isAiTurn: false,
          depth: 0,
          alpha: -1000,
          beta: 1000,
          aiPlayer: aiPlayer,
        );

        if (score > bestScore) {
          bestScore = score;
          bestChoice = AiMoveChoice(fromIndex: fromIdx, toIndex: toIdx);
        }
      }
    }

    return bestChoice ??
        AiMoveChoice(
          fromIndex: aiPositions[_random.nextInt(aiPositions.length)],
          toIndex: emptyIndices[_random.nextInt(emptyIndices.length)],
        );
  }

  static int _minimaxMovement({
    required List<int> aiPositions,
    required List<int> humanPositions,
    required bool isAiTurn,
    required int depth,
    required int alpha,
    required int beta,
    required Player aiPlayer,
  }) {
    final humanPlayer = aiPlayer.opponent;

    if (GameRules.checkWinner(aiPositions, aiPlayer).hasWinner) {
      return 10 - depth;
    }
    if (GameRules.checkWinner(humanPositions, humanPlayer).hasWinner) {
      return depth - 10;
    }

    if (depth >= 4) return 0;

    final occupied = {...aiPositions, ...humanPositions};
    final emptyIndices = [0, 1, 2, 3, 4, 5, 6, 7, 8]
        .where((idx) => !occupied.contains(idx))
        .toList();

    if (isAiTurn) {
      int maxEval = -1000;
      for (final fromIdx in aiPositions) {
        for (final toIdx in emptyIndices) {
          final nextAiPos = List<int>.from(aiPositions)
            ..remove(fromIdx)
            ..add(toIdx);

          final eval = _minimaxMovement(
            aiPositions: nextAiPos,
            humanPositions: humanPositions,
            isAiTurn: false,
            depth: depth + 1,
            alpha: alpha,
            beta: beta,
            aiPlayer: aiPlayer,
          );
          maxEval = max(maxEval, eval);
          alpha = max(alpha, eval);
          if (beta <= alpha) break;
        }
      }
      return maxEval;
    } else {
      int minEval = 1000;
      for (final fromIdx in humanPositions) {
        for (final toIdx in emptyIndices) {
          final nextHumanPos = List<int>.from(humanPositions)
            ..remove(fromIdx)
            ..add(toIdx);

          final eval = _minimaxMovement(
            aiPositions: aiPositions,
            humanPositions: nextHumanPos,
            isAiTurn: true,
            depth: depth + 1,
            alpha: alpha,
            beta: beta,
            aiPlayer: aiPlayer,
          );
          minEval = min(minEval, eval);
          beta = min(beta, eval);
          if (beta <= alpha) break;
        }
      }
      return minEval;
    }
  }
}
