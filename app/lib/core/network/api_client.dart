import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base URL for the backend API. Override at build time:
///   flutter run --dart-define=API_BASE_URL=https://api.example.com
const String _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

/// Resolve a media path returned by the backend to an absolute URL.
///
/// The API stores devotional images as root-relative paths (e.g.
/// `/media/wallpapers/durga.jpg`) served by the backend's static handler.
/// Absolute URLs (picsum, SoundHelix, …) are passed through unchanged. Use this
/// for both `Image.network` and the native wallpaper/ringtone channels.
String mediaUrl(String path) {
  if (path.isEmpty) return path;
  if (path.startsWith('/')) return '$_apiBaseUrl$path';
  return path;
}

/// Shared Dio client for talking to the Express backend.
final Provider<Dio> apiClientProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );
});
