import 'package:flutter/material.dart';

TextTheme kokotobaTextTheme() {
  return const TextTheme(
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
  );
}
