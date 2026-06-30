import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/format/count_format.dart';
import 'package:mobile_app/features/feed/feed_controller.dart';
import 'package:mobile_app/features/feed/feed_models.dart';
import 'package:mobile_app/features/home/home_controller.dart';
import 'package:mobile_app/features/media/ringtones_screen.dart';
import 'package:mobile_app/features/media/wallpapers_screen.dart';

/// Home tab (Figma 285:3464): brand header, promo banner, feature grid, and a
/// backend-driven "trending" feed of devotional cards.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<StatusPost>> feed = ref.watch(homeFeedProvider);
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
          data: (List<StatusPost> items) => ListView(
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
              for (final StatusPost item in items) _HomeFeedCard(post: item),
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
          const Icon(Icons.auto_awesome, color: AppColors.white, size: 40),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static const List<(IconData, String)> _items = <(IconData, String)>[
    (Icons.music_note, 'Aarti & Bhajans'),
    (Icons.menu_book, 'Mantras & Stuti'),
    (Icons.ring_volume, 'Set Ringtones'),
    (Icons.wallpaper, 'Set Wallpaper'),
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
        childAspectRatio: 2.6,
        children: <Widget>[
          for (final (IconData icon, String label) in _items)
            _FeatureTile(icon: icon, label: label),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: <Widget>[
              Icon(icon, color: primary, size: 22),
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

/// A Home feed card: image with advertiser overlay + a persisted engagement
/// row (Like / views / Share). Likes persist via the shared [statusActionsProvider].
class _HomeFeedCard extends ConsumerWidget {
  const _HomeFeedCard({required this.post});

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
