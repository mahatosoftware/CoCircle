import 'package:flutter/material.dart';
import 'app_pallete.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightThemeMode = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppPallete.primary,
      onPrimary: AppPallete.onPrimary,
      secondary: AppPallete.secondary,
      onSecondary: Colors.white,
      error: AppPallete.error,
      onError: Colors.white,
      surface: AppPallete.surface,
      onSurface: AppPallete.onSurface,
      background: AppPallete.background,
      onBackground: AppPallete.onBackground,
    ),
    scaffoldBackgroundColor: AppPallete.background,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.surface,
      elevation: 0,
      centerTitle: true,
    ),
  );

  static final darkThemeMode = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: AppPallete.primary,
      // Create a proper dark scheme later
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
  );
}
