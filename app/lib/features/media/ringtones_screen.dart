import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/audio/audio_controller.dart';
import 'package:mobile_app/core/format/count_format.dart';
import 'package:mobile_app/features/feed/deity_filter_bar.dart';
import 'package:mobile_app/features/media/media_controller.dart';
import 'package:mobile_app/features/media/media_models.dart';

/// Ringtones gallery (Figma 670:4481): search + deity selector + playable grid.
class RingtonesScreen extends ConsumerWidget {
  const RingtonesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String deity = ref.watch(ringtoneDeityProvider);
    final AsyncValue<List<Ringtone>> ringtones =
        ref.watch(ringtonesProvider(deity));
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        title: TextField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Search Ringtones',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: const Icon(Icons.mic_none),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppColors.grey300),
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          DeityFilterBar(
            activeId: deity,
            onSelect: (String id) =>
                ref.read(ringtoneDeityProvider.notifier).state = id,
          ),
          Expanded(
            child: ringtones.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object e, _) => Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(ringtonesProvider(deity)),
                  child: const Text('Could not load ringtones — Retry'),
                ),
              ),
              data: (List<Ringtone> list) => list.isEmpty
                  ? const Center(child: Text('No ringtones yet'))
                  : GridView.count(
                      crossAxisCount: 3,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.62,
                      children: <Widget>[
                        for (final Ringtone r in list)
                          _RingtoneCard(ringtone: r),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingtoneCard extends ConsumerWidget {
  const _RingtoneCard({required this.ringtone});

  final Ringtone ringtone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AudioState audio = ref.watch(audioControllerProvider);
    final bool playing = audio.mediaId == ringtone.id && audio.playing;
    final TextTheme text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => ref
          .read(audioControllerProvider.notifier)
          .toggle(ringtone.id, ringtone.audioUrl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.network(
                    ringtone.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: AppColors.grey200),
                  ),
                  Center(
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black.withValues(alpha: 0.45),
                      child: Icon(
                        playing ? Icons.pause : Icons.play_arrow,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            ringtone.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.labelMedium,
          ),
          const SizedBox(height: 2),
          Row(
            children: <Widget>[
              const Icon(Icons.headphones, size: 13, color: AppColors.grey400),
              const SizedBox(width: 2),
              Text(formatCount(ringtone.plays), style: text.labelSmall),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.download,
                size: 13,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 2),
              Text(formatCount(ringtone.downloads), style: text.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
