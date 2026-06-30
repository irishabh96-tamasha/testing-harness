import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app/core/audio/audio_controller.dart';
import 'package:mobile_app/core/format/count_format.dart';
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
              const _HomeSearchBar(),
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
          SvgPicture.asset(
            'assets/home/temple_logo.svg',
            width: 36,
            height: 36,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Prabhuji',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge
                  ?.copyWith(color: primary),
            ),
          ),
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

/// Decorative search field below the header (Figma Home 285:3499). Search is
/// not wired yet; tapping shows a placeholder.
class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.search, size: 20, color: AppColors.grey400),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Search bhajans, mantras, wallpapers…',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.grey400),
              ),
            ),
            const Icon(Icons.mic_none, size: 20, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }
}

/// Full-bleed promo banner carousel (Figma Home banners 285:3507): backend
/// banner images in a swipeable PageView with page dots.
class _PromoBanner extends ConsumerStatefulWidget {
  const _PromoBanner();

  @override
  ConsumerState<_PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends ConsumerState<_PromoBanner> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<String>> banners = ref.watch(homeBannersProvider);
    return banners.maybeWhen(
      data: (List<String> urls) {
        if (urls.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: AspectRatio(
            aspectRatio: 328 / 150,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: <Widget>[
                  PageView.builder(
                    controller: _controller,
                    itemCount: urls.length,
                    onPageChanged: (int i) => setState(() => _page = i),
                    itemBuilder: (_, int i) => Image.network(
                      urls[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const ColoredBox(color: AppColors.brand100),
                    ),
                  ),
                  Positioned(
                    right: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                    child: Row(
                      children: <Widget>[
                        for (int i = 0; i < urls.length; i++)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == _page
                                  ? AppColors.white
                                  : AppColors.white.withValues(alpha: 0.5),
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
      },
      orElse: () => const Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        child: AspectRatio(
          aspectRatio: 328 / 150,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.brand100,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  // Gold illustrated icons extracted from Figma (icons/homescreen-feature-cards
  // 767:6575), bundled under assets/home. Labels match Figma exactly.
  static const List<(String, String)> _items = <(String, String)>[
    ('assets/home/aarti.png', 'Aarti & Bhajans'),
    ('assets/home/mantra.png', 'Mantras & Stutis'),
    ('assets/home/ringtone.png', 'Set Ringtone'),
    ('assets/home/wallpaper.png', 'Set Wallpaper'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        0,
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 159 / 117,
        children: <Widget>[
          for (final (String asset, String label) in _items)
            _FeatureTile(asset: asset, label: label),
        ],
      ),
    );
  }
}

/// A home feature card (Figma 767:6580): cream→orange gradient, brand border,
/// centered title on top, large gold illustration filling the card below.
class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.cardGradient,
        ),
        border: Border.all(color: AppColors.brand400),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadowXs,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            final Widget? dest = switch (label) {
              'Set Wallpaper' => const WallpapersScreen(),
              'Set Ringtone' => const RingtonesScreen(),
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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              0,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey500,
                    letterSpacing: -0.5,
                  ),
                ),
                Expanded(
                  child: Image.asset(asset, fit: BoxFit.contain),
                ),
              ],
            ),
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
