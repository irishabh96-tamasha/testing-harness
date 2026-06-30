/// A zodiac sign + today's reading, from `GET /api/horoscope`.
class Sign {
  const Sign({required this.id, required this.name, required this.reading});

  factory Sign.fromJson(Map<String, dynamic> json) => Sign(
        id: json['id'] as String,
        name: json['name'] as String,
        reading: json['reading'] as String,
      );

  final String id;
  final String name;
  final String reading;
}
