class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Video {
  final String key;
  final String name;
  final String site;
  final String type;

  Video({
    required this.key,
    required this.name,
    required this.site,
    required this.type,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      key: json['key'],
      name: json['name'],
      site: json['site'],
      type: json['type'],
    );
  }
}

class Cast {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  Cast({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  factory Cast.fromJson(Map<String, dynamic> json) {
    return Cast(
      id: json['id'],
      name: json['name'],
      character: json['character'] ?? '',
      profilePath: json['profile_path'],
    );
  }
}

class Review {
  final String id;
  final String author;
  final String content;
  final String createdAt;

  Review({
    required this.id,
    required this.author,
    required this.content,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      author: json['author'],
      content: json['content'],
      createdAt: json['created_at'],
    );
  }
}

class MovieDetails {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int runtime;
  final List<Genre> genres;
  final String tagline;

  MovieDetails({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.runtime,
    required this.genres,
    required this.tagline,
  });

  factory MovieDetails.fromJson(Map<String, dynamic> json) {
    return MovieDetails(
      id: json['id'],
      title: json['title'],
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      releaseDate: json['release_date'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      runtime: json['runtime'] ?? 0,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e))
              .toList() ??
          [],
      tagline: json['tagline'] ?? '',
    );
  }
}

class TVShowDetails {
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String firstAirDate;
  final double voteAverage;
  final int numberOfSeasons;
  final List<Genre> genres;
  final List<Season> seasons;

  TVShowDetails({
    required this.id,
    required this.name,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.firstAirDate,
    required this.voteAverage,
    required this.numberOfSeasons,
    required this.genres,
    required this.seasons,
  });

  factory TVShowDetails.fromJson(Map<String, dynamic> json) {
    return TVShowDetails(
      id: json['id'],
      name: json['name'],
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      firstAirDate: json['first_air_date'] ?? '',
      voteAverage: (json['vote_average'] as num).toDouble(),
      numberOfSeasons: json['number_of_seasons'] ?? 0,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e))
              .toList() ??
          [],
      seasons: (json['seasons'] as List<dynamic>?)
              ?.map((e) => Season.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Season {
  final int seasonNumber;
  final String? posterPath;
  final String name;
  final int episodeCount;

  Season({
    required this.seasonNumber,
    this.posterPath,
    required this.name,
    required this.episodeCount,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      seasonNumber: json['season_number'],
      posterPath: json['poster_path'],
      name: json['name'],
      episodeCount: json['episode_count'],
    );
  }
}
