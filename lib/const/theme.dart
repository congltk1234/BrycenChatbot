import 'package:flutter/material.dart';

var kColorScheme =
    ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 0, 205, 14));

final configThemes = ThemeData().copyWith(
    useMaterial3: true,
    // scaffoldBackgroundColor: Colors.amber[200],
    colorScheme: kColorScheme,
    appBarTheme: const AppBarTheme().copyWith(
      backgroundColor: kColorScheme.onPrimaryContainer,
      foregroundColor: kColorScheme.primaryContainer,
    ),
    cardTheme: CardTheme(
      color: kColorScheme.secondaryContainer,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      backgroundColor: kColorScheme.primaryContainer,
    )),
    textTheme: ThemeData().textTheme.copyWith(
            titleLarge: TextStyle(
          fontWeight: FontWeight.bold,
          color: kColorScheme.primary,
          fontSize: 18,
        )));
