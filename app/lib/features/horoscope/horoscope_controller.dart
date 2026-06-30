import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/horoscope/horoscope_models.dart';

/// The 12 zodiac signs with readings (`GET /api/horoscope`).
final horoscopeProvider = FutureProvider.autoDispose<List<Sign>>((ref) async {
  final dio = ref.watch(apiClientProvider);
  final res = await dio.get<List<dynamic>>('/api/horoscope');
  return (res.data ?? <dynamic>[])
      .map((e) => Sign.fromJson(e as Map<String, dynamic>))
      .toList();
});
