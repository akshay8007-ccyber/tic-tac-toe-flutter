import '../models/player.dart';

/// Result of a win-check.
class GameResult {
  final bool hasWinner;
  final Player? winner;
  final List<int>? winningLine;

  const GameResult({this.hasWinner = false, this.winner, this.winningLine});
}

/// Pure, stateless game rules for the "moving" 3x3 Tic-Tac-Toe variant.
///
/// This class holds no mutable state — it only knows the board
/// dimensions, the max-marks rule, and how to detect a winning line.
/// All mutable game state lives in [GameController].
class GameLogic {
  GameLogic._();

  static const int boardSize = 9;
  static const int maxMarksPerPlayer = 3;

  /// All possible winning combinations: 3 rows, 3 columns, 2 diagonals.
  static const List<List<int>> winningCombinations = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  /// Checks whether [positions] (a player's currently active cell indices)
  /// exactly matches one of the winning combinations.
  ///
  /// Because a player can never have more than [maxMarksPerPlayer] marks
  /// on the board, a win is only possible once they have exactly 3 active
  /// marks and those 3 marks line up.
  static GameResult checkWinner(List<int> positions, Player player) {
    if (positions.length < maxMarksPerPlayer) return const GameResult();

    final sortedPositions = List<int>.from(positions)..sort();

    for (final combo in winningCombinations) {
      final sortedCombo = List<int>.from(combo)..sort();
      if (_listEquals(sortedPositions, sortedCombo)) {
        return GameResult(hasWinner: true, winner: player, winningLine: combo);
      }
    }

    return const GameResult();
  }

  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
