import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/feed/all_gods_avatar.dart';
import 'package:mobile_app/features/feed/feed_controller.dart';
import 'package:mobile_app/features/feed/feed_models.dart';
import 'package:mobile_app/features/feed/status_card.dart';
import 'package:mobile_app/features/profile/edit_details_screen.dart';

/// The "Status" tab: header, deity selector, and the deity's status card.
/// Selecting a deity loads that deity's statuses; Next cycles through them.
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Deity>> feed = ref.watch(feedProvider);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundGradient,
            stops: <double>[0, 0.3],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: feed.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (Object e, _) => _ErrorRetry(
              message: 'Could not load deities.',
              onRetry: () => ref.invalidate(feedProvider),
            ),
            data: (List<Deity> deities) {
              if (deities.isEmpty) {
                return const _Centered('No deities yet');
              }
              final String activeId =
                  ref.watch(selectedDeityProvider) ?? deities.first.id;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _Header(),
                  SizedBox(
                    height: 104,
                    child: _DeitySelector(
                      items: deities,
                      activeId: activeId,
                      onSelect: (String id) {
                        ref.read(selectedDeityProvider.notifier).state = id;
                        ref.read(statusIndexProvider.notifier).state = 0;
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: _StatusForDeity(deityId: activeId),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatusForDeity extends ConsumerWidget {
  const _StatusForDeity({required this.deityId});

  final String deityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<StatusPost>> statuses =
        ref.watch(statusListProvider(deityId));
    return statuses.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object e, _) => _ErrorRetry(
        message: 'Could not load statuses.',
        onRetry: () => ref.invalidate(statusListProvider(deityId)),
      ),
      data: (List<StatusPost> list) {
        if (list.isEmpty) {
          return const _Centered('No statuses yet');
        }
        final int index = ref.watch(statusIndexProvider) % list.length;
        return StatusCard(
          post: list[index],
          onNext: () => ref.read(statusIndexProvider.notifier).state =
              ref.read(statusIndexProvider) + 1,
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('Status', style: Theme.of(context).textTheme.headlineLarge),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const EditDetailsScreen(),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 16),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              shape: const StadiumBorder(),
            ),
            label: const Text('Edit Details'),
          ),
        ],
      ),
    );
  }
}

class _DeitySelector extends StatelessWidget {
  const _DeitySelector({
    required this.items,
    required this.activeId,
    required this.onSelect,
  });

  final List<Deity> items;
  final String activeId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
      itemBuilder: (BuildContext context, int i) {
        final Deity item = items[i];
        return _DeityAvatar(
          deity: item,
          selected: item.id == activeId,
          onTap: () => onSelect(item.id),
        );
      },
    );
  }
}

class _DeityAvatar extends StatelessWidget {
  const _DeityAvatar({
    required this.deity,
    required this.selected,
    required this.onTap,
  });

  final Deity deity;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    final bool isAll = deity.id == 'all';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: selected ? Border.all(color: primary, width: 2) : null,
              ),
              child: isAll
                  ? const AllGodsAvatar(radius: 28)
                  : CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.grey200,
                      backgroundImage: NetworkImage(deity.imageUrl),
                      onBackgroundImageError: (_, __) {},
                    ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              deity.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected ? primary : AppColors.grey400,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
