import 'package:flutter/material.dart';
import 'app_pallete.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final lightThemeMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppPallete.primary,
      onPrimary: AppPallete.onPrimary,
      primaryContainer: AppPallete.primaryContainer,
      onPrimaryContainer: AppPallete.onPrimaryContainer,
      secondary: AppPallete.secondary,
      onSecondary: AppPallete.onSecondary,
      secondaryContainer: AppPallete.secondaryContainer,
      onSecondaryContainer: AppPallete.onSecondaryContainer,
      tertiary: AppPallete.tertiary,
      onTertiary: AppPallete.onTertiary,
      tertiaryContainer: AppPallete.tertiaryContainer,
      onTertiaryContainer: AppPallete.onTertiaryContainer,
      error: AppPallete.error,
      onError: AppPallete.onError,
      errorContainer: AppPallete.errorContainer,
      onErrorContainer: AppPallete.onErrorContainer,
      surface: AppPallete.surface,
      onSurface: AppPallete.onSurface,
      outline: AppPallete.outline,
      outlineVariant: AppPallete.outlineVariant,
    ),
    scaffoldBackgroundColor: AppPallete.background,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.surface,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: AppPallete.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      iconTheme: IconThemeData(color: AppPallete.onSurface),
    ),
    cardTheme: CardThemeData(
      color: AppPallete.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppPallete.outlineVariant, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    tabBarTheme: TabBarThemeData(
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: AppPallete.primary,
      unselectedLabelColor: const Color(0xFF64748B),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      dividerColor: Colors.transparent,
      indicator: BoxDecoration(
        color: AppPallete.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      indicatorColor: AppPallete.primary.withValues(alpha: 0.12),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppPallete.primary, size: 24);
        }
        return const IconThemeData(color: Color(0xFF64748B), size: 24);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppPallete.primary,
          );
        }
        return const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: Color(0xFF64748B),
        );
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallete.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: -0.1),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppPallete.primary,
        side: const BorderSide(color: AppPallete.outlineVariant, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPallete.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPallete.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppPallete.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );

  static final darkThemeMode = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppPallete.primary,
      onPrimary: AppPallete.onPrimary,
      secondary: AppPallete.secondary,
      onSecondary: AppPallete.onSecondary,
      tertiary: AppPallete.tertiary,
      onTertiary: AppPallete.onTertiary,
      error: AppPallete.error,
      onError: AppPallete.onError,
      surface: AppPallete.surfaceDark,
      onSurface: AppPallete.onSurfaceDark,
      outline: AppPallete.outlineDark,
    ),
    scaffoldBackgroundColor: AppPallete.backgroundDark,
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.surfaceDark,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppPallete.surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppPallete.outlineDark, width: 1),
      ),
    ),
    tabBarTheme: TabBarThemeData(
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: Colors.white,
      unselectedLabelColor: const Color(0xFF94A3B8),
      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      dividerColor: Colors.transparent,
      indicator: BoxDecoration(
        color: AppPallete.primary.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: AppPallete.surfaceDark,
      indicatorColor: AppPallete.primary.withValues(alpha: 0.3),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Colors.white, size: 24);
        }
        return const IconThemeData(color: Color(0xFF94A3B8), size: 24);
      }),
    ),
  );
}
