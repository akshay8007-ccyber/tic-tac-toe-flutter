import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color seedLight = Color(0xFF6750A4);
  static const Color seedDark = Color(0xFFD0BCFF);

  static const Color tertiaryLight = Color(0xFFE8873A);
  static const Color tertiaryDark = Color(0xFFFFB77C);

  static const Color bgLight = Color(0xFFF6F5FA);
  static const Color bgDark = Color(0xFF141218);

  static const Color amberAccent = Colors.amber;
  static const Color greenAccent = Color(0xFF2E7D32);
  static const Color redAccent = Color(0xFFE53935);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [seedLight, tertiaryLight],
  );
}
