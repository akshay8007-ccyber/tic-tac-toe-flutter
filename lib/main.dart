import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/game_bloc.dart';
import 'bloc/game_state.dart';
import 'screens/game_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(),
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          final isDark = state.isDarkMode;

          final lightColorScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            tertiary: const Color(0xFFE8873A),
            brightness: Brightness.light,
          );

          final darkColorScheme = ColorScheme.fromSeed(
            seedColor: const Color(0xFFD0BCFF),
            tertiary: const Color(0xFFFFB77C),
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
                backgroundColor: Colors.transparent,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkColorScheme,
              scaffoldBackgroundColor: const Color(0xFF141218),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/home': (context) => const HomeScreen(),
              '/game': (context) => const GameScreen(),
            },
          );
        },
      ),
    );
  }
}
