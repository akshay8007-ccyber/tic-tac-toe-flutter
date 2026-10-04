enum Player {
  x('X'),
  o('O');

  final String label;
  const Player(this.label);

  Player get opponent => this == Player.x ? Player.o : Player.x;
}
