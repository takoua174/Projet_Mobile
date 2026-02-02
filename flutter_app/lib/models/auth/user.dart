/// User model
/// Migrated from Angular auth.model.ts
class User {
  final String id;
  final String email;
  final String username;
  final String? profilePicture;
  final List<int>? favoriteMovies;
  final List<int>? favoriteTvShows;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.profilePicture,
    this.favoriteMovies,
    this.favoriteTvShows,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      profilePicture: json['profilePicture'] as String?,
      favoriteMovies: (json['favoriteMovies'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      favoriteTvShows: (json['favoriteTvShows'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'profilePicture': profilePicture,
      'favoriteMovies': favoriteMovies,
      'favoriteTvShows': favoriteTvShows,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? profilePicture,
    List<int>? favoriteMovies,
    List<int>? favoriteTvShows,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      profilePicture: profilePicture ?? this.profilePicture,
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
      favoriteTvShows: favoriteTvShows ?? this.favoriteTvShows,
    );
  }
}

/// Auth response model
class AuthResponse {
  final String accessToken;
  final User user;

  const AuthResponse({
    required this.accessToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

/// Login request model
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// Register request model
class RegisterRequest {
  final String email;
  final String username;
  final String password;

  const RegisterRequest({
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'password': password,
    };
  }
}

/// Update profile request model
class UpdateProfileRequest {
  final String? username;
  final String? profilePicture;

  const UpdateProfileRequest({
    this.username,
    this.profilePicture,
  });

  Map<String, dynamic> toJson() {
    return {
      if (username != null) 'username': username,
      if (profilePicture != null) 'profilePicture': profilePicture,
    };
  }
}

/// Update password request model
class UpdatePasswordRequest {
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }
}

/// Favorites response model
class FavoritesResponse {
  final List<int> movies;
  final List<int> tvShows;

  const FavoritesResponse({
    required this.movies,
    required this.tvShows,
  });

  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    return FavoritesResponse(
      movies: (json['movies'] as List<dynamic>).map((e) => e as int).toList(),
      tvShows: (json['tvShows'] as List<dynamic>).map((e) => e as int).toList(),
    );
  }
}
