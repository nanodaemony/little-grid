import 'package:flutter/material.dart';

enum BrushType {
  normal,      // 普通画笔
  marker,      // 马克笔（半透明）
  highlighter, // 荧光笔（高亮）
  pressure,    // 压感画笔
}

class Stroke {
  final String id;
  final List<Offset> points;
  final List<double>? pressures;
  final Color color;
  final double size;
  final BrushType brushType;
  final bool isEraser;

  Stroke({
    required this.id,
    required this.points,
    this.pressures,
    required this.color,
    required this.size,
    this.brushType = BrushType.normal,
    this.isEraser = false,
  });

  Stroke copyWith({
    String? id,
    List<Offset>? points,
    List<double>? pressures,
    Color? color,
    double? size,
    BrushType? brushType,
    bool? isEraser,
  }) {
    return Stroke(
      id: id ?? this.id,
      points: points ?? this.points,
      pressures: pressures ?? this.pressures,
      color: color ?? this.color,
      size: size ?? this.size,
      brushType: brushType ?? this.brushType,
      isEraser: isEraser ?? this.isEraser,
    );
  }

  /// 获取笔画的边界
  Rect getBounds() {
    if (points.isEmpty) return Rect.zero;

    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;

    for (final point in points) {
      if (point.dx < minX) minX = point.dx;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dy > maxY) maxY = point.dy;
    }

    return Rect.fromLTRB(minX - size, minY - size, maxX + size, maxY + size);
  }
}