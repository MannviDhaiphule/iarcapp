import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

/// All named [TextStyle] constants for the Swarm Interface app.
/// Import this file to access typography — never hardcode font sizes elsewhere.
class AppTextStyles {
  AppTextStyles._();

  /// App bar title: DM Sans, 16 sp, semi-bold, primary text colour.
  static TextStyle get appBarTitle => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.colorTextPrimary,
        letterSpacing: 1.2,
      );

  /// Version label shown in the AppBar trailing slot.
  static TextStyle get appBarVersion => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppTheme.colorTextSecondary,
      );

  /// Large command label on the Intent Display Card.
  static TextStyle get cmdLabel => GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppTheme.colorTextPrimary,
        letterSpacing: 0.5,
      );

  /// Section header / card title.
  static TextStyle get cardTitle => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.colorTextSecondary,
        letterSpacing: 1.4,
      );

  /// Chip label text.
  static TextStyle get chipLabel => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      );

  /// Transcript body text.
  static TextStyle get transcriptBody => GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppTheme.colorTextPrimary,
      );

  /// Timestamp label in transcription rows.
  static TextStyle get timestamp => GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppTheme.colorTextSecondary,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  /// Mic button label below the button.
  static TextStyle get micLabel => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppTheme.colorTextSecondary,
        letterSpacing: 0.6,
      );
}
