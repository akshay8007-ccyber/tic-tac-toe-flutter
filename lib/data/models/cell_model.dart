import 'player_model.dart';

class CellData {
  final Player? player;
  final int moveId;

  const CellData({this.player, this.moveId = 0});

  bool get isEmpty => player == null;
  bool get isNotEmpty => player != null;

  CellData copyWith({Player? player, int? moveId}) {
    return CellData(
      player: player ?? this.player,
      moveId: moveId ?? this.moveId,
    );
  }
}
