import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/feed/feed_controller.dart';
import 'package:mobile_app/features/feed/feed_models.dart';

/// Horizontal deity selector (All Gods + deities) reused by the Wallpapers and
/// Ringtones screens. Driven by [feedProvider].
class DeityFilterBar extends ConsumerWidget {
  const DeityFilterBar({
    required this.activeId,
    required this.onSelect,
    super.key,
  });

  final String activeId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Deity>> feed = ref.watch(feedProvider);
    return SizedBox(
      height: 96,
      child: feed.maybeWhen(
        data: (List<Deity> deities) => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          itemCount: deities.length,
          separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (BuildContext context, int i) {
            final Deity d = deities[i];
            return _DeityAvatar(
              deity: d,
              selected: d.id == activeId,
              onTap: () => onSelect(d.id),
            );
          },
        ),
        orElse: () => const SizedBox.shrink(),
      ),
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
        width: 64,
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
                  ? CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.brand100,
                      child: Icon(Icons.temple_hindu, color: primary),
                    )
                  : CircleAvatar(
                      radius: 26,
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
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
