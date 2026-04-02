import 'package:flutter/material.dart';

class AppPalette {
  const AppPalette._();

  static const olive = Color(0xFF5C6B3A);
  static const moss = Color(0xFF8A9E5B);
  static const tan = Color(0xFFB5885A);
  static const danger = Color(0xFF9C4B4B);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF7F3EE),
    colorScheme: const ColorScheme.light(
      primary: olive,
      secondary: tan,
      surface: Color(0xFFFFFFFF),
      error: danger,
      onSurface: Color(0xFF2C2C2C),
      onSurfaceVariant: Color(0xFF7A7A7A),
      surfaceContainerHighest: Color(0xFFE8D4BE),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme.dark(
      primary: moss,
      secondary: tan,
      surface: Color(0xFF1E1E1E),
      error: Color(0xFFCF6679),
      onSurface: Color(0xFFE0E0E0),
      onSurfaceVariant: Color(0xFFA0A0A0),
      surfaceContainerHighest: Color(0xFF333333),
    ),
    useMaterial3: true,
  );
}
