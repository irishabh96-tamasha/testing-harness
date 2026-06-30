import 'package:mobile_app/core/network/api_client.dart';

/// A deity shown in the Status selector, returned by `GET /api/feed`.
class Deity {
  const Deity({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory Deity.fromJson(Map<String, dynamic> json) => Deity(
        id: json['id'] as String,
        name: json['name'] as String,
        imageUrl: mediaUrl(json['imageUrl'] as String),
      );

  final String id;
  final String name;
  final String imageUrl;
}

/// A status card, returned by `GET /api/status?deity=<id>` (as a list).
class StatusPost {
  const StatusPost({
    required this.id,
    required this.deityId,
    required this.imageUrl,
    required this.authorName,
    required this.authorSubtitle,
    required this.tagline,
    required this.authorAvatarUrl,
    required this.likes,
    required this.views,
  });

  factory StatusPost.fromJson(Map<String, dynamic> json) => StatusPost(
        id: json['id'] as String,
        deityId: json['deityId'] as String,
        imageUrl: json['imageUrl'] as String,
        authorName: json['authorName'] as String,
        authorSubtitle: json['authorSubtitle'] as String,
        tagline: json['tagline'] as String,
        authorAvatarUrl: json['authorAvatarUrl'] as String,
        likes: (json['likes'] as num).toInt(),
        views: (json['views'] as num).toInt(),
      );

  final String id;
  final String deityId;
  final String imageUrl;
  final String authorName;
  final String authorSubtitle;
  final String tagline;
  final String authorAvatarUrl;
  final int likes;
  final int views;
}
