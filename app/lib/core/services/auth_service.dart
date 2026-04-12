import 'dart:convert';
import '../../models/user.dart';
import 'secure_storage.dart';
import 'http_client.dart';
import '../utils/logger.dart';
import '../constants/api_constants.dart';

class AuthService {
  static const _baseUrl = '${ApiConstants.baseUrl}${ApiConstants.appApiPrefix}/auth';

  /// Phone login
  static Future<AuthResult> loginWithPhone(String phone, String password, String deviceId) async {
    final response = await HttpClient.post(
      Uri.parse('$_baseUrl/login'),
      body: {
        'phone': phone,
        'password': password,
        'deviceId': deviceId,
      },
      module: 'AuthService',
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
  static Future<AuthResult> register(String phone, String password, String deviceId, {String? nickname}) async {
    final response = await HttpClient.post(
      Uri.parse('$_baseUrl/register'),
      body: {
        'phone': phone,
        'password': password,
        'deviceId': deviceId,
        if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
      },
      module: 'AuthService',
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

    final response = await HttpClient.post(
      Uri.parse('$_baseUrl/bind/phone'),
      headers: {'Authorization': token},
      body: {
        'phone': phone,
        'password': password,
      },
      module: 'AuthService',
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
        await HttpClient.delete(
          Uri.parse('$_baseUrl/logout'),
          headers: {'Authorization': token},
          module: 'AuthService',
        );
      } catch (e) {
        AppLogger.w('Logout request failed', module: 'AuthService');
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

    final response = await HttpClient.post(
      Uri.parse('$_baseUrl/user/bind-email'),
      headers: {'Authorization': token},
      body: {'email': email},
      module: 'AuthService',
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('绑定失败: ${response.body}');
    }
  }

  /// Send password reset verification code
  static Future<void> sendResetCode(String phone) async {
    final response = await HttpClient.post(
      Uri.parse('$_baseUrl/auth/send-reset-code'),
      body: {'phone': phone},
      module: 'AuthService',
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('发送失败: ${response.body}');
    }
  }

  /// Reset password with verification code
  static Future<void> resetPassword(String phone, String code, String password) async {
    final response = await HttpClient.post(
      Uri.parse('$_baseUrl/auth/reset-password'),
      body: {
        'phone': phone,
        'code': code,
        'password': password,
      },
      module: 'AuthService',
    );

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('重置失败: ${response.body}');
    }
  }

  /// Update user info
  static Future<User> updateUser({String? nickname, String? email}) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('请先登录');
    }

    final Map<String, dynamic> body = {};
    if (nickname != null) body['nickname'] = nickname;
    if (email != null) body['email'] = email;

    final response = await HttpClient.post(
      Uri.parse('$_baseUrl/user/update'),
      headers: {'Authorization': token},
      body: body,
      module: 'AuthService',
    );

    if (response.statusCode == 200) {
      final userJson = jsonDecode(response.body);
      final user = User.fromJson(userJson);
      await SecureStorage.saveUser(user.toJsonString());
      return user;
    } else {
      throw Exception('更新失败: ${response.body}');
    }
  }
}
