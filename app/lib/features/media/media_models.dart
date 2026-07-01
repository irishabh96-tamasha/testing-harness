import 'package:mobile_app/core/network/api_client.dart';

/// A wallpaper image (`GET /api/wallpapers`).
class Wallpaper {
  const Wallpaper({
    required this.id,
    required this.imageUrl,
    required this.collection,
    required this.likes,
    required this.shares,
    required this.setCount,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) => Wallpaper(
        id: json['id'] as String,
        imageUrl: mediaUrl(json['imageUrl'] as String),
        collection: (json['collection'] as String?) ?? 'new',
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        shares: (json['shares'] as num?)?.toInt() ?? 0,
        setCount: (json['setCount'] as num?)?.toInt() ?? 0,
      );

  final String id;
  final String imageUrl;
  final String collection; // live | new | trending
  final int likes;
  final int shares;
  final int setCount;

  /// Live wallpapers cover both home + lock at once (single action); static
  /// wallpapers offer separate Home / Lockscreen targets.
  bool get isLive => collection == 'live';

  Wallpaper copyWith({int? likes, int? shares, int? setCount}) => Wallpaper(
        id: id,
        imageUrl: imageUrl,
        collection: collection,
        likes: likes ?? this.likes,
        shares: shares ?? this.shares,
        setCount: setCount ?? this.setCount,
      );
}

/// A devotional ringtone (`GET /api/ringtones`).
class Ringtone {
  const Ringtone({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.audioUrl,
    required this.plays,
    required this.downloads,
    required this.likes,
    required this.shares,
    required this.setCount,
  });

  factory Ringtone.fromJson(Map<String, dynamic> json) => Ringtone(
        id: json['id'] as String,
        title: json['title'] as String,
        imageUrl: mediaUrl(json['imageUrl'] as String),
        audioUrl: mediaUrl(json['audioUrl'] as String),
        plays: (json['plays'] as num).toInt(),
        downloads: (json['downloads'] as num).toInt(),
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        shares: (json['shares'] as num?)?.toInt() ?? 0,
        setCount: (json['setCount'] as num?)?.toInt() ?? 0,
      );

  final String id;
  final String title;
  final String imageUrl;
  final String audioUrl;
  final int plays;
  final int downloads;
  final int likes;
  final int shares;
  final int setCount;

  Ringtone copyWith({int? likes, int? shares, int? setCount}) => Ringtone(
        id: id,
        title: title,
        imageUrl: imageUrl,
        audioUrl: audioUrl,
        plays: plays,
        downloads: downloads,
        likes: likes ?? this.likes,
        shares: shares ?? this.shares,
        setCount: setCount ?? this.setCount,
      );
}
