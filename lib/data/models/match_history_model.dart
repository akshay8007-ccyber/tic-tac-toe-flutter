import 'cell_model.dart';
import 'game_mode_model.dart';
import 'player_model.dart';

class MoveRecord {
  final int moveNumber;
  final Player player;
  final int? fromIndex;
  final int toIndex;
  final List<CellData> boardStateSnapshot;

  MoveRecord({
    required this.moveNumber,
    required this.player,
    this.fromIndex,
    required this.toIndex,
    required this.boardStateSnapshot,
  });
}

class MatchRecord {
  final String id;
  final DateTime timestamp;
  final GameMode gameMode;
  final AiDifficulty? aiDifficulty;
  final Player? winner;
  final List<int>? winningLine;
  final String playerXName;
  final String playerOName;
  final List<MoveRecord> moves;
  final SymbolTheme symbolTheme;

  MatchRecord({
    required this.id,
    required this.timestamp,
    required this.gameMode,
    this.aiDifficulty,
    required this.winner,
    this.winningLine,
    required this.playerXName,
    required this.playerOName,
    required this.moves,
    required this.symbolTheme,
  });

  int get totalMoves => moves.length;
}
