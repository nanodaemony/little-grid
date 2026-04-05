import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user.dart';
import 'secure_storage.dart';

class AuthService {
  static const _baseUrl = 'http://8.137.39.155:8080/api/app/auth';

  /// Phone login
  static Future<AuthResult> loginWithPhone(String phone, String password, String deviceId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'password': password,
        'deviceId': deviceId,
      }),
    );

    if (response.statusCode == 200) {
      final result = AuthResult.fromJson(jsonDecode(response.body));
      await _saveAuthData(result);
      return result;
    } else {
      throw Exception('登录失败: ${response.body}');
    }
  }

  /// Phone registration
  static Future<AuthResult> register(String phone, String password, String deviceId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'password': password,
        'deviceId': deviceId,
      }),
    );

    if (response.statusCode == 200) {
      final result = AuthResult.fromJson(jsonDecode(response.body));
      await _saveAuthData(result);
      return result;
    } else if (response.statusCode == 409) {
      throw Exception('该手机号已注册，请直接登录');
    } else {
      throw Exception('注册失败: ${response.body}');
    }
  }

  /// Bind phone number for user
  static Future<void> bindPhone(String phone, String password) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('请先登录');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/bind/phone'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Update current user info
      final user = await getCurrentUser();
      if (user != null) {
        // Refresh user data
        await SecureStorage.saveUser(jsonEncode({
          ...jsonDecode(user.toJsonString()),
          'phone': phone,
        }));
      }
      return;
    } else if (response.statusCode == 400) {
      throw Exception('该手机号已被其他账号绑定');
    } else {
      throw Exception('绑定失败: ${response.body}');
    }
  }

  /// Logout
  static Future<void> logout() async {
    final token = await SecureStorage.getToken();
    if (token != null) {
      try {
        await http.delete(
          Uri.parse('$_baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token,
          },
        );
      } catch (e) {
        // Ignore network errors
      }
    }
    await SecureStorage.clear();
  }

  /// Get current token
  static Future<String?> getToken() async {
    return await SecureStorage.getToken();
  }

  /// Get current user
  static Future<User?> getCurrentUser() async {
    final userJson = await SecureStorage.getUser();
    if (userJson != null) {
      return User.fromJsonString(userJson);
    }
    return null;
  }

  /// Check login status
  static Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save auth data
  static Future<void> _saveAuthData(AuthResult result) async {
    await SecureStorage.saveToken(result.token);
    await SecureStorage.saveUser(result.user.toJsonString());
  }

  /// Bind email for password reset
  static Future<void> bindEmail(String email) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('请先登录');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/user/bind-email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: jsonEncode({
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('绑定失败: ${response.body}');
    }
  }

  /// Send password reset verification code
  static Future<void> sendResetCode(String phone) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/send-reset-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('发送失败: ${response.body}');
    }
  }

  /// Reset password with verification code
  static Future<void> resetPassword(String phone, String code, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'code': code,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('重置失败: ${response.body}');
    }
  }
}
