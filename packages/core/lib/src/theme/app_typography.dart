import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography. Space Grotesk for display/brand, Inter for UI/body.
///
/// Scale (px): 28 / 22 / 18 / 16 / 14 / 12. Headings use weight 600; body 400–500.
abstract final class AppTypography {
  const AppTypography._();

  static TextStyle _display() => GoogleFonts.spaceGrotesk();
  static TextStyle _body() => GoogleFonts.inter();

  static TextTheme textTheme({required Color color, required Color muted}) {
    final display = _display();
    final body = _body();
    return TextTheme(
      displaySmall: display.copyWith(
        fontSize: 28,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineSmall: display.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: display.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: body.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      bodyLarge: body.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodyMedium: body.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodySmall: body.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: body.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      // Used for the "NOW EXPLORING" / "STATION HOMEPAGE" overline labels.
      labelSmall: body.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.4,
        color: muted,
      ),
    );
  }
}
