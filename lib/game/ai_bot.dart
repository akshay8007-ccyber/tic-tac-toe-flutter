import 'dart:math';

import '../models/player.dart';
import 'game_logic.dart';

/// Represents a move: placing at [toIndex], optionally moving from [fromIndex].
class MoveChoice {
  final int? fromIndex;
  final int toIndex;

  const MoveChoice({this.fromIndex, required this.toIndex});
}

/// AI Bot adapted for the interactive "Select & Move" Tic Tac Toe rule.
class AiBot {
  static final Random _random = Random();

  /// Finds the best [MoveChoice] for [aiPlayer].
  static MoveChoice? findBestMove({
    required List<Player?> board,
    required Map<Player, List<int>> markPositions,
    required Player aiPlayer,
    required bool isHardMode,
  }) {
    final possibleMoves = _generatePossibleMoves(board, markPositions, aiPlayer);
    if (possibleMoves.isEmpty) return null;

    // Easy mode random selection (45% chance)
    if (!isHardMode && _random.nextDouble() < 0.45) {
      return possibleMoves[_random.nextInt(possibleMoves.length)];
    }

    // 1. Instant win check
    for (final move in possibleMoves) {
      if (_isWinningMove(markPositions, aiPlayer, move)) {
        return move;
      }
    }

    // 2. Instant block check (opponent's winning move)
    final opponent = aiPlayer.opponent;
    final opponentMoves = _generatePossibleMoves(board, markPositions, opponent);
    for (final oppMove in opponentMoves) {
      if (_isWinningMove(markPositions, opponent, oppMove)) {
        // Find an AI move that blocks or moves smartly
        final blockingMove = possibleMoves.firstWhere(
          (m) => m.toIndex == oppMove.toIndex,
          orElse: () => possibleMoves.first,
        );
        return blockingMove;
      }
    }

    // 3. Minimax search over choices
    int bestScore = -99999;
    MoveChoice bestMove = possibleMoves[_random.nextInt(possibleMoves.length)];

    for (final move in possibleMoves) {
      final newBoard = List<Player?>.from(board);
      final newPositions = {
        Player.x: List<int>.from(markPositions[Player.x]!),
        Player.o: List<int>.from(markPositions[Player.o]!),
      };

      _simulateMove(newBoard, newPositions, aiPlayer, move);

      final score = _minimax(
        board: newBoard,
        markPositions: newPositions,
        turnPlayer: opponent,
        aiPlayer: aiPlayer,
        depth: 0,
        maxDepth: 4,
        alpha: -100000,
        beta: 100000,
      );

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove;
  }

  static List<MoveChoice> _generatePossibleMoves(
    List<Player?> board,
    Map<Player, List<int>> markPositions,
    Player player,
  ) {
    final emptyIndices = <int>[];
    for (var i = 0; i < board.length; i++) {
      if (board[i] == null) emptyIndices.add(i);
    }

    final playerPositions = markPositions[player]!;
    final moves = <MoveChoice>[];

    if (playerPositions.length < GameLogic.maxMarksPerPlayer) {
      // Placement phase
      for (final emptyIdx in emptyIndices) {
        moves.add(MoveChoice(toIndex: emptyIdx));
      }
    } else {
      // Movement phase: choose any of 3 current marks to move to any empty spot
      for (final fromIdx in playerPositions) {
        for (final emptyIdx in emptyIndices) {
          moves.add(MoveChoice(fromIndex: fromIdx, toIndex: emptyIdx));
        }
      }
    }

    return moves;
  }

  static bool _isWinningMove(
    Map<Player, List<int>> markPositions,
    Player player,
    MoveChoice move,
  ) {
    final tempPositions = List<int>.from(markPositions[player]!);
    if (move.fromIndex != null) {
      tempPositions.remove(move.fromIndex);
    }
    tempPositions.add(move.toIndex);

    return GameLogic.checkWinner(tempPositions, player).hasWinner;
  }

  static void _simulateMove(
    List<Player?> board,
    Map<Player, List<int>> markPositions,
    Player player,
    MoveChoice move,
  ) {
    final positions = markPositions[player]!;
    if (move.fromIndex != null) {
      positions.remove(move.fromIndex);
      board[move.fromIndex!] = null;
    }
    positions.add(move.toIndex);
    board[move.toIndex] = player;
  }

  static int _minimax({
    required List<Player?> board,
    required Map<Player, List<int>> markPositions,
    required Player turnPlayer,
    required Player aiPlayer,
    required int depth,
    required int maxDepth,
    required int alpha,
    required int beta,
  }) {
    final opponent = aiPlayer.opponent;

    if (GameLogic.checkWinner(markPositions[aiPlayer]!, aiPlayer).hasWinner) {
      return 100 - depth;
    }
    if (GameLogic.checkWinner(markPositions[opponent]!, opponent).hasWinner) {
      return depth - 100;
    }
    if (depth >= maxDepth) {
      return _evaluateBoard(markPositions, aiPlayer);
    }

    final moves = _generatePossibleMoves(board, markPositions, turnPlayer);
    if (moves.isEmpty) return 0;

    final isAiTurn = turnPlayer == aiPlayer;

    if (isAiTurn) {
      int maxEval = -99999;
      for (final move in moves) {
        final newBoard = List<Player?>.from(board);
        final newPositions = {
          Player.x: List<int>.from(markPositions[Player.x]!),
          Player.o: List<int>.from(markPositions[Player.o]!),
        };

        _simulateMove(newBoard, newPositions, aiPlayer, move);

        final eval = _minimax(
          board: newBoard,
          markPositions: newPositions,
          turnPlayer: opponent,
          aiPlayer: aiPlayer,
          depth: depth + 1,
          maxDepth: maxDepth,
          alpha: alpha,
          beta: beta,
        );

        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 99999;
      for (final move in moves) {
        final newBoard = List<Player?>.from(board);
        final newPositions = {
          Player.x: List<int>.from(markPositions[Player.x]!),
          Player.o: List<int>.from(markPositions[Player.o]!),
        };

        _simulateMove(newBoard, newPositions, opponent, move);

        final eval = _minimax(
          board: newBoard,
          markPositions: newPositions,
          turnPlayer: aiPlayer,
          aiPlayer: aiPlayer,
          depth: depth + 1,
          maxDepth: maxDepth,
          alpha: alpha,
          beta: beta,
        );

        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  static int _evaluateBoard(
    Map<Player, List<int>> markPositions,
    Player aiPlayer,
  ) {
    final opponent = aiPlayer.opponent;
    int aiLines = _countPotentialLines(markPositions[aiPlayer]!);
    int oppLines = _countPotentialLines(markPositions[opponent]!);
    return aiLines * 5 - oppLines * 5;
  }

  static int _countPotentialLines(List<int> positions) {
    if (positions.length < 2) return 0;
    int score = 0;
    for (final combo in GameLogic.winningCombinations) {
      int matchCount = 0;
      for (final pos in positions) {
        if (combo.contains(pos)) matchCount++;
      }
      if (matchCount == 2) score++;
    }
    return score;
  }
}
