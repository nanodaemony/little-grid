import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'models/qrcode_config.dart';

/// 二维码生成服务
class QRCodeService extends ChangeNotifier {
  QRCodeConfig _config = QRCodeConfig();
  final GlobalKey repaintKey = GlobalKey();

  QRCodeConfig get config => _config;

  /// 更新内容
  void setContent(String content) {
    _config = _config.copyWith(content: content);
    notifyListeners();
  }

  /// 更新内容类型
  void setContentType(ContentType type) {
    _config = _config.copyWith(contentType: type);
    notifyListeners();
  }

  /// 更新前景色
  void setForegroundColor(Color color) {
    _config = _config.copyWith(foregroundColor: color);
    notifyListeners();
  }

  /// 设置纯色背景
  void setSolidBackground(Color color) {
    _config = _config.copyWith(
      backgroundType: BackgroundType.solid,
      solidBackgroundColor: color,
    );
    notifyListeners();
  }

  /// 设置预设背景
  void setPresetBackground(String id) {
    _config = _config.copyWith(
      backgroundType: BackgroundType.preset,
      presetBackgroundId: id,
    );
    notifyListeners();
  }

  /// 设置自定义背景
  void setCustomBackground(String? path) {
    _config = _config.copyWith(
      backgroundType: path != null ? BackgroundType.custom : BackgroundType.solid,
      customBackgroundPath: path,
    );
    notifyListeners();
  }

  /// 设置 Logo 类型
  void setLogoType(LogoType type) {
    _config = _config.copyWith(logoType: type);
    notifyListeners();
  }

  /// 设置 Emoji Logo
  void setEmojiLogo(String emoji) {
    _config = _config.copyWith(
      logoType: LogoType.emoji,
      emojiLogo: emoji,
    );
    notifyListeners();
  }

  /// 设置预设 Logo
  void setPresetLogo(String id) {
    _config = _config.copyWith(
      logoType: LogoType.preset,
      presetLogoId: id,
    );
    notifyListeners();
  }

  /// 设置自定义 Logo
  void setCustomLogo(String? path) {
    _config = _config.copyWith(
      logoType: path != null ? LogoType.custom : LogoType.none,
      customLogoPath: path,
    );
    notifyListeners();
  }

  /// 重置配置
  void reset() {
    _config = QRCodeConfig();
    notifyListeners();
  }

  /// 导出为图片数据
  Future<Uint8List?> exportToImage() async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Export error: $e');
      return null;
    }
  }

  /// 保存到相册
  Future<bool> saveToGallery() async {
    final data = await exportToImage();
    if (data == null) return false;

    try {
      await Gal.putImageBytes(data);
      return true;
    } catch (e) {
      debugPrint('Save to gallery error: $e');
      return false;
    }
  }
}