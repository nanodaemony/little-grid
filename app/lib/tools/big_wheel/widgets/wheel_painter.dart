import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/wheel_option.dart';
import '../utils/color_utils.dart';

/// CustomPainter for drawing the spinning wheel
class WheelPainter extends CustomPainter {
  final List<WheelOption> options;
  final double rotationAngle;
  final double borderWidth;

  WheelPainter({
    required this.options,
    required this.rotationAngle,
    this.borderWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Calculate total weight for sector distribution
    final totalWeight = options.fold<double>(
      0,
      (sum, option) => sum + option.weight,
    );

    // Draw each sector
    double currentAngle = rotationAngle;

    for (final option in options) {
      final sweepAngle = (option.weight / totalWeight) * 2 * math.pi;

      // Parse color from option or use a default
      final color = parseColor(option.color);

      // Draw sector
      _drawSector(
        canvas,
        center,
        radius,
        currentAngle,
        sweepAngle,
        color,
      );

      // Draw text label in sector
      _drawText(
        canvas,
        center,
        radius,
        currentAngle,
        sweepAngle,
        option.name,
      );

      currentAngle += sweepAngle;
    }

    // Draw center circle
    _drawCenterCircle(canvas, center, radius);
  }

  void _drawSector(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    Color color,
  ) {
    // Draw the sector
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
      )
      ..lineTo(center.dx, center.dy)
      ..close();

    canvas.drawPath(path, paint);

    // Draw white border between sectors
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Draw radial border lines at the start and end of sector
    final startX = center.dx + radius * math.cos(startAngle);
    final startY = center.dy + radius * math.sin(startAngle);
    canvas.drawLine(center, Offset(startX, startY), borderPaint);
  }

  void _drawText(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    String text,
  ) {
    // Calculate text position (middle of sector, at 60% of radius)
    final textAngle = startAngle + sweepAngle / 2;
    final textRadius = radius * 0.6;
    final textOffset = Offset(
      center.dx + textRadius * math.cos(textAngle),
      center.dy + textRadius * math.sin(textAngle),
    );

    // Create text painter
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black26,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout(maxWidth: radius * 0.8);

    // Calculate rotation for text to be readable
    // Rotate text to align with sector, but keep it upright
    double rotation = textAngle + math.pi / 2;
    if (rotation > math.pi / 2 && rotation < 3 * math.pi / 2) {
      rotation += math.pi;
    }

    canvas.save();
    canvas.translate(textOffset.dx, textOffset.dy);
    canvas.rotate(rotation - math.pi / 2);
    canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  void _drawCenterCircle(Canvas canvas, Offset center, double radius) {
    // Draw outer border of center circle
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.12, borderPaint);

    // Draw inner center circle
    final centerPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.10, centerPaint);
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.options != options;
  }
}
