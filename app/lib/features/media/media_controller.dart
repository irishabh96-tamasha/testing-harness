import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/media/media_models.dart';

/// Selected deity for each gallery (defaults to "all").
final wallpaperDeityProvider = StateProvider<String>((ref) => 'all');
final ringtoneDeityProvider = StateProvider<String>((ref) => 'all');

/// Ids the user has liked this session (optimistic heart state).
final likedWallpaperProvider = StateProvider<Set<String>>((ref) => <String>{});
final likedRingtoneProvider = StateProvider<Set<String>>((ref) => <String>{});

/// Wallpapers for a deity (`GET /api/wallpapers?deity=`).
final wallpapersProvider = FutureProvider.autoDispose
    .family<List<Wallpaper>, String>((ref, deity) async {
  final dio = ref.watch(apiClientProvider);
  final res = await dio.get<List<dynamic>>(
    '/api/wallpapers',
    queryParameters: <String, dynamic>{'deity': deity},
  );
  return (res.data ?? <dynamic>[])
      .map((e) => Wallpaper.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Ringtones for a deity (`GET /api/ringtones?deity=`).
final ringtonesProvider = FutureProvider.autoDispose
    .family<List<Ringtone>, String>((ref, deity) async {
  final dio = ref.watch(apiClientProvider);
  final res = await dio.get<List<dynamic>>(
    '/api/ringtones',
    queryParameters: <String, dynamic>{'deity': deity},
  );
  return (res.data ?? <dynamic>[])
      .map((e) => Ringtone.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Backend-persisted engagement for wallpapers + ringtones (like / set / share
/// / play). An interface so widget tests can substitute a no-op without hitting
/// the network (mirrors `StatusActions`).
abstract class MediaActions {
  Future<void> likeWallpaper({required String id, required bool liked});
  Future<void> countWallpaperSet(String id);
  Future<void> shareWallpaper(String id);

  Future<void> likeRingtone({required String id, required bool liked});
  Future<void> countRingtoneSet(String id);
  Future<void> shareRingtone(String id);
  Future<void> countRingtonePlay(String id);
}

final mediaActionsProvider =
    Provider<MediaActions>((ref) => _ApiMediaActions(ref));

/// Persists media engagement to the backend (best-effort — UI keeps its
/// optimistic state if the network call fails).
class _ApiMediaActions implements MediaActions {
  _ApiMediaActions(this._ref);

  final Ref _ref;

  Future<void> _post(String path) async {
    final dio = _ref.read(apiClientProvider);
    try {
      await dio.post<dynamic>(path);
    } catch (_) {
      // Engagement counts are best-effort.
    }
  }

  @override
  Future<void> likeWallpaper({required String id, required bool liked}) async {
    final dio = _ref.read(apiClientProvider);
    try {
      await dio.post<dynamic>(
        '/api/wallpapers/$id/like',
        data: <String, dynamic>{'liked': liked},
      );
    } catch (_) {}
  }

  @override
  Future<void> countWallpaperSet(String id) => _post('/api/wallpapers/$id/set');

  @override
  Future<void> shareWallpaper(String id) => _post('/api/wallpapers/$id/share');

  @override
  Future<void> likeRingtone({required String id, required bool liked}) async {
    final dio = _ref.read(apiClientProvider);
    try {
      await dio.post<dynamic>(
        '/api/ringtones/$id/like',
        data: <String, dynamic>{'liked': liked},
      );
    } catch (_) {}
  }

  @override
  Future<void> countRingtoneSet(String id) => _post('/api/ringtones/$id/set');

  @override
  Future<void> shareRingtone(String id) => _post('/api/ringtones/$id/share');

  @override
  Future<void> countRingtonePlay(String id) => _post('/api/ringtones/$id/play');
}
