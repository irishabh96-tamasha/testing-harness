import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/format/count_format.dart';
import 'package:mobile_app/features/feed/feed_controller.dart';
import 'package:mobile_app/features/feed/feed_models.dart';
import 'package:share_plus/share_plus.dart';

/// The status card: engagement row (Share / Like / views / Next), rounded
/// image, advertiser overlay. Likes and views are persisted to the backend;
/// Share opens the OS sheet.
class StatusCard extends ConsumerStatefulWidget {
  const StatusCard({required this.post, required this.onNext, super.key});

  final StatusPost post;
  final VoidCallback onNext;

  @override
  ConsumerState<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends ConsumerState<StatusCard> {
  @override
  void initState() {
    super.initState();
    _recordView();
  }

  @override
  void didUpdateWidget(StatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _recordView();
    }
  }

  /// Record a view once this status is shown (deferred off the build phase).
  void _recordView() {
    final String id = widget.post.id;
    Future<void>.microtask(
      () => ref.read(statusActionsProvider).recordView(id),
    );
  }

  void _toggleLike(StatusPost post) {
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
  }

  @override
  Widget build(BuildContext context) {
    final StatusPost post = widget.post;
    final bool liked = ref.watch(likedStatusProvider).contains(post.id);
    return Column(
      children: <Widget>[
        _EngagementRow(
          post: post,
          liked: liked,
          onLike: () => _toggleLike(post),
          onShare: () => Share.share('${post.authorName}: ${post.tagline}'),
          onNext: widget.onNext,
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(child: _ImageCard(post: post)),
      ],
    );
  }
}

class _EngagementRow extends StatelessWidget {
  const _EngagementRow({
    required this.post,
    required this.liked,
    required this.onLike,
    required this.onShare,
    required this.onNext,
  });

  final StatusPost post;
  final bool liked;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    // post.likes is the server count (refreshed after a like persists).
    final int likeCount = post.likes;
    return Row(
      children: <Widget>[
        FilledButton.icon(
          onPressed: onShare,
          icon: const Icon(Icons.share, size: 18),
          label: const Text('Share'),
          style: FilledButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            shape: const StadiumBorder(),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _StatButton(
          icon: liked ? Icons.favorite : Icons.favorite_border,
          color: liked ? scheme.primary : scheme.onSurface,
          label: formatCount(likeCount),
          onTap: onLike,
        ),
        const SizedBox(width: AppSpacing.md),
        _StatButton(
          icon: Icons.visibility_outlined,
          color: scheme.onSurface,
          label: formatCount(post.views),
          onTap: null,
        ),
        const Spacer(),
        OutlinedButton(
          onPressed: onNext,
          style: OutlinedButton.styleFrom(
            foregroundColor: scheme.onSurface,
            side: const BorderSide(color: AppColors.grey300),
            shape: const StadiumBorder(),
          ),
          child: const Text('Next'),
        ),
      ],
    );
  }
}

class _StatButton extends StatelessWidget {
  const _StatButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  const _ImageCard({required this.post});

  final StatusPost post;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: AppColors.grey200),
          ),
          Positioned(
            left: AppSpacing.sm,
            right: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: _AdvertiserOverlay(post: post),
          ),
        ],
      ),
    );
  }
}

class _AdvertiserOverlay extends StatelessWidget {
  const _AdvertiserOverlay({required this.post});

  final StatusPost post;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadowXs,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          _AvatarWithBadge(url: post.authorAvatarUrl),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(post.authorName, style: text.titleMedium),
                const SizedBox(height: 2),
                Text(
                  post.authorSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall?.copyWith(color: AppColors.grey400),
                ),
                const SizedBox(height: 2),
                Text(
                  post.tagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelSmall?.copyWith(color: AppColors.grey400),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarWithBadge extends StatelessWidget {
  const _AvatarWithBadge({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.grey200,
            backgroundImage: NetworkImage(url),
            onBackgroundImageError: (_, __) {},
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: CircleAvatar(
              radius: 9,
              backgroundColor: AppColors.white,
              child: Icon(Icons.add_circle, size: 16, color: primary),
            ),
          ),
        ],
      ),
    );
  }
}
