import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accountName: 'flutter_secure_storage',
    ),
  );

  /// Save token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete token
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Save user info (JSON string)
  static Future<void> saveUser(String userJson) async {
    await _storage.write(key: _userKey, value: userJson);
  }

  /// Get user info
  static Future<String?> getUser() async {
    return await _storage.read(key: _userKey);
  }

  /// Delete user info
  static Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
  }

  /// Clear all data
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}
