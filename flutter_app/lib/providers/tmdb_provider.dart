import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:dio/dio.dart';
import '../services/tmdb_service.dart';
import '../models/tmdb_models.dart';

/// Dio Provider
final dioProvider = riverpod.Provider<Dio>((ref) {
  return Dio();
});

/// TMDB Service Provider
final tmdbServiceProvider = riverpod.Provider<TmdbService>((ref) {
  final dio = ref.watch(dioProvider);
  return TmdbService(dio);
});

/// Movie Genres Provider
final movieGenresProvider = riverpod.FutureProvider<List<Genre>>((ref) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
  return await tmdbService.getMovieGenres();
});

/// TV Genres Provider
final tvGenresProvider = riverpod.FutureProvider<List<Genre>>((ref) async {
  final tmdbService = ref.watch(tmdbServiceProvider);
  return await tmdbService.getTVGenres();
});
