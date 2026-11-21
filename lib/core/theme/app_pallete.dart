import 'package:flutter/material.dart';

class AppPallete {
  // Wireframe Core Design System Palette
  static const Color navy = Color(0xFF0B1F3B);
  static const Color indigo = Color(0xFF5B42F3);
  static const Color teal = Color(0xFF14BBA6);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color amber = Color(0xFFF59E0B);
  static const Color gray = Color(0xFF6B7280);

  // Trip Status Colors (Wireframe Specification)
  static const Color statusDraft = Color(0xFF6B7280);
  static const Color statusPlanning = Color(0xFF5B42F3);
  static const Color statusConfirmed = Color(0xFF14BBA6);
  static const Color statusUpcoming = Color(0xFF0EA5E9);
  static const Color statusOngoing = Color(0xFF10B981);
  static const Color statusSettling = Color(0xFFF59E0B);
  static const Color statusClosed = Color(0xFF475569);
  static const Color statusCancelled = Color(0xFFFF6B6B);

  // Brand Primary & Accents
  static const Color primary = indigo; // #5B42F3 Royal Indigo
  static const Color onPrimary = Colors.white;
  static const Color primaryContainer = Color(0xFFEEF2FF);
  static const Color onPrimaryContainer = Color(0xFF3730A3);

  static const Color secondary = teal; // #14BBA6 Teal
  static const Color onSecondary = Colors.white;
  static const Color secondaryContainer = Color(0xFFCCFBF1);
  static const Color onSecondaryContainer = Color(0xFF0F766E);

  static const Color tertiary = Color(0xFF10B981); // Emerald Green
  static const Color onTertiary = Colors.white;
  static const Color tertiaryContainer = Color(0xFFD1FAE5);
  static const Color onTertiaryContainer = Color(0xFF065F46);

  // Background & Surfaces (Light)
  static const Color background = Color(0xFFF8FAFC);
  static const Color onBackground = Color(0xFF0F172A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF0F172A);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color outline = Color(0xFFCBD5E1);
  static const Color outlineVariant = Color(0xFFE2E8F0);

  // Background & Surfaces (Dark)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color onBackgroundDark = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color onSurfaceDark = Color(0xFFF8FAFC);
  static const Color surfaceVariantDark = Color(0xFF334155);
  static const Color outlineDark = Color(0xFF475569);

  // Status Colors
  static const Color error = Color(0xFFEF4444); // Crimson (Emergency/Negative)
  static const Color onError = Colors.white;
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF991B1B);

  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color onWarning = Colors.white;
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarningContainer = Color(0xFF92400E);

  static const Color trustBlue = Color(0xFF0284C7);
  static const Color collaborationGreen = Color(0xFF10B981);

  // Modern Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFF43F5E), Color(0xFFFB7185)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Elevation & Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get primaryGlow => [
        BoxShadow(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];
}
