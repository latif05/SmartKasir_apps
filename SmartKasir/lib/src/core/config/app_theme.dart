import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006CFF)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
      );
}
