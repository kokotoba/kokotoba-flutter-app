import 'package:flutter/material.dart';

const rose700 = Color(0xFFA34E4A);
const rose600 = Color(0xFFB85F5A);
const rose100 = Color(0xFFF2D6D3);
const rose050 = Color(0xFFFBE9E7);
const ink = Color(0xFF2B201F);
const mutedInk = Color(0xFF665552);
const warmWhite = Color(0xFFFFFAF9);
const softSurface = Color(0xFFF8F0EF);
const outline = Color(0xFFBDA5A2);

ThemeData kokotobaTheme() {
  final scheme = const ColorScheme.light(
    primary: rose700,
    onPrimary: warmWhite,
    primaryContainer: rose050,
    onPrimaryContainer: ink,
    secondary: rose600,
    onSecondary: warmWhite,
    secondaryContainer: rose100,
    onSecondaryContainer: ink,
    surface: warmWhite,
    onSurface: ink,
    surfaceContainerHighest: softSurface,
    onSurfaceVariant: mutedInk,
    outline: outline,
    outlineVariant: Color(0xFFE6D4D2),
    error: Color(0xFF8F3037),
    errorContainer: Color(0xFFFFE8E9),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: warmWhite,
    fontFamilyFallback: const ['Hiragino Sans', 'Noto Sans JP'],
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        height: 1.27,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        height: 1.33,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.4,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        fontSize: 17,
        height: 1.41,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(fontSize: 17, height: 1.53),
      bodyMedium: TextStyle(fontSize: 15, height: 1.47),
      labelLarge: TextStyle(
        fontSize: 15,
        height: 1.33,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: softSurface,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: rose700,
        foregroundColor: warmWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: rose700,
        side: const BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
  );
}
