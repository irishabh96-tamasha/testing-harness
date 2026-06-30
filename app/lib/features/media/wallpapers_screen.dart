import 'package:design_tokens/design_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/features/feed/deity_filter_bar.dart';
import 'package:mobile_app/features/media/media_controller.dart';
import 'package:mobile_app/features/media/media_models.dart';
import 'package:mobile_app/features/media/wallpaper_preview_screen.dart';

const Map<String, String> _collectionTitles = <String, String>{
  'live': 'Top Live Wallpapers',
  'new': 'New Wallpapers',
  'trending': 'Trending Wallpaper',
};
const List<String> _collectionOrder = <String>['live', 'new', 'trending'];

/// Wallpapers gallery (Figma 704:5223): deity selector + collection rows.
class WallpapersScreen extends ConsumerWidget {
  const WallpapersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String deity = ref.watch(wallpaperDeityProvider);
    final AsyncValue<List<Wallpaper>> wallpapers =
        ref.watch(wallpapersProvider(deity));
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: AppColors.white,
        title: const Text('Wallpapers'),
      ),
      body: Column(
        children: <Widget>[
          DeityFilterBar(
            activeId: deity,
            onSelect: (String id) =>
                ref.read(wallpaperDeityProvider.notifier).state = id,
          ),
          Expanded(
            child: wallpapers.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object e, _) => Center(
                child: TextButton(
                  onPressed: () => ref.invalidate(wallpapersProvider(deity)),
                  child: const Text('Could not load wallpapers — Retry'),
                ),
              ),
              data: (List<Wallpaper> list) {
                if (list.isEmpty) {
                  return const Center(child: Text('No wallpapers yet'));
                }
                return ListView(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  children: <Widget>[
                    for (final String c in _collectionOrder)
                      if (list.any((Wallpaper w) => w.collection == c))
                        _CollectionRow(
                          title: _collectionTitles[c] ?? c,
                          items: list
                              .where((Wallpaper w) => w.collection == c)
                              .toList(),
                        ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionRow extends StatelessWidget {
  const _CollectionRow({required this.title, required this.items});

  final String title;
  final List<Wallpaper> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (BuildContext context, int i) => GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      WallpaperPreviewScreen(imageUrl: items[i].imageUrl),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  items[i].imageUrl,
                  width: 150,
                  height: 230,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox(
                    width: 150,
                    child: ColoredBox(color: AppColors.grey200),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
