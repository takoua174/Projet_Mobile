/// Genre model
/// Migrated from Angular tmdb.model.ts
class Genre {
  final int id;
  final String name;

  const Genre({
    required this.id,
    required this.name,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

/// Genres response wrapper
class GenresResponse {
  final List<Genre> genres;

  const GenresResponse({required this.genres});

  factory GenresResponse.fromJson(Map<String, dynamic> json) {
    return GenresResponse(
      genres: (json['genres'] as List<dynamic>)
          .map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
