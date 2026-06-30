/// A wallpaper image (`GET /api/wallpapers`).
class Wallpaper {
  const Wallpaper({
    required this.id,
    required this.imageUrl,
    required this.collection,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) => Wallpaper(
        id: json['id'] as String,
        imageUrl: json['imageUrl'] as String,
        collection: (json['collection'] as String?) ?? 'new',
      );

  final String id;
  final String imageUrl;
  final String collection; // live | new | trending
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
  });

  factory Ringtone.fromJson(Map<String, dynamic> json) => Ringtone(
        id: json['id'] as String,
        title: json['title'] as String,
        imageUrl: json['imageUrl'] as String,
        audioUrl: json['audioUrl'] as String,
        plays: (json['plays'] as num).toInt(),
        downloads: (json['downloads'] as num).toInt(),
      );

  final String id;
  final String title;
  final String imageUrl;
  final String audioUrl;
  final int plays;
  final int downloads;
}
