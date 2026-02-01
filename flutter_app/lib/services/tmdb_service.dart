// filepath: lib/services/tmdb_service.dart
import 'package:dio/dio.dart';
import '../models/tmdb_models.dart';
import '../config/app_config.dart';

class TmdbService {
  final Dio _dio;

  TmdbService(this._dio);

  Future<MovieDetails> getMovieDetails(int id) async {
    try {
      final response = await _dio.get('${AppConfig.tmdbBaseUrl}/movie/$id', queryParameters: {
        'api_key': AppConfig.tmdbApiKey,
      });
      return MovieDetails.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load movie details: $e');
    }
  }

  Future<List<Cast>> getMovieCredits(int id) async {
    try {
      final response = await _dio.get('${AppConfig.tmdbBaseUrl}/movie/$id/credits', queryParameters: {
        'api_key': AppConfig.tmdbApiKey,
      });
      final list = response.data['cast'] as List;
      return list.map((e) => Cast.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load movie credits: $e');
    }
  }

  Future<List<Video>> getMovieVideos(int id) async {
    try {
      final response = await _dio.get('${AppConfig.tmdbBaseUrl}/movie/$id/videos', queryParameters: {
        'api_key': AppConfig.tmdbApiKey,
      });
      final list = response.data['results'] as List;
      return list
          .map((e) => Video.fromJson(e))
          .where((v) => v.site == 'YouTube')
          .toList();
    } catch (e) {
      throw Exception('Failed to load movie videos: $e');
    }
  }

  Future<List<MovieDetails>> getSimilarMovies(int id) async {
     try {
      final response = await _dio.get('${AppConfig.tmdbBaseUrl}/movie/$id/similar', queryParameters: {
        'api_key': AppConfig.tmdbApiKey,
      });
      final list = response.data['results'] as List;
      return list.map((e) => MovieDetails.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load similar movies: $e');
    }
  }

  Future<List<Review>> getMovieReviews(int id) async {
     try {
      final response = await _dio.get('${AppConfig.tmdbBaseUrl}/movie/$id/reviews', queryParameters: {
        'api_key': AppConfig.tmdbApiKey,
      });
      final list = response.data['results'] as List;
      return list.map((e) => Review.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load movie reviews: $e');
    }
  }

  Future<TVShowDetails> getTVShowDetails(int id) async {
    try {
      final response = await _dio.get('${AppConfig.tmdbBaseUrl}/tv/$id', queryParameters: {
        'api_key': AppConfig.tmdbApiKey,
      });
      return TVShowDetails.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load TV show details: $e');
    }
  }

  Future<List<Cast>> getTVShowCredits(int id) async {
    try {
      final response = await _dio.get('${AppConfig.tmdbBaseUrl}/tv/$id/credits', queryParameters: {
        'api_key': AppConfig.tmdbApiKey,
      });
      final list = response.data['cast'] as List;
      return list.map((e) => Cast.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load TV show credits: $e');
    }
  }

   Future<List<Video>> getTVShowVideos(int id) async {
    try {
      final response = await _dio.get('${AppConfig.tmdbBaseUrl}/tv/$id/videos', queryParameters: {
        'api_key': AppConfig.tmdbApiKey,
      });
      final list = response.data['results'] as List;
      return list
          .map((e) => Video.fromJson(e))
          .where((v) => v.site == 'YouTube')
          .toList();
    } catch (e) {
      throw Exception('Failed to load TV show videos: $e');
    }
  }

  Future<List<TVShowDetails>> getSimilarTVShows(int id) async {
     try {
      final response = await _dio.get('${AppConfig.tmdbBaseUrl}/tv/$id/similar', queryParameters: {
        'api_key': AppConfig.tmdbApiKey,
      });
      final list = response.data['results'] as List;
      return list.map((e) => TVShowDetails.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load similar TV shows: $e');
    }
  }
}


