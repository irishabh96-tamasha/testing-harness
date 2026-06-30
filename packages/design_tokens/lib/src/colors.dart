import 'package:flutter/material.dart';

/// Color tokens — pulled from Figma Dev Mode (Tamasha "Status" design,
/// node 302:4384) via `get_variable_defs`. Regenerate from Figma; don't hand-tune.
abstract final class AppColors {
  // Universal
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Brand (orange)
  static const Color brand100 = Color(0xFFFFF1E2);
  static const Color brand300 = Color(0xFFFE8A02);
  static const Color brand400 = Color(0xFFFC7304);

  // Grey scale
  static const Color grey200 = Color(0xFFEAEBEE);
  static const Color grey300 = Color(0xFFB8B8B8);
  static const Color grey400 = Color(0xFF767676);
  static const Color grey500 = Color(0xFF3F3F3F);

  // Semantic roles (mapped into the theme)
  static const Color primary = brand400;
  static const Color onPrimary = white;
  static const Color surface = white;
  static const Color onSurface = grey500;
  static const Color error = Color(0xFFD32F2F);

  // Gradients (Figma: stop list low→high)
  static const List<Color> ctaGradient = <Color>[brand400, brand300];
  static const List<Color> backgroundGradient = <Color>[brand100, white];

  // Effects
  static const Color shadowXs = Color(0x0D0A0D12); // shadow-xs (#0a0d12 @ 5%)
}
