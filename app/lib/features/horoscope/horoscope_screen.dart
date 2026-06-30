import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/format/date_format.dart';
import 'package:mobile_app/features/horoscope/horoscope_controller.dart';
import 'package:mobile_app/features/horoscope/horoscope_detail_screen.dart';
import 'package:mobile_app/features/horoscope/horoscope_models.dart';
import 'package:mobile_app/features/horoscope/zodiac_icon.dart';

/// Horoscope tab (Figma 371:3796): "Today's Horoscope" + a 3-column grid of
/// the 12 zodiac signs. Tapping a sign opens its reading.
class HoroscopeScreen extends ConsumerWidget {
  const HoroscopeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Sign>> signs = ref.watch(horoscopeProvider);
    final TextTheme text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: AppSpacing.md),
              Text("Today's Horoscope", style: text.headlineLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(
                formatLongDate(DateTime.now()),
                style: text.titleMedium?.copyWith(color: AppColors.grey400),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: signs.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (Object e, _) => Center(
                    child: TextButton(
                      onPressed: () => ref.invalidate(horoscopeProvider),
                      child: const Text('Could not load horoscope — Retry'),
                    ),
                  ),
                  data: (List<Sign> list) => GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.92,
                    children: <Widget>[
                      for (final Sign s in list) _SignCard(sign: s),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignCard extends StatelessWidget {
  const _SignCard({required this.sign});

  final Sign sign;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => HoroscopeDetailScreen(sign: sign),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey300),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ZodiacIcon(signId: sign.id, size: 42),
              const SizedBox(height: AppSpacing.sm),
              Text(
                sign.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
