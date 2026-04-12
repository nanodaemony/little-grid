import 'dart:convert';

class User {
  final int id;
  final String? phone;
  final String? nickname;
  final String? avatar;
  final String? avatarUrl;
  final String? email;

  User({
    required this.id,
    this.phone,
    this.nickname,
    this.avatar,
    this.avatarUrl,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      phone: json['phone'] as String?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'nickname': nickname,
      'avatar': avatar,
      'avatarUrl': avatarUrl,
      'email': email,
    };
  }

  String toJsonString() => jsonEncode(toJson());

  factory User.fromJsonString(String jsonString) {
    return User.fromJson(jsonDecode(jsonString));
  }
}

class AuthResult {
  final String token;
  final User user;

  AuthResult({
    required this.token,
    required this.user,
  });

  factory AuthResult.fromJson(Map<String, dynamic> json) {
    return AuthResult(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
