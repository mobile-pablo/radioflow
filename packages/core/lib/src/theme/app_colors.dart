import 'package:flutter/widgets.dart';

/// RadioFlow color tokens.
///
/// Black-and-white minimalism with a single mint "on air" accent — mirrors the
/// brand spec. Colours use ARGB hex (`0xAARRGGBB`); translucent whites encode the
/// design's `rgba(255,255,255,x)` line/foreground steps.
abstract final class AppColors {
  const AppColors._();

  // Backgrounds.
  static const Color ink = Color(0xFF000000); // app + map background (pure black)
  static const Color bg0 = Color(0xFF050507);
  static const Color surface = Color(0xFF0E0E10); // cards, sheets, bars
  static const Color surfaceAlt = Color(0xFF1A1B1E); // hover/active, borders
  static const Color surfaceHi = Color(0xFF26262C);

  // Hairlines / dividers (white at low opacity).
  static const Color line = Color(0x14FFFFFF); // ~8%
  static const Color lineStrong = Color(0x24FFFFFF); // ~14%

  // Accent — mint "on air" glow, active markers, CTAs, favourites.
  static const Color accent = Color(0xFF38E1B0);
  static const Color accentSoft = Color(0xFF7FF0DA); // hover / glow
  static const Color accentBlue = Color(0xFF5BE3FF);

  // Brand body — the creamy-white logo wave.
  static const Color cream = Color(0xFFF4EFE6);
  static const Color creamSoft = Color(0xFFE6E1D6);

  // Foreground / text.
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB8FFFFFF); // ~72%
  static const Color textMuted = Color(0x85FFFFFF); // ~52%
  static const Color textFaint = Color(0x52FFFFFF); // ~32%

  // Status.
  static const Color danger = Color(0xFFFF5C5C);
}
