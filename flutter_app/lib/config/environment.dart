// Export AppConfig as Environment for compatibility
export 'app_config.dart';

// Alias for migration compatibility
class Environment {
  static String get apiUrl => 'http://localhost:3000';
  static String get tmdbBaseUrl => 'https://api.themoviedb.org/3';
  static String get tmdbApiKey => '0ec8764a109b727d05b2b31d218d6099';
  static String get tmdbImageBaseUrl => 'https://image.tmdb.org/t/p';
}
