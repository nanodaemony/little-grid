import 'package:flutter/material.dart';

/// Fixed pointer widget that sits at the top of the wheel
class WheelPointer extends StatelessWidget {
  final double size;

  const WheelPointer({
    super.key,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.2,
      child: CustomPaint(
        painter: _PointerPainter(),
        size: Size(size, size * 1.2),
      ),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final triangleHeight = size.height * 0.8;
    final circleRadius = size.width * 0.15;

    // Draw the triangle pointing down
    final trianglePath = Path()
      ..moveTo(centerX, size.height) // Bottom point
      ..lineTo(0, 0) // Top left
      ..lineTo(size.width, 0) // Top right
      ..close();

    // Red fill for triangle
    final fillPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawPath(trianglePath, fillPaint);

    // White border for triangle
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawPath(trianglePath, borderPaint);

    // Draw small circle at pivot point (top center)
    final circleCenter = Offset(centerX, 0);

    // White border circle
    final circleBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(circleCenter, circleRadius + 2, circleBorderPaint);

    // Red inner circle
    final circleFillPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawCircle(circleCenter, circleRadius, circleFillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
