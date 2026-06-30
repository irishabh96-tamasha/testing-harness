import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_client.dart';
import 'package:mobile_app/features/books/books_models.dart';

/// The library (`GET /api/books`), optionally filtered by category.
final booksProvider = FutureProvider.autoDispose
    .family<List<Book>, String?>((ref, category) async {
  final dio = ref.watch(apiClientProvider);
  final res = await dio.get<List<dynamic>>(
    '/api/books',
    queryParameters:
        category != null ? <String, dynamic>{'category': category} : null,
  );
  return (res.data ?? <dynamic>[])
      .map((e) => Book.fromJson(e as Map<String, dynamic>))
      .toList();
});

/// A book with its chapters (`GET /api/books/:id`).
final bookDetailProvider =
    FutureProvider.autoDispose.family<BookDetail, String>((ref, id) async {
  final dio = ref.watch(apiClientProvider);
  final res = await dio.get<Map<String, dynamic>>('/api/books/$id');
  return BookDetail.fromJson(res.data ?? <String, dynamic>{});
});
