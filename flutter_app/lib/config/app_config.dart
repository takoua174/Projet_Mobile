import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return 'http://10.0.2.2:3000';
    }
  }

  // API Endpoints
  static String get authEndpoint => '$apiBaseUrl/auth';
  static String get usersEndpoint => '$apiBaseUrl/users';

  // Storage Keys
  static const String tokenKey = 'access_token';
  static const String userKey = 'current_user';

  // TMDB Config
  static const String tmdbApiKey = '0ec8764a109b727d05b2b31d218d6099';
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';
}
