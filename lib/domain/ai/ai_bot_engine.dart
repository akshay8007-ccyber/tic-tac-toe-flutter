import 'dart:math';

import '../../data/models/player_model.dart';
import '../logic/game_rules.dart';

class AiMoveChoice {
  final int? fromIndex;
  final int toIndex;

  AiMoveChoice({this.fromIndex, required this.toIndex});
}

class AiBotEngine {
  AiBotEngine._();

  static final Random _random = Random();

  static AiMoveChoice? findBestMove({
    required List<Player?> board,
    required Map<Player, List<int>> markPositions,
    required Player aiPlayer,
    required bool isHardMode,
  }) {
    final humanPlayer = aiPlayer.opponent;
    final aiPositions = markPositions[aiPlayer] ?? [];

    if (aiPositions.length < GameRules.maxMarksPerPlayer) {
      return _findPlacementMove(board, markPositions, aiPlayer, humanPlayer, isHardMode);
    } else {
      return _findMovementMove(board, markPositions, aiPlayer, humanPlayer, isHardMode);
    }
  }

  static AiMoveChoice? _findPlacementMove(
    List<Player?> board,
    Map<Player, List<int>> markPositions,
    Player aiPlayer,
    Player humanPlayer,
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

    // 1. Check for immediate winning placement
    final aiPositions = markPositions[aiPlayer]!;
    for (final emptyIdx in emptyIndices) {
      final testPositions = [...aiPositions, emptyIdx];
      if (GameRules.checkWinner(testPositions, aiPlayer).hasWinner) {
        return AiMoveChoice(toIndex: emptyIdx);
      }
    }

    // 2. Block human player's winning placement
    final humanPositions = markPositions[humanPlayer]!;
    for (final emptyIdx in emptyIndices) {
      final testPositions = [...humanPositions, emptyIdx];
      if (GameRules.checkWinner(testPositions, humanPlayer).hasWinner) {
        return AiMoveChoice(toIndex: emptyIdx);
      }
    }

    // 3. Prefer center
    if (emptyIndices.contains(4)) {
      return AiMoveChoice(toIndex: 4);
    }

    // 4. Prefer corners
    final corners = [0, 2, 6, 8].where((c) => emptyIndices.contains(c)).toList();
    if (corners.isNotEmpty) {
      return AiMoveChoice(toIndex: corners[_random.nextInt(corners.length)]);
    }

    return AiMoveChoice(toIndex: emptyIndices[_random.nextInt(emptyIndices.length)]);
  }

  static AiMoveChoice? _findMovementMove(
    List<Player?> board,
    Map<Player, List<int>> markPositions,
    Player aiPlayer,
    Player humanPlayer,
    bool isHardMode,
  ) {
    final aiPositions = List<int>.from(markPositions[aiPlayer]!);
    final emptyIndices = <int>[];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == null) emptyIndices.add(i);
    }

    if (emptyIndices.isEmpty) return null;

    if (!isHardMode) {
      final fromIdx = aiPositions[_random.nextInt(aiPositions.length)];
      final toIdx = emptyIndices[_random.nextInt(emptyIndices.length)];
      return AiMoveChoice(fromIndex: fromIdx, toIndex: toIdx);
    }

    // 1. Winning move check
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

    // 2. Block human player from winning on their next turn
    final humanPositions = markPositions[humanPlayer]!;
    for (final emptyIdx in emptyIndices) {
      final testPositions = [...humanPositions, emptyIdx];
      if (GameRules.checkWinner(testPositions, humanPlayer).hasWinner) {
        final fromIdx = aiPositions[_random.nextInt(aiPositions.length)];
        return AiMoveChoice(fromIndex: fromIdx, toIndex: emptyIdx);
      }
    }

    // 3. Fallback heuristic
    final fromIdx = aiPositions[_random.nextInt(aiPositions.length)];
    final toIdx = emptyIndices[_random.nextInt(emptyIndices.length)];
    return AiMoveChoice(fromIndex: fromIdx, toIndex: toIdx);
  }
}
