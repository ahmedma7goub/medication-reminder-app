import 'package:flutter/material.dart';

class AppTheme {
  static final Color _lightPrimaryColor = Colors.teal;
  static final Color _darkPrimaryColor = Colors.tealAccent;

  static final ThemeData lightTheme = ThemeData(
    primaryColor: _lightPrimaryColor,
    scaffoldBackgroundColor: Colors.grey[100],
    appBarTheme: AppBarTheme(
      color: _lightPrimaryColor,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
    ),
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      secondary: Colors.tealAccent,
      onPrimary: Colors.white,
      background: Colors.grey[100]!,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
    ),
    fontFamily: 'Cairo',
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      color: const Color(0xFF1F1F1F),
      elevation: 0,
      iconTheme: IconThemeData(color: _darkPrimaryColor),
      titleTextStyle: TextStyle(color: _darkPrimaryColor, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
    ),
    colorScheme: ColorScheme.dark(
      primary: _darkPrimaryColor,
      secondary: Colors.teal,
      onPrimary: Colors.black,
      background: const Color(0xFF121212),
      surface: const Color(0xFF1F1F1F),
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1F1F1F),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
    ),
    fontFamily: 'Cairo',
  );
}
