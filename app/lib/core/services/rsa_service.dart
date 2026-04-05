import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart' show rootBundle;

/// RSA加密服务
/// 用于加密密码后传输到后端
class RsaService {
  static Encrypter? _encrypter;

  /// 从assets加载公钥
  /// 需要在pubspec.yaml中配置assets
  static Future<void> initialize() async {
    try {
      // 尝试从assets加载公钥
      final publicKeyPem = await rootBundle.loadString('assets/keys/public_key.pem');
      _encrypter = _createEncrypterFromPem(publicKeyPem);
    } catch (e) {
      // 如果加载失败，使用硬编码的公钥（仅用于开发测试）
      // 生产环境应该从安全渠道获取公钥
      _encrypter = _loadDefaultPublicKey();
    }
  }

  /// 从 PEM 创建加密器
  static Encrypter _createEncrypterFromPem(String pem) {
    final parser = RSAKeyParser();
    final key = parser.parse(pem);
    return Encrypter(RSA(publicKey: key as dynamic));
  }

  /// 使用默认公钥（仅开发测试用）
  /// TODO: 生产环境需要替换为真实公钥
  static Encrypter _loadDefaultPublicKey() {
    // 这是一个示例公钥，实际使用时需要替换
    // 生成命令：openssl genrsa -out private_key.pem 2048
    //          openssl rsa -in private_key.pem -pubout -out public_key.pem
    const publicKeyPem = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA2Z3qX2d8z0nG7K6lLm1n
s5f8dQa7V5oF7dC6jL8s9k2mN3oPqRstUvWxYzAbCdEfGhIjKlMnMnOpQrStUvWxYz
AbCdEfGhIjKlMnOpQrStUvWxYzAbCdEfGhIjKlMnOpQrStUvWxYzAbCdEfGhIjKl
MnOpQrStUvWxYzAbCdEfGhIjKlMnOpQrStUvWxYzAbCdEfGhIjKlMnOpQrStUvWx
YzAbCdEfGhIjKlMnOpQrStUvWxYzAbCdEfGhIjKlMnOpQrStUvWxYzAbCdEfGhIj
KlMnOpQrStUvWxYzAbCdEfGhIjKlMnOpQIDAQAB
-----END PUBLIC KEY-----''';

    return _createEncrypterFromPem(publicKeyPem);
  }

  /// 加密文本
  static String encrypt(String text) {
    if (_encrypter == null) {
      throw Exception('RSA公钥未初始化，请先调用initialize()');
    }

    final encrypted = _encrypter!.encrypt(text);
    return encrypted.base64;
  }

  /// 使用公钥加密密码
  /// 返回Base64编码的加密字符串
  static String encryptPassword(String password) {
    return encrypt(password);
  }
}
