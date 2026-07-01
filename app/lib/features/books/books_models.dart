/// A book in the library, from `GET /api/books`.
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.category,
  });

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] as String,
        title: json['title'] as String,
        author: json['author'] as String,
        coverUrl: (json['coverUrl'] as String?) ?? '',
        category: (json['category'] as String?) ?? '',
      );

  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String category;

  /// Bundled cover art for books we shipped from Figma; null → use [coverUrl].
  static const Set<String> _bundled = <String>{
    'ramayan',
    'gita',
    'vishnu-puran',
  };
  String? get coverAsset =>
      _bundled.contains(id) ? 'assets/books/$id.png' : null;
}

/// A chapter within a book.
class Chapter {
  const Chapter({
    required this.id,
    required this.section,
    required this.title,
    required this.body,
    required this.audioUrl,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        id: json['id'] as String,
        section: (json['section'] as String?) ?? '',
        title: json['title'] as String,
        body: json['body'] as String,
        audioUrl: (json['audioUrl'] as String?) ?? '',
      );

  final String id;
  final String section;
  final String title;
  final String body;
  final String audioUrl;
}

/// A book plus its ordered chapters, from `GET /api/books/:id`.
class BookDetail {
  const BookDetail({required this.book, required this.chapters});

  factory BookDetail.fromJson(Map<String, dynamic> json) => BookDetail(
        book: Book.fromJson(json),
        chapters: ((json['chapters'] as List<dynamic>?) ?? <dynamic>[])
            .map((e) => Chapter.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final Book book;
  final List<Chapter> chapters;
}
