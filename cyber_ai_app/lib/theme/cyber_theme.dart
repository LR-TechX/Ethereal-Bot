import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildCyberTheme() {
  const neonGreen = Color(0xFF00FF9C);
  const neonBlue = Color(0xFF00C6FF);
  const bg = Color(0xFF0B0F14);
  const surface = Color(0xFF111923);

  final base = ThemeData.dark(useMaterial3: true);
  final textTheme = base.textTheme.apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ).copyWith(
    headlineSmall: GoogleFonts.robotoMono(
      color: neonGreen,
      fontWeight: FontWeight.w700,
    ),
    titleLarge: GoogleFonts.robotoMono(
      color: neonBlue,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: GoogleFonts.inter(
      color: Colors.white,
    ),
  );

  final colorScheme = ColorScheme.fromSeed(
    seedColor: neonGreen,
    brightness: Brightness.dark,
    background: bg,
    surface: surface,
    onSurface: Colors.white,
    primary: neonGreen,
    secondary: neonBlue,
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: bg,
    textTheme: textTheme,
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: Colors.white,
      centerTitle: true,
      titleTextStyle: GoogleFonts.robotoMono(
        color: neonGreen,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF0D141D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: neonBlue),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: neonBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: neonGreen, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: neonGreen,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: neonBlue,
    ),
  );
}