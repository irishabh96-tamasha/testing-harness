import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/media/media_models.dart';

/// Selected deity for each gallery (defaults to "all").
final wallpaperDeityProvider = StateProvider<String>((ref) => 'all');
final ringtoneDeityProvider = StateProvider<String>((ref) => 'all');

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
