import 'package:flutter/foundation.dart';
import '../models/tmdb_models.dart';
import '../services/tmdb_service.dart';

class TvDetailProvider extends ChangeNotifier {
  final TmdbService _tmdbService;

  TVShowDetails? tvShow;
  List<Cast> cast = [];
  List<Video> videos = [];
  List<TVShowDetails> similarShows = [];


  bool isLoading = false;
  String? error;

  TvDetailProvider(this._tmdbService);

  Future<void> loadTvShow(int id) async {
    isLoading = true;
    error = null;
     // Clear previous data
    tvShow = null;
    cast = [];
    videos = [];
    similarShows = [];

    notifyListeners();

    try {
      final results = await Future.wait([
        _tmdbService.getTVShowDetails(id),
        _tmdbService.getTVShowCredits(id),
        _tmdbService.getTVShowVideos(id),
        _tmdbService.getSimilarTVShows(id),
      ]);

      tvShow = results[0] as TVShowDetails;
      cast = results[1] as List<Cast>;
      videos = results[2] as List<Video>;
      similarShows = results[3] as List<TVShowDetails>;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

