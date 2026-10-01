/// Represents the two players in the game.
enum Player { x, o }

extension PlayerExtension on Player {
  /// The display label used on the board ("X" or "O").
  String get label => this == Player.x ? 'X' : 'O';

  /// The other player — used to switch turns.
  Player get opponent => this == Player.x ? Player.o : Player.x;
}
