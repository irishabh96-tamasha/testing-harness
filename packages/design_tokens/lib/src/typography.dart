import 'package:flutter/material.dart';

/// Typography tokens — pulled from Figma (font "Inter"). These hold the
/// metrics (size/weight/height/spacing); the actual Inter font is applied in
/// app_theme.dart via google_fonts. letterSpacing is approximated from Figma.
abstract final class AppTypography {
  static const String fontFamily = 'Inter';

  // Headings/heading-sm — Inter SemiBold 24 / lineHeight 32
  static const TextStyle headingSm = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    letterSpacing: -0.5,
  );

  // Title (16) — used for emphasized body / card titles
  static const TextStyle titleMd = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    letterSpacing: -0.2,
  );

  // Label/label-md — Inter Medium 14 / lineHeight 20
  static const TextStyle labelMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    letterSpacing: -0.1,
  );

  // Label/label-sm — Inter Medium 12 / lineHeight 16
  static const TextStyle labelSm = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: -0.1,
  );
}
