import 'package:flutter/material.dart';

import 'package:kokotoba_flutter_app/ui/theme/color.dart';
import 'package:kokotoba_flutter_app/ui/theme/type.dart';

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
    textTheme: kokotobaTextTheme(),
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
