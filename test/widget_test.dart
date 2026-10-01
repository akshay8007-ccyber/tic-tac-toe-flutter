import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe/main.dart';

void main() {
  testWidgets('TicTacToeApp renders splash screen successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const TicTacToeApp());
    expect(find.text('TIC TAC TOE'), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);
  });
}
