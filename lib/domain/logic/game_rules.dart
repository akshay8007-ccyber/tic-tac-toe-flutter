import '../../data/models/player_model.dart';

class GameResult {
  final Player? winner;
  final List<int>? winningLine;

  const GameResult({this.winner, this.winningLine});

  bool get hasWinner => winner != null;
}

class GameRules {
  GameRules._();

  static const int boardSize = 9;
  static const int maxMarksPerPlayer = 3;

  static const List<List<int>> winningCombinations = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // Rows
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // Columns
    [0, 4, 8], [2, 4, 6],           // Diagonals
  ];

  static GameResult checkWinner(List<int> markPositions, Player player) {
    if (markPositions.length < 3) return const GameResult();

    for (final combo in winningCombinations) {
      if (combo.every((pos) => markPositions.contains(pos))) {
        return GameResult(winner: player, winningLine: combo);
      }
    }

    return const GameResult();
  }
}
