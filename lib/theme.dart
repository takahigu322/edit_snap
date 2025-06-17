import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF00838F), // Teal
    secondary: const Color(0xFFFF6B35), // Orange accent
    tertiary: const Color(0xFF6C63FF), // Purple accent
    surface: const Color(0xFFF8F9FA),
    error: const Color(0xFFE53E3E),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onTertiary: Colors.white,
    onSurface: const Color(0xFF1A202C),
    onError: Colors.white,
    outline: const Color(0xFFE2E8F0),
  ),
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF8F9FA),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 57.0,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.25,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 45.0,
      fontWeight: FontWeight.w300,
      letterSpacing: 0.0,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 36.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
    ),
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 28.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.0,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.0,
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 22.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.0,
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 11.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
    ),
  ),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF26D0CE), // Bright teal
    secondary: Color(0xFFFF8A50), // Warm orange
    tertiary: Color(0xFF9C88FF), // Light purple
    surface: Color(0xFF0D1117), // GitHub dark
    surfaceContainerHighest: Color(0xFF161B22), // Elevated surface
    error: Color(0xFFFF6B6B),
    onPrimary: Color(0xFF003337),
    onSecondary: Color(0xFF2D1B00),
    onTertiary: Color(0xFF1A0E4F),
    onSurface: Color(0xFFE6EDF3),
    onError: Color(0xFF2D0000),
    outline: Color(0xFF30363D),
    outlineVariant: Color(0xFF21262D),
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0D1117),
  cardColor: const Color(0xFF161B22),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 57.0,
      fontWeight: FontWeight.w300,
      letterSpacing: -0.25,
      color: const Color(0xFFE6EDF3),
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 45.0,
      fontWeight: FontWeight.w300,
      letterSpacing: 0.0,
      color: const Color(0xFFE6EDF3),
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 36.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
      color: const Color(0xFFE6EDF3),
    ),
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.0,
      color: const Color(0xFFE6EDF3),
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 28.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.0,
      color: const Color(0xFFE6EDF3),
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.0,
      color: const Color(0xFFE6EDF3),
    ),
    titleLarge: GoogleFonts.poppins(
      fontSize: 22.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.0,
      color: const Color(0xFFE6EDF3),
    ),
    titleMedium: GoogleFonts.poppins(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: const Color(0xFFE6EDF3),
    ),
    titleSmall: GoogleFonts.poppins(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: const Color(0xFFE6EDF3),
    ),
    labelLarge: GoogleFonts.poppins(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: const Color(0xFFE6EDF3),
    ),
    labelMedium: GoogleFonts.poppins(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: const Color(0xFFE6EDF3),
    ),
    labelSmall: GoogleFonts.poppins(
      fontSize: 11.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: const Color(0xFFE6EDF3),
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.5,
      color: const Color(0xFFE6EDF3),
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      color: const Color(0xFFE6EDF3),
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      color: const Color(0xFFE6EDF3),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0D1117),
    foregroundColor: Color(0xFFE6EDF3),
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF26D0CE),
      foregroundColor: const Color(0xFF003337),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF26D0CE),
      side: const BorderSide(color: Color(0xFF26D0CE)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFFE6EDF3),
  ),
);