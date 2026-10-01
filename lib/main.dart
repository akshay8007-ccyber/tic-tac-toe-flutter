import 'package:flutter/material.dart';

import 'game/game_controller.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatefulWidget {
  const TicTacToeApp({super.key});

  @override
  State<TicTacToeApp> createState() => _TicTacToeAppState();
}

class _TicTacToeAppState extends State<TicTacToeApp> {
  final GameController _gameController = GameController();

  @override
  void initState() {
    super.initState();
    _gameController.addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    _gameController.removeListener(_onControllerChanged);
    _gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _gameController.isDarkMode;

    final lightColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.light,
    );

    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFD0BCFF),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      title: 'Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        scaffoldBackgroundColor: const Color(0xFFF6F5FA),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        scaffoldBackgroundColor: const Color(0xFF141218),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: GameScreen(controller: _gameController),
    );
  }
}
