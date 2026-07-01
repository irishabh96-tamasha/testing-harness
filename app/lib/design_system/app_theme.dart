import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Maps design tokens onto a Flutter [ThemeData]. Widgets read from the theme
/// (Theme.of(context)) rather than referencing tokens directly, so the
/// Figma-generated tokens have a single integration point here.
abstract final class AppTheme {
  /// Applies the real Inter font to a token's metrics.
  static TextStyle _inter(TextStyle style) =>
      GoogleFonts.inter(textStyle: style);

  static ThemeData get light {
    const ColorScheme scheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.brand300,
      onSecondary: AppColors.white,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.white,
      textTheme: TextTheme(
        headlineLarge: _inter(AppTypography.headingSm),
        headlineSmall: _inter(AppTypography.headingSm),
        titleMedium: _inter(AppTypography.titleMd),
        bodyMedium: _inter(AppTypography.labelMd),
        labelLarge: _inter(AppTypography.labelMd),
        labelSmall: _inter(AppTypography.labelSm),
      ),
    );
  }
}
