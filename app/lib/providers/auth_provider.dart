import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;

  /// Initialize (called on app start)
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      _currentUser = await AuthService.getCurrentUser();
      _isLoggedIn = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Phone login
  Future<bool> login(String phone, String password, String deviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AuthService.loginWithPhone(phone, password, deviceId);
      _currentUser = result.user;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  /// Phone registration
  Future<bool> register(String phone, String password, String deviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AuthService.register(phone, password, deviceId);
      _currentUser = result.user;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  /// Bind phone number
  Future<bool> bindPhone(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.bindPhone(phone, password);
      // Refresh user info
      _currentUser = await AuthService.getCurrentUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await AuthService.logout();
    _currentUser = null;
    _isLoggedIn = false;
    _isLoading = false;
    notifyListeners();
  }

  /// Bind email for password reset
  Future<bool> bindEmail(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.bindEmail(email);
      _currentUser = await AuthService.getCurrentUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  /// Send password reset verification code
  Future<bool> sendResetCode(String phone) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.sendResetCode(phone);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }

  /// Reset password with verification code
  Future<bool> resetPassword(String phone, String code, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.resetPassword(phone, code, password);
      await logout();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }
}
