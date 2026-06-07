import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_text_styles.dart';

/// Central design system for Swarm Interface.
/// All color tokens, spacing constants, and border radii are defined here.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Color tokens
  // ---------------------------------------------------------------------------

  static const Color colorBackground = Color(0xFF0A0E1A);
  static const Color colorSurface = Color(0xFF111827);
  static const Color colorSurfaceElevated = Color(0xFF1C2333);
  static const Color colorBorder = Color(0xFF2A3352);
  static const Color colorAccent = Color(0xFF3B82F6);
  static const Color colorAccentGlow = Color(0xFF1D4ED8);
  static const Color colorAccentLight = Color(0xFF1E3A5F);
  static const Color colorSuccess = Color(0xFF10B981);
  static const Color colorWarning = Color(0xFFF59E0B);
  static const Color colorError = Color(0xFFEF4444);
  static const Color colorTextPrimary = Color(0xFFF1F5F9);
  static const Color colorTextSecondary = Color(0xFF64748B);
  static const Color colorGlass = Color(0x0DFFFFFF);

  // ---------------------------------------------------------------------------
  // Spacing — base-8 grid (PRD §5)
  // ---------------------------------------------------------------------------

  /// 6 dp spacing (half-step).
  static const double spacing6 = 6.0;

  /// 4 dp spacing.
  static const double spacing4 = 4.0;

  /// 8 dp spacing.
  static const double spacing8 = 8.0;

  /// 12 dp spacing (half-step).
  static const double spacing12 = 12.0;

  /// 16 dp spacing.
  static const double spacing16 = 16.0;

  /// 24 dp spacing.
  static const double spacing24 = 24.0;

  /// 32 dp spacing.
  static const double spacing32 = 32.0;

  /// 48 dp spacing.
  static const double spacing48 = 48.0;

  // ---------------------------------------------------------------------------
  // Border radii (PRD §5)
  // ---------------------------------------------------------------------------

  /// Cards use 16 dp radius.
  static final BorderRadius radiusCard = BorderRadius.circular(16);

  /// Buttons use 12 dp radius.
  static final BorderRadius radiusButton = BorderRadius.circular(12);

  /// Mic button uses full circle.
  static final BorderRadius radiusMic = BorderRadius.circular(9999);

  // ---------------------------------------------------------------------------
  // ThemeData
  // ---------------------------------------------------------------------------

  /// Returns the fully configured [ThemeData] for the app.
  static ThemeData get themeData {
    final base = GoogleFonts.dmSansTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: colorAccent,
        onPrimary: Colors.white,
        secondary: colorSuccess,
        onSecondary: Colors.white,
        error: colorError,
        onError: Colors.white,
        surface: colorSurface,
        onSurface: colorTextPrimary,
      ),
      scaffoldBackgroundColor: colorBackground,
      textTheme: base.apply(
        bodyColor: colorTextPrimary,
        displayColor: colorTextPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.appBarTitle,
        iconTheme: const IconThemeData(color: colorTextPrimary),
        shape: const Border(bottom: BorderSide(color: colorBorder, width: 1)),
      ),
      cardTheme: const CardThemeData(
        color: colorSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}
