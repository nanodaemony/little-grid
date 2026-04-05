import 'package:flutter/material.dart';

class Sticker {
  final String id;
  final String emoji;  // 使用 emoji 作为贴纸
  final Offset position;
  final double scale;
  final double rotation;

  Sticker({
    required this.id,
    required this.emoji,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  Sticker copyWith({
    String? id,
    String? emoji,
    Offset? position,
    double? scale,
    double? rotation,
  }) {
    return Sticker(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }

  /// 获取贴纸的边界
  Rect getBounds() {
    const baseSize = 48.0;
    final size = baseSize * scale;
    return Rect.fromCenter(
      center: position,
      width: size,
      height: size,
    );
  }
}