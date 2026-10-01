import 'player.dart';

/// Represents the state of a single cell on the board.
///
/// [moveId] is a strictly increasing id assigned every time a mark is
/// placed. It is used purely as an animation key so that the UI can
/// detect "this cell's mark changed" (including a fresh mark placed in
/// a cell that was previously occupied by a now-removed mark) and
/// trigger the appear/disappear animation correctly.
class CellData {
  final Player? player;
  final int? moveId;

  const CellData({this.player, this.moveId});

  bool get isEmpty => player == null;
}
