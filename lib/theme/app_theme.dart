import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _darkPrimaryColor = Color(0xFF4DB6AC); // A softer teal
  static const Color _darkAccentColor = Color(0xFF69F0AE); // A vibrant green
  static const Color _darkBackgroundColor = Color(0xFF1A1C1E);
  static const Color _darkCardColor = Color(0xFF25282D);
  static const Color _darkTextColor = Color(0xFFE3E3E3);
  static const Color _darkSecondaryTextColor = Color(0xFFA9B4BE);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF00897B),
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    fontFamily: 'Cairo',
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF00897B), // Teal
      secondary: Color(0xFF00BFA5), // Teal Accent
      surface: Colors.white,
      background: Color(0xFFF5F5F5),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.black,
      error: Colors.redAccent,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0, color: Colors.black87),
      bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black54),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF00897B),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: _darkBackgroundColor,
    fontFamily: 'Cairo',
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      secondary: _darkAccentColor,
      surface: _darkCardColor,
      background: _darkBackgroundColor,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: _darkTextColor,
      onBackground: _darkTextColor,
      error: Colors.redAccent,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: _darkCardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0, color: _darkTextColor),
      bodyLarge: TextStyle(fontSize: 16.0, color: _darkTextColor),
      bodyMedium: TextStyle(fontSize: 14.0, color: _darkSecondaryTextColor),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkCardColor, 
      selectedItemColor: _darkPrimaryColor,
      unselectedItemColor: _darkSecondaryTextColor,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
    ),
  );
}
