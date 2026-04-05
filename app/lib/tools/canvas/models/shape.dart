import 'package:flutter/material.dart';

enum ShapeType {
  line,
  rectangle,
  circle,
  triangle,
  arrow,
}

class CanvasShape {
  final String id;
  final ShapeType type;
  final Rect bounds;
  final Color color;
  final double strokeWidth;
  final bool filled;
  final double rotation;

  CanvasShape({
    required this.id,
    required this.type,
    required this.bounds,
    required this.color,
    this.strokeWidth = 2.0,
    this.filled = false,
    this.rotation = 0.0,
  });

  CanvasShape copyWith({
    String? id,
    ShapeType? type,
    Rect? bounds,
    Color? color,
    double? strokeWidth,
    bool? filled,
    double? rotation,
  }) {
    return CanvasShape(
      id: id ?? this.id,
      type: type ?? this.type,
      bounds: bounds ?? this.bounds,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      filled: filled ?? this.filled,
      rotation: rotation ?? this.rotation,
    );
  }

  /// 获取形状的边界
  Rect getBounds() {
    return bounds;
  }
}