import 'package:flutter/material.dart';

class SpinelTheme {
  // Ultra-refined Obsidian & Deep Ruby Palette
  static const Color darkBase = Color(0xFF0F0F13);
  static const Color darkCanvas = Color(0xFF131318);
  static const Color darkSurface = Color(0xFF16161D);
  static const Color darkSidebar = Color(0xFF111116);
  static const Color darkCard = Color(0xFF1A1A22);
  static const Color darkInput = Color(0xFF17171F);
  
  // Refined Jewel Ruby Accents (subtle, elegant, never screaming)
  static const Color rubyPrimary = Color(0xFF9E1B32);  // Rich Crimson Ruby
  static const Color rubyAccent = Color(0xFF7A1526);   // Deep Garnet
  static const Color rubyBright = Color(0xFFB8263E);   // Jewel Accent
  static const Color rubyLight = Color(0xFFD4435B);    // Subtle highlight
  static const Color rubyMuted = Color(0xFF3D0E16);    // Background tint

  // Neutral UI Grays
  static const Color slateMuted = Color(0xFF555562);
  static const Color slateText = Color(0xFF8E8E9B);
  static const Color softText = Color(0xFFB4B4C0);
  static const Color brightText = Color(0xFFEDEDF2);
  static const Color borderColor = Color(0xFF22222C);

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
        bodyMedium: TextStyle(fontSize: 13.5, color: brightText),
        bodyLarge: TextStyle(fontSize: 15, color: brightText),
        bodySmall: TextStyle(fontSize: 11.5, color: slateText),
        titleMedium: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: brightText),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: brightText),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSidebar,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: brightText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
        iconColor: slateText,
        collapsedIconColor: slateText,
        textColor: brightText,
        collapsedTextColor: softText,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: borderColor),
        ),
      ),
    );
  }
}
