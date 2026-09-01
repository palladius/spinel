import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SpinelTheme {
  static const Color darkBase = Color(0xFF0F0F12);
  static const Color darkSurface = Color(0xFF16161A);
  static const Color darkSidebar = Color(0xFF131316);
  static const Color darkCard = Color(0xFF1E1E24);
  static const Color rubyAccent = Color(0xFFE0115F);
  static const Color rubyGlow = Color(0xFFD81159);
  static const Color slateText = Color(0xFF94A1B2);
  static const Color brightText = Color(0xFFFFFFFE);
  static const Color borderColor = Color(0xFF2E2F3E);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBase,
      primaryColor: rubyAccent,
      colorScheme: const ColorScheme.dark(
        primary: rubyAccent,
        secondary: rubyGlow,
        surface: darkSurface,
        onSurface: brightText,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: brightText,
          displayColor: brightText,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: brightText,
          fontSize: 16,
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
