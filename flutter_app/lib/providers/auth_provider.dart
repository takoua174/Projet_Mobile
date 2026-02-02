import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import '../models/auth_model.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._apiService) {
    _loadCurrentUser();
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  Future<void> _loadCurrentUser() async {
    _currentUser = await _apiService.getCurrentUser();
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      setLoading(true);
      clearError();

      final request = LoginRequest(email: email, password: password);
      final response = await _apiService.login(request);

      _currentUser = response.user;
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> register(String email, String username, String password) async {
    try {
      setLoading(true);
      clearError();

      final request = RegisterRequest(
        email: email,
        username: username,
        password: password,
      );
      final response = await _apiService.register(request);

      _currentUser = response.user;
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> updateProfile({String? username, String? profilePicture}) async {
    try {
      setLoading(true);
      clearError();

      final request = UpdateProfileRequest(
        username: username,
        profilePicture: profilePicture,
      );
      final user = await _apiService.updateProfile(request);

      _currentUser = user;
      setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      setLoading(true);
      clearError();

      final request = UpdatePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      await _apiService.updatePassword(request);

      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final user = await _apiService.getProfile();
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      // Silent fail
    }
  }
}

// ========== Riverpod Providers for HomeScreen Migration ==========

/// API Service Provider
final apiServiceProvider = riverpod.Provider<ApiService>((ref) {
  return ApiService();
});

/// Auth Provider (ChangeNotifier)
final authChangeNotifierProvider = riverpod.ChangeNotifierProvider<AuthProvider>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthProvider(apiService);
});

/// Current User Provider (Riverpod)
final currentUserProvider = riverpod.Provider<User?>((ref) {
  final authProvider = ref.watch(authChangeNotifierProvider);
  return authProvider.currentUser;
});

/// Auth Service Provider (for compatibility with HomeScreen)
final authServiceProvider = riverpod.Provider<ApiService>((ref) {
  return ref.watch(apiServiceProvider);
});
