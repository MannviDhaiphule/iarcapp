import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_text_styles.dart';

/// Central design system for Swarm Interface.
/// All color tokens, spacing constants, and border radii are defined here.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Color tokens (exact hex values from PRD §5)
  // ---------------------------------------------------------------------------

  /// All screen backgrounds.
  static const Color colorBackground = Color(0xFFF7F8FA);

  /// Cards, containers.
  static const Color colorSurface = Color(0xFFECEEF2);

  /// Dividers, borders.
  static const Color colorSurfaceDark = Color(0xFFD5D9E0);

  /// Active mic, safe paths, CTAs.
  static const Color colorAccent = Color(0xFF2563EB);

  /// Active mic background glow.
  static const Color colorAccentLight = Color(0xFFEFF4FF);

  /// Valid CMD recognized.
  static const Color colorSuccess = Color(0xFF16A34A);

  /// Partial / ambiguous match.
  static const Color colorWarning = Color(0xFFD97706);

  /// No match / mic error.
  static const Color colorError = Color(0xFFDC2626);

  /// Headlines, CMD labels.
  static const Color colorTextPrimary = Color(0xFF111827);

  /// Captions, metadata.
  static const Color colorTextSecondary = Color(0xFF6B7280);

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
