import 'package:flutter/material.dart';

class SpinelTheme {
  // Deep royal ruby and obsidian palette
  static const Color darkBase = Color(0xFF0D0D11);
  static const Color darkCanvas = Color(0xFF0D0D11);
  static const Color darkSurface = Color(0xFF15151B);
  static const Color darkSidebar = Color(0xFF111116);
  static const Color darkCard = Color(0xFF1C1C24);
  static const Color darkInput = Color(0xFF181820);
  
  // Authentic Deep Ruby / Crimson
  static const Color rubyPrimary = Color(0xFFA61C2E);  // Imperial dark ruby
  static const Color rubyAccent = Color(0xFF8B0000);   // Deep blood ruby
  static const Color rubyBright = Color(0xFFB31B1B);   // Garnet / rich crimson
  static const Color rubyLight = Color(0xFFD9384E);    // Bright ruby highlight
  static const Color rubyMuted = Color(0xFF5A0E17);    // Subtle ruby tint

  static const Color slateText = Color(0xFF8E8E9A);
  static const Color brightText = Color(0xFFEDEDF0);
  static const Color borderColor = Color(0xFF262630);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBase,
      primaryColor: rubyPrimary,
      colorScheme: const ColorScheme.dark(
        primary: rubyPrimary,
        secondary: rubyBright,
        surface: darkSurface,
        onSurface: brightText,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 14, color: brightText),
        bodyLarge: TextStyle(fontSize: 16, color: brightText),
        bodySmall: TextStyle(fontSize: 12, color: slateText),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: brightText),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: brightText),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSidebar,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: brightText,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: borderColor),
        ),
      ),
    );
  }
}
