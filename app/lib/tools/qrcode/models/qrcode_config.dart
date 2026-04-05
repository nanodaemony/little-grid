import 'package:flutter/material.dart';

/// 内容类型
enum ContentType { text, url }

/// 背景类型
enum BackgroundType { solid, preset, custom }

/// Logo类型
enum LogoType { none, emoji, preset, custom }

/// 二维码配置
class QRCodeConfig {
  String content;
  ContentType contentType;
  Color foregroundColor;

  // 背景配置
  BackgroundType backgroundType;
  Color solidBackgroundColor;
  String? presetBackgroundId;
  String? customBackgroundPath;

  // Logo配置
  LogoType logoType;
  String? emojiLogo;
  String? presetLogoId;
  String? customLogoPath;
  double logoSize;

  QRCodeConfig({
    this.content = '',
    this.contentType = ContentType.text,
    this.foregroundColor = Colors.black,
    this.backgroundType = BackgroundType.solid,
    this.solidBackgroundColor = Colors.white,
    this.presetBackgroundId,
    this.customBackgroundPath,
    this.logoType = LogoType.none,
    this.emojiLogo,
    this.presetLogoId,
    this.customLogoPath,
    this.logoSize = 0.2,
  });

  /// 是否有有效内容
  bool get hasContent => content.trim().isNotEmpty;

  /// 是否显示 Logo
  bool get showLogo => logoType != LogoType.none;

  QRCodeConfig copyWith({
    String? content,
    ContentType? contentType,
    Color? foregroundColor,
    BackgroundType? backgroundType,
    Color? solidBackgroundColor,
    String? presetBackgroundId,
    String? customBackgroundPath,
    LogoType? logoType,
    String? emojiLogo,
    String? presetLogoId,
    String? customLogoPath,
    double? logoSize,
  }) {
    return QRCodeConfig(
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundType: backgroundType ?? this.backgroundType,
      solidBackgroundColor: solidBackgroundColor ?? this.solidBackgroundColor,
      presetBackgroundId: presetBackgroundId ?? this.presetBackgroundId,
      customBackgroundPath: customBackgroundPath ?? this.customBackgroundPath,
      logoType: logoType ?? this.logoType,
      emojiLogo: emojiLogo ?? this.emojiLogo,
      presetLogoId: presetLogoId ?? this.presetLogoId,
      customLogoPath: customLogoPath ?? this.customLogoPath,
      logoSize: logoSize ?? this.logoSize,
    );
  }
}