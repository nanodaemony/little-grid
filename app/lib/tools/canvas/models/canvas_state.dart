import 'dart:ui';

import 'stroke.dart';
import 'shape.dart';
import 'sticker.dart';

class CanvasState {
  final List<Stroke> strokes;
  final List<CanvasShape> shapes;
  final List<Sticker> stickers;
  final String? backgroundImage;

  CanvasState({
    this.strokes = const [],
    this.shapes = const [],
    this.stickers = const [],
    this.backgroundImage,
  });

  CanvasState copyWith({
    List<Stroke>? strokes,
    List<CanvasShape>? shapes,
    List<Sticker>? stickers,
    String? backgroundImage,
  }) {
    return CanvasState(
      strokes: strokes ?? this.strokes,
      shapes: shapes ?? this.shapes,
      stickers: stickers ?? this.stickers,
      backgroundImage: backgroundImage ?? this.backgroundImage,
    );
  }

  /// 检查画布是否为空
  bool get isEmpty =>
      strokes.isEmpty && shapes.isEmpty && stickers.isEmpty;

  /// 获取所有内容的边界
  Rect getContentBounds() {
    final allBounds = <Rect>[];

    for (final stroke in strokes) {
      allBounds.add(stroke.getBounds());
    }
    for (final shape in shapes) {
      allBounds.add(shape.getBounds());
    }
    for (final sticker in stickers) {
      allBounds.add(sticker.getBounds());
    }

    if (allBounds.isEmpty) return Rect.zero;

    double minX = allBounds.first.left;
    double maxX = allBounds.first.right;
    double minY = allBounds.first.top;
    double maxY = allBounds.first.bottom;

    for (final bounds in allBounds) {
      if (bounds.left < minX) minX = bounds.left;
      if (bounds.right > maxX) maxX = bounds.right;
      if (bounds.top < minY) minY = bounds.top;
      if (bounds.bottom > maxY) maxY = bounds.bottom;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}