import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/format/date_format.dart';
import 'package:mobile_app/features/horoscope/horoscope_models.dart';
import 'package:mobile_app/features/horoscope/zodiac_icon.dart';

/// A sign's reading on a dark cosmic background (Figma 387:2487).
class HoroscopeDetailScreen extends StatelessWidget {
  const HoroscopeDetailScreen({required this.sign, super.key});

  final Sign sign;

  static const Color _cream = Color(0xFFF3E2C7);

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF0A0E1F),
              Color(0xFF1B2138),
              Color(0xFF0A0E1F),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ZodiacIcon(signId: sign.id, size: 28, color: _cream),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      sign.name,
                      style:
                          text.headlineLarge?.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  formatLongDate(DateTime.now()),
                  style: text.titleMedium?.copyWith(color: AppColors.grey300),
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      Positioned(
                        top: 18,
                        left: 0,
                        right: 0,
                        bottom: AppSpacing.md,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xl,
                                ),
                                child: Text(
                                  sign.reading,
                                  textAlign: TextAlign.center,
                                  style: text.titleMedium?.copyWith(
                                    color: _cream,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: AppSpacing.lg,
                                child: Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // "Namaste" pill straddling the card's top border.
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF15192B),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              'Namaste',
                              style: text.titleMedium?.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
