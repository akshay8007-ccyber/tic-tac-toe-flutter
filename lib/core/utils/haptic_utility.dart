import 'package:flutter/services.dart';

class HapticUtility {
  HapticUtility._();

  static void light({required bool enabled}) {
    if (enabled) HapticFeedback.lightImpact();
  }

  static void medium({required bool enabled}) {
    if (enabled) HapticFeedback.mediumImpact();
  }

  static void heavy({required bool enabled}) {
    if (enabled) HapticFeedback.heavyImpact();
  }

  static void selection({required bool enabled}) {
    if (enabled) HapticFeedback.selectionClick();
  }
}
