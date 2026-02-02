import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/user.dart';
import '../config/environment.dart';

/// Authentication Service
/// Migrated from Angular AuthService
/// 
/// Manages user authentication, token storage, and user profile operations
class AuthService {
  static const String _tokenKey = 'access_token';
  static const String _userKey = 'current_user';

  final String _apiUrl = '${Environment.apiUrl}/auth';
  final String _usersUrl = '${Environment.apiUrl}/users';

  final ValueNotifier<User?> currentUserNotifier = ValueNotifier<User?>(null);

  AuthService() {
    _loadUserFromStorage();
  }

  /// Load user from local storage
  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      try {
        final userJson = jsonDecode(userStr) as Map<String, dynamic>;
        currentUserNotifier.value = User.fromJson(userJson);
      } catch (e) {
        debugPrint('Error loading user from storage: $e');
      }
    }
  }

  /// Get current user value
  User? get currentUser => currentUserNotifier.value;

  /// Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  /// Register new user
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        await _storeAuthData(authResponse);
        return authResponse;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Registration error: $e');
      rethrow;
    }
  }

  /// Login user
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$_apiUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        await _storeAuthData(authResponse);
        return authResponse;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    currentUserNotifier.value = null;
  }

  /// Get user profile
  Future<User> getProfile() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$_usersUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        await _updateStoredUser(user);
        return user;
      } else {
        throw Exception('Failed to get profile: ${response.body}');
      }
    } catch (e) {
      debugPrint('Get profile error: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<User> updateProfile(UpdateProfileRequest request) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$_usersUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final user = User.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        await _updateStoredUser(user);
        return user;
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  /// Update password
  Future<void> updatePassword(UpdatePasswordRequest request) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$_usersUrl/password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to update password: ${response.body}');
      }
    } catch (e) {
      debugPrint('Update password error: $e');
      rethrow;
    }
  }

  /// Verify username availability
  Future<bool> verifyUsername(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/usernames-available/$username'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        return result['available'] as bool;
      } else {
        throw Exception('Failed to verify username: ${response.body}');
      }
    } catch (e) {
      debugPrint('Verify username error: $e');
      rethrow;
    }
  }

  /// Toggle favorite content
  Future<bool> toggleFavorite(int contentId, String contentType) async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse('$_usersUrl/favorites/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'contentId': contentId,
          'contentType': contentType,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        // Refresh profile to update favorites
        await getProfile();
        return result['isFavorite'] as bool;
      } else {
        throw Exception('Failed to toggle favorite: ${response.body}');
      }
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
      rethrow;
    }
  }

  /// Get user favorites
  Future<FavoritesResponse> getFavorites() async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$_usersUrl/favorites'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return FavoritesResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to get favorites: ${response.body}');
      }
    } catch (e) {
      debugPrint('Get favorites error: $e');
      rethrow;
    }
  }

  /// Verify token validity
  Future<bool> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('$_apiUrl/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Verify token error: $e');
      return false;
    }
  }

  /// Store authentication data
  Future<void> _storeAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, authResponse.accessToken);
    await prefs.setString(_userKey, jsonEncode(authResponse.user.toJson()));
    currentUserNotifier.value = authResponse.user;
  }

  /// Update stored user data
  Future<void> _updateStoredUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    currentUserNotifier.value = user;
  }
}
