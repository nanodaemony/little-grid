import 'dart:math';
import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart' as freehand;
import '../models/stroke.dart';
import '../models/shape.dart';
import '../models/sticker.dart';
import '../models/canvas_state.dart';
import '../services/drawing_service.dart';

class CanvasWidget extends StatefulWidget {
  final DrawingService service;
  final GlobalKey repaintKey;

  const CanvasWidget({
    super.key,
    required this.service,
    required this.repaintKey,
  });

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RepaintBoundary(
      key: widget.repaintKey,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (details) {
          if (widget.service.mode == DrawMode.brush || widget.service.mode == DrawMode.eraser) {
            widget.service.startStroke(details.localPosition);
          } else if (widget.service.mode == DrawMode.shape) {
            widget.service.startShape(details.localPosition);
          }
        },
        onPanUpdate: (details) {
          if (widget.service.mode == DrawMode.brush || widget.service.mode == DrawMode.eraser) {
            widget.service.addPoint(details.localPosition);
          } else if (widget.service.mode == DrawMode.shape) {
            widget.service.updateShape(details.localPosition);
          }
        },
        onPanEnd: (_) {
          if (widget.service.mode == DrawMode.brush || widget.service.mode == DrawMode.eraser) {
            widget.service.endStroke();
          } else if (widget.service.mode == DrawMode.shape) {
            widget.service.endShape();
          }
        },
        child: Container(
          color: Colors.white,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: _CanvasPainter(
                  state: widget.service.state,
                  currentStroke: widget.service.currentStroke,
                  currentShapeRect: widget.service.currentShapeRect,
                  shapeType: widget.service.shapeType,
                  shapeFilled: widget.service.shapeFilled,
                  currentColor: widget.service.currentColor,
                  currentSize: widget.service.currentSize,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final CanvasState state;
  final Stroke? currentStroke;
  final Rect? currentShapeRect;
  final ShapeType shapeType;
  final bool shapeFilled;
  final Color currentColor;
  final double currentSize;

  _CanvasPainter({
    required this.state,
    this.currentStroke,
    this.currentShapeRect,
    required this.shapeType,
    required this.shapeFilled,
    required this.currentColor,
    required this.currentSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制已保存的笔画
    for (final stroke in state.strokes) {
      _drawStroke(canvas, stroke);
    }

    // 绘制当前笔画
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }

    // 绘制已保存的形状
    for (final shape in state.shapes) {
      _drawShape(canvas, shape);
    }

    // 绘制当前形状预览
    if (currentShapeRect != null) {
      _drawShapePreview(canvas, currentShapeRect!);
    }

    // 绘制贴纸
    for (final sticker in state.stickers) {
      _drawSticker(canvas, sticker);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final points = stroke.points.map((p) => freehand.Point(p.dx, p.dy)).toList();

    final outline = freehand.getStroke(
      points,
      size: stroke.size * 2,
      smoothing: 0.5,
      thinning: stroke.brushType == BrushType.pressure ? 0.7 : 0.0,
    );

    if (outline.isEmpty) return;

    final path = Path()..moveTo(outline[0].x, outline[0].y);
    for (int i = 1; i < outline.length; i++) {
      path.lineTo(outline[i].x, outline[i].y);
    }
    path.close();

    final paint = Paint()
      ..color = stroke.isEraser
          ? Colors.white
          : _getBrushColor(stroke.color, stroke.brushType)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  Color _getBrushColor(Color baseColor, BrushType type) {
    switch (type) {
      case BrushType.marker:
        return baseColor.withOpacity(0.5);
      case BrushType.highlighter:
        return baseColor.withOpacity(0.3);
      default:
        return baseColor;
    }
  }

  void _drawShape(Canvas canvas, CanvasShape shape) {
    final paint = Paint()
      ..color = shape.color
      ..style = shape.filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = shape.strokeWidth;

    canvas.save();
    canvas.translate(shape.bounds.center.dx, shape.bounds.center.dy);
    canvas.rotate(shape.rotation);
    canvas.translate(-shape.bounds.center.dx, -shape.bounds.center.dy);

    switch (shape.type) {
      case ShapeType.line:
        canvas.drawLine(
          Offset(shape.bounds.left, shape.bounds.top),
          Offset(shape.bounds.right, shape.bounds.bottom),
          paint,
        );
      case ShapeType.rectangle:
        canvas.drawRect(shape.bounds, paint);
      case ShapeType.circle:
        canvas.drawOval(shape.bounds, paint);
      case ShapeType.triangle:
        final path = Path()
          ..moveTo(shape.bounds.center.dx, shape.bounds.top)
          ..lineTo(shape.bounds.right, shape.bounds.bottom)
          ..lineTo(shape.bounds.left, shape.bounds.bottom)
          ..close();
        canvas.drawPath(path, paint);
      case ShapeType.arrow:
        _drawArrow(canvas, shape.bounds, paint);
    }

    canvas.restore();
  }

  void _drawShapePreview(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = currentColor
      ..style = shapeFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = currentSize;

    switch (shapeType) {
      case ShapeType.line:
        canvas.drawLine(rect.topLeft, rect.bottomRight, paint);
      case ShapeType.rectangle:
        canvas.drawRect(rect, paint);
      case ShapeType.circle:
        canvas.drawOval(rect, paint);
      case ShapeType.triangle:
        final path = Path()
          ..moveTo(rect.center.dx, rect.top)
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.left, rect.bottom)
          ..close();
        canvas.drawPath(path, paint);
      case ShapeType.arrow:
        _drawArrow(canvas, rect, paint);
    }
  }

  void _drawArrow(Canvas canvas, Rect rect, Paint paint) {
    final start = rect.centerLeft;
    final end = rect.centerRight;

    canvas.drawLine(start, end, paint);

    final arrowSize = 15.0;
    final angle = atan2(0, 1);

    final arrowPaint = Paint()
      ..color = paint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = paint.strokeWidth;

    canvas.drawLine(
      end,
      Offset(
        end.dx - arrowSize * cos(angle - pi / 6),
        end.dy - arrowSize * sin(angle - pi / 6),
      ),
      arrowPaint,
    );
    canvas.drawLine(
      end,
      Offset(
        end.dx - arrowSize * cos(angle + pi / 6),
        end.dy - arrowSize * sin(angle + pi / 6),
      ),
      arrowPaint,
    );
  }

  void _drawSticker(Canvas canvas, Sticker sticker) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: sticker.emoji,
        style: TextStyle(fontSize: 48 * sticker.scale),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(sticker.position.dx, sticker.position.dy);
    canvas.rotate(sticker.rotation);
    canvas.translate(
      -textPainter.width / 2,
      -textPainter.height / 2,
    );

    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) {
    return state != oldDelegate.state ||
        currentStroke != oldDelegate.currentStroke ||
        currentShapeRect != oldDelegate.currentShapeRect ||
        shapeType != oldDelegate.shapeType ||
        shapeFilled != oldDelegate.shapeFilled ||
        currentColor != oldDelegate.currentColor ||
        currentSize != oldDelegate.currentSize;
  }
}