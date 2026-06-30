import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/feed/feed_models.dart';
import 'package:mobile_app/features/media/media_models.dart';

/// One card in the Home "Trending" feed. The backend tags each item with a
/// `type`; the UI switches on the concrete subtype to pick a card widget.
sealed class HomeFeedItem {
  const HomeFeedItem();
}

class StatusFeedItem extends HomeFeedItem {
  const StatusFeedItem(this.post);
  final StatusPost post;
}

class WallpaperFeedItem extends HomeFeedItem {
  const WallpaperFeedItem(this.wallpaper);
  final Wallpaper wallpaper;
}

class RingtoneFeedItem extends HomeFeedItem {
  const RingtoneFeedItem(this.ringtone);
  final Ringtone ringtone;
}

/// The Home feed — a typed, interleaved mix of status / wallpaper / ringtone
/// cards (`GET /api/home/feed`).
final homeFeedProvider = FutureProvider.autoDispose<List<HomeFeedItem>>(
  (ref) async {
    final dio = ref.watch(apiClientProvider);
    final res = await dio.get<List<dynamic>>('/api/home/feed');
    return (res.data ?? <dynamic>[]).map((dynamic e) {
      final Map<String, dynamic> m = e as Map<String, dynamic>;
      switch (m['type']) {
        case 'wallpaper':
          return WallpaperFeedItem(Wallpaper.fromJson(m));
        case 'ringtone':
          return RingtoneFeedItem(Ringtone.fromJson(m));
        default:
          return StatusFeedItem(StatusPost.fromJson(m));
      }
    }).toList();
  },
);
