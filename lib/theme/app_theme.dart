import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// WhatsApp-inspired theme (Light + Dark) for SafeTalk
/// Uses Google Fonts 'Roboto' — closest clean match to WhatsApp's UI font.
class AppTheme {
  AppTheme._(); // prevent instantiation

  // ---------- Brand Colors (WhatsApp style) ----------
  static const Color waGreen = Color(0xFF128C7E); // primary teal-green
  static const Color waGreenDark = Color(0xFF075E54); // darker app bar green
  static const Color waLightGreen = Color(0xFF25D366); // accent / FAB green
  static const Color waTealLight = Color(
    0xFFDCF8C6,
  ); // sent message bubble (light)

  // Dark mode surface colors (WhatsApp dark)
  static const Color darkBackground = Color(0xFF0B141A); // chat background
  static const Color darkSurface = Color(0xFF111B21); // scaffold / cards
  static const Color darkAppBar = Color(0xFF1F2C34); // app bar / bottom bar
  static const Color darkBubbleSent = Color(0xFF005C4B); // sent message bubble
  static const Color darkBubbleReceived = Color(0xFF1F2C34); // received bubble
  static const Color darkDivider = Color(0xFF2A3942);

  // ---------- LIGHT THEME ----------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: waGreen,
      scaffoldBackgroundColor: const Color(
        0xFFECE5DD,
      ), // WhatsApp chat wallpaper tone
      colorScheme: ColorScheme.light(
        primary: waGreen,
        secondary: waLightGreen,
        surface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: waGreenDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: waLightGreen,
        foregroundColor: Colors.white,
      ),
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE0E0E0),
      textTheme: GoogleFonts.robotoTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: waGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  // ---------- DARK THEME ----------
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: waGreen,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: waGreen,
        secondary: waLightGreen,
        surface: darkSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkAppBar,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white70),
        titleTextStyle: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: waLightGreen,
        foregroundColor: Colors.black,
      ),
      cardColor: darkAppBar,
      dividerColor: darkDivider,
      textTheme: GoogleFonts.robotoTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkAppBar,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.white38),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: waGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      bottomAppBarTheme: const BottomAppBarThemeData(
        // ✅
        color: darkAppBar,
      ),
    );
  }

  // ---------- Helper: Chat bubble colors (use directly in chat widget) ----------
  static Color sentBubbleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBubbleSent
        : waTealLight;
  }

  static Color receivedBubbleColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBubbleReceived
        : Colors.white;
  }
}
