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
    scaffoldBackgroundColor: const Color(0xFF0F1110),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFA8BC7A),
      secondary: Color(0xFFD1A877),
      surface: Color(0xFF171A18),
      error: Color(0xFFE08C8C),
      onSurface: Color(0xFFF1F4EE),
      onSurfaceVariant: Color(0xFFC2C8BD),
      surfaceContainerHighest: Color(0xFF2A2F2B),
    ),
    useMaterial3: true,
  );
}
