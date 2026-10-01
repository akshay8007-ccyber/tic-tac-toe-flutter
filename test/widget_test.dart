import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/main.dart';

void main() {
  testWidgets('TicTacToeApp renders successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());
    expect(find.text('Tic Tac Toe'), findsOneWidget);
  });
}
