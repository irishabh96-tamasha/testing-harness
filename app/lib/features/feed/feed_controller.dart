import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/feed/feed_models.dart';

/// Deities shown in the selector (`GET /api/feed`).
final feedProvider = FutureProvider.autoDispose<List<Deity>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  final res = await dio.get<List<dynamic>>('/api/feed');
  return (res.data ?? <dynamic>[])
      .map((e) => Deity.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Selected deity id. Null means "use the first deity" (resolved in the UI).
final selectedDeityProvider = StateProvider<String?>((ref) => null);

/// Statuses for a given deity (`GET /api/status?deity=<id>`).
final statusListProvider =
    FutureProvider.family<List<StatusPost>, String>((ref, deityId) async {
  final dio = ref.watch(apiClientProvider);
  final res = await dio.get<List<dynamic>>(
    '/api/status',
    queryParameters: <String, dynamic>{'deity': deityId},
  );
  return (res.data ?? <dynamic>[])
      .map((e) => StatusPost.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// Index of the currently shown status within the selected deity's list.
/// "Next" advances this; it resets to 0 when the deity changes.
final statusIndexProvider = StateProvider<int>((ref) => 0);

/// Ids of statuses the user has liked this session (toggled by the heart).
final likedStatusProvider = StateProvider<Set<String>>((ref) => <String>{});

/// Ids whose view has already been recorded this session (record once each).
final viewedStatusProvider = StateProvider<Set<String>>((ref) => <String>{});

/// Backend-persisted engagement actions (like / view). An interface so tests
/// can substitute a no-op without hitting the network.
abstract class StatusActions {
  Future<void> setLike({
    required String id,
    required String deityId,
    required bool liked,
  });

  Future<void> recordView(String id);
}

final statusActionsProvider =
    Provider<StatusActions>((ref) => _ApiStatusActions(ref));

/// Persists likes and views to the backend so counts survive app restarts.
class _ApiStatusActions implements StatusActions {
  _ApiStatusActions(this._ref);

  final Ref _ref;

  /// Persist a like/unlike, then refresh that deity's list for the new count.
  @override
  Future<void> setLike({
    required String id,
    required String deityId,
    required bool liked,
  }) async {
    final dio = _ref.read(apiClientProvider);
    try {
      await dio.post<dynamic>(
        '/api/status/$id/like',
        data: <String, dynamic>{'liked': liked},
      );
      _ref.invalidate(statusListProvider(deityId));
    } catch (_) {
      // Keep the optimistic local state if the network call fails.
    }
  }

  /// Record a view at most once per status per session (best-effort).
  @override
  Future<void> recordView(String id) async {
    final Set<String> viewed = _ref.read(viewedStatusProvider);
    if (viewed.contains(id)) return;
    _ref.read(viewedStatusProvider.notifier).state = <String>{...viewed, id};
    final dio = _ref.read(apiClientProvider);
    try {
      await dio.post<dynamic>('/api/status/$id/view');
    } catch (_) {
      // View tracking is best-effort; ignore failures.
    }
  }
}
