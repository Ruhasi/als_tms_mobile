import 'package:flutter/material.dart';

import '../values/text_styles.dart';

abstract final class TmsColors {
  static const ink = Color(0xFF12151B);
  static const canvas = Color(0xFFF5F4F0);
  static const card = Colors.white;
  static const orange = Color(0xFFEF641D);
  static const muted = Color(0xFF7B7B80);
  static const line = Color(0xFFE5E3DD);
  static const green = Color(0xFF3F9A71);
  static const blue = Color(0xFF5A8EDA);
  static const gold = Color(0xFFD5A841);
  static const red = Color(0xFFD85B58);
  static const textGray = Color(0xFF9A9CA2);
}

ThemeData buildTmsTheme() {
  final styles = AppTextStyles();
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: TmsColors.canvas,
    colorScheme: const ColorScheme.light(
      primary: TmsColors.orange,
      surface: TmsColors.card,
      onSurface: TmsColors.ink,
    ),
    textTheme: TextTheme(
      displaySmall: styles.displaySmall,
      headlineSmall: styles.headlineSmall,
      titleLarge: styles.titleLarge,
      titleMedium: styles.titleMedium,
      bodyMedium: styles.bodyMedium,
      bodySmall: styles.bodySmall,
      labelSmall: styles.labelSmall,
    ),
  );
}
