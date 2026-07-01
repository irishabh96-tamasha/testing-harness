import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/profile/profile_models.dart';

/// The current profile (`GET /api/profile`).
final profileProvider = FutureProvider.autoDispose<Profile>((ref) async {
  final dio = ref.watch(apiClientProvider);
  final res = await dio.get<Map<String, dynamic>>('/api/profile');
  return Profile.fromJson(res.data ?? <String, dynamic>{});
});

/// Persists profile edits (`PUT /api/profile`). An interface so tests can stub.
abstract class ProfileActions {
  Future<void> save(Map<String, dynamic> patch);
}

final profileActionsProvider =
    Provider<ProfileActions>((ref) => _ApiProfileActions(ref));

class _ApiProfileActions implements ProfileActions {
  _ApiProfileActions(this._ref);

  final Ref _ref;

  @override
  Future<void> save(Map<String, dynamic> patch) async {
    final dio = _ref.read(apiClientProvider);
    await dio.put<Map<String, dynamic>>('/api/profile', data: patch);
    _ref.invalidate(profileProvider);
  }
}
