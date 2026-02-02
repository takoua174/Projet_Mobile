import 'package:flutter/foundation.dart';
import '../models/tmdb_models.dart';
import '../services/tmdb_service.dart';
import '../services/api_service.dart';

class MovieDetailProvider extends ChangeNotifier {
  final TmdbService _tmdbService;
  final ApiService _apiService;

  MovieDetails? movie;
  List<Cast> cast = [];
  List<Video> videos = [];
  List<MovieDetails> similarMovies = [];
  List<Review> reviews = []; // TMDB reviews
  List<dynamic> userReviews = []; // Local API reviews

  bool isLoading = false;
  String? error;

  MovieDetailProvider(this._tmdbService, this._apiService);

  Future<void> loadMovie(int id) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Use Future.wait to fetch data in parallel
      final results = await Future.wait([
        _tmdbService.getMovieDetails(id),
        _tmdbService.getMovieCredits(id),
        _tmdbService.getMovieVideos(id),
        _tmdbService.getSimilarMovies(id),
        _tmdbService.getMovieReviews(id),
      ]);

      movie = results[0] as MovieDetails;
      cast = results[1] as List<Cast>;
      videos = results[2] as List<Video>;
      similarMovies = results[3] as List<MovieDetails>;
      reviews = results[4] as List<Review>;

      // Load user reviews from local API
      await loadReviews(id);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReviews(int movieId) async {
    try {
      final response = await _apiService.getReviewsByMovieId(movieId.toString());
      userReviews = response;
      notifyListeners();
    } catch (e) {
      // Silent fail - user reviews are optional
      userReviews = [];
      notifyListeners();
    }
  }
}

