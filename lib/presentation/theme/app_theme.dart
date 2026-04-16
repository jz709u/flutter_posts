import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  /// Brand seed colour used for both light and dark [ColorScheme] generation.
  static const _seedColor = Colors.indigo;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
      );
}
