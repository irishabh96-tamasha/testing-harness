import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/feed/feed_models.dart';

/// The Home "trending" feed — all statuses across deities
/// (`GET /api/home/feed`).
final homeFeedProvider = FutureProvider.autoDispose<List<StatusPost>>(
  (ref) async {
    final dio = ref.watch(apiClientProvider);
    final res = await dio.get<List<dynamic>>('/api/home/feed');
    return (res.data ?? <dynamic>[])
        .map((e) => StatusPost.fromJson(e as Map<String, dynamic>))
        .toList();
  },
);
