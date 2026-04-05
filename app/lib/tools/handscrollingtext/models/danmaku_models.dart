import 'package:flutter/material.dart';

/// 弹幕显示模式
enum DanmakuMode {
  scroll,   // 滚动模式（从右向左）
  static,   // 常驻模式（居中静止）
}

/// 弹幕配置
class DanmakuConfig {
  final String text;           // 显示文本
  final DanmakuMode mode;      // 显示模式
  final double fontSize;       // 字体大小 (50-300)
  final Color textColor;       // 文字颜色
  final Color backgroundColor; // 背景颜色
  final double speed;          // 滚动速度 (1-10，仅滚动模式)
  final String fontFamily;     // 字体（系统内置）

  DanmakuConfig({
    required this.text,
    this.mode = DanmakuMode.scroll,
    this.fontSize = 120,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.speed = 5,
    this.fontFamily = 'system', // 系统默认字体
  });

  DanmakuConfig copyWith({
    String? text,
    DanmakuMode? mode,
    double? fontSize,
    Color? textColor,
    Color? backgroundColor,
    double? speed,
    String? fontFamily,
  }) {
    return DanmakuConfig(
      text: text ?? this.text,
      mode: mode ?? this.mode,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      speed: speed ?? this.speed,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

/// 预设文案
class PresetText {
  final String text;
  final String category; // 分类：应援/表白/搞笑/通用

  const PresetText({required this.text, required this.category});
}

/// 系统预设文案列表
final List<PresetText> presetTexts = [
  // 应援
  PresetText(text: '加油！', category: '应援'),
  PresetText(text: '我爱你', category: '应援'),
  PresetText(text: '欢迎回家', category: '应援'),
  PresetText(text: '最棒的', category: '应援'),
  // 表白
  PresetText(text: '做我女朋友吧', category: '表白'),
  PresetText(text: '嫁给我', category: '表白'),
  PresetText(text: '喜欢你', category: '表白'),
  // 搞笑
  PresetText(text: '我是路人甲', category: '搞笑'),
  PresetText(text: '求合影', category: '搞笑'),
  PresetText(text: '请投食', category: '搞笑'),
  // 通用
  PresetText(text: '找人', category: '通用'),
  PresetText(text: '求助', category: '通用'),
  PresetText(text: '谢谢', category: '通用'),
];

/// 分类列表
final List<String> categories = ['全部', '应援', '表白', '搞笑', '通用'];

/// 系统字体选项
final Map<String, String> fontOptions = {
  'system': '系统默认',
  'serif': '衬线体',
  'sansSerif': '无衬线',
  'monospace': '等宽字体',
};
