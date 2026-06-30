import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/audio/audio_controller.dart';
import 'package:mobile_app/core/format/count_format.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/feed/feed_controller.dart';
import 'package:mobile_app/features/feed/feed_models.dart';
import 'package:mobile_app/features/home/home_controller.dart';
import 'package:mobile_app/features/media/media_models.dart';
import 'package:mobile_app/features/media/ringtone_preview_screen.dart';
import 'package:mobile_app/features/media/ringtones_screen.dart';
import 'package:mobile_app/features/media/wallpaper_preview_screen.dart';
import 'package:mobile_app/features/media/wallpapers_screen.dart';

/// Home tab (Figma 285:3464): brand header, promo banner, feature grid, and a
/// backend-driven "trending" feed mixing status, wallpaper and ringtone cards.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<HomeFeedItem>> feed = ref.watch(homeFeedProvider);
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: feed.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object e, _) => Center(
            child: TextButton(
              onPressed: () => ref.invalidate(homeFeedProvider),
              child: const Text('Could not load Home — Retry'),
            ),
          ),
          data: (List<HomeFeedItem> items) => ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: <Widget>[
              const _HomeHeader(),
              const _PromoBanner(),
              const _FeatureGrid(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Text(
                  'Trending',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              for (final HomeFeedItem item in items)
                switch (item) {
                  StatusFeedItem(:final StatusPost post) =>
                    _StatusFeedCard(post: post),
                  WallpaperFeedItem(:final Wallpaper wallpaper) =>
                    _WallpaperFeedCard(wallpaper: wallpaper),
                  RingtoneFeedItem(:final Ringtone ringtone) =>
                    _RingtoneFeedCard(ringtone: ringtone),
                },
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.temple_hindu, color: primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Prabhuji',
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(color: primary),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: <Color>[AppColors.brand400, AppColors.brand300],
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Bhakti Status',
                  style: text.headlineLarge?.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Share devotion every day',
                  style: text.labelMedium?.copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              mediaUrl('/media/wallpapers/krishna-radha.jpg'),
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.auto_awesome,
                color: AppColors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  // Gold illustrated icons extracted from Figma (icons/homescreen-feature-cards
  // 767:6575), bundled under assets/home.
  static const List<(String, String)> _items = <(String, String)>[
    ('assets/home/aarti.png', 'Aarti & Bhajans'),
    ('assets/home/mantra.png', 'Mantras & Stuti'),
    ('assets/home/ringtone.png', 'Set Ringtones'),
    ('assets/home/wallpaper.png', 'Set Wallpaper'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        0,
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 2.4,
        children: <Widget>[
          for (final (String asset, String label) in _items)
            _FeatureTile(asset: asset, label: label),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brand100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          final Widget? dest = switch (label) {
            'Set Wallpaper' => const WallpapersScreen(),
            'Set Ringtones' => const RingtonesScreen(),
            _ => null,
          };
          if (dest != null) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => dest),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$label — coming soon')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Image.asset(asset, width: 44, height: 44),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "TRENDING" pill shown on featured feed cards.
class _TrendingBadge extends StatelessWidget {
  const _TrendingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.brand400,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'TRENDING',
        style: TextStyle(
          color: AppColors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// A status (advertiser) card: image with author overlay + persisted Like/views.
class _StatusFeedCard extends ConsumerWidget {
  const _StatusFeedCard({required this.post});

  final StatusPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool liked = ref.watch(likedStatusProvider).contains(post.id);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: <Widget>[
                Image.network(
                  post.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 220,
                    child: ColoredBox(color: AppColors.grey200),
                  ),
                ),
                Positioned(
                  left: AppSpacing.sm,
                  right: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.grey200,
                          backgroundImage: NetworkImage(post.authorAvatarUrl),
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            post.authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  final Set<String> current = ref.read(likedStatusProvider);
                  final bool nowLiked = !current.contains(post.id);
                  ref.read(likedStatusProvider.notifier).state = nowLiked
                      ? <String>{...current, post.id}
                      : current.where((String e) => e != post.id).toSet();
                  ref.read(statusActionsProvider).setLike(
                        id: post.id,
                        deityId: post.deityId,
                        liked: nowLiked,
                      );
                },
                icon: Icon(
                  liked ? Icons.favorite : Icons.favorite_border,
                  color: liked ? scheme.primary : scheme.onSurface,
                ),
              ),
              Text(formatCount(post.likes)),
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.visibility_outlined, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Text(formatCount(post.views)),
            ],
          ),
        ],
      ),
    );
  }
}

/// A wallpaper promo card: devotional image, TRENDING badge, and a Set Wallpaper
/// action that opens the full-screen preview (L2).
class _WallpaperFeedCard extends StatelessWidget {
  const _WallpaperFeedCard({required this.wallpaper});

  final Wallpaper wallpaper;

  void _open(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => WallpaperPreviewScreen(wallpaper: wallpaper),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: GestureDetector(
        onTap: () => _open(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: <Widget>[
              Image.network(
                wallpaper.imageUrl,
                height: 260,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                  height: 260,
                  child: ColoredBox(color: AppColors.grey200),
                ),
              ),
              const Positioned(
                left: AppSpacing.sm,
                top: AppSpacing.sm,
                child: _TrendingBadge(),
              ),
              Positioned(
                right: AppSpacing.sm,
                bottom: AppSpacing.sm,
                child: FilledButton.icon(
                  onPressed: () => _open(context),
                  icon: const Icon(Icons.wallpaper, size: 18),
                  label: const Text('Set Wallpaper'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.brand400,
                    shape: const StadiumBorder(),
                  ),
                ),
              ),
              Positioned(
                left: AppSpacing.sm,
                bottom: AppSpacing.sm,
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.favorite,
                      color: AppColors.white,
                      size: 16,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      formatCount(wallpaper.likes),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A ringtone promo card: cover + title + play + Set Ringtone, opening the
/// ringtone preview (L2).
class _RingtoneFeedCard extends ConsumerWidget {
  const _RingtoneFeedCard({required this.ringtone});

  final Ringtone ringtone;

  void _open(BuildContext context) => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => RingtonePreviewScreen(ringtone: ringtone),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme text = Theme.of(context).textTheme;
    final AudioState audio = ref.watch(audioControllerProvider);
    final bool playing = audio.mediaId == ringtone.id && audio.playing;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Material(
        color: AppColors.brand100,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _open(context),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    ringtone.imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      width: 72,
                      height: 72,
                      child: ColoredBox(color: AppColors.grey200),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        ringtone.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.headphones,
                            size: 13,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            formatCount(ringtone.plays),
                            style: text.labelSmall,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Set Ringtone',
                            style: text.labelSmall
                                ?.copyWith(color: AppColors.brand400),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => ref
                      .read(audioControllerProvider.notifier)
                      .toggle(ringtone.id, ringtone.audioUrl),
                  icon: CircleAvatar(
                    backgroundColor: AppColors.brand400,
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
      ),
    );
  }
}
