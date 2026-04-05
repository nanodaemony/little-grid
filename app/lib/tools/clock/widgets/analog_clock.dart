import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/clock_config.dart';
import '../models/clock_enums.dart';

class AnalogClock extends StatelessWidget {
  final DateTime time;
  final ClockConfig config;

  const AnalogClock({
    super.key,
    required this.time,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.shortestSide * 0.7;
    final textColor = config.effectiveTextColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _ClockPainter(
              time: time,
              config: config,
            ),
          ),
        ),
        if (config.showDate) ...[
          const SizedBox(height: 24),
          Text(
            '${time.year}/${_twoDigits(time.month)}/${_twoDigits(time.day)}',
            style: TextStyle(
              fontSize: 24 * config.fontSize.scale,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      ],
    );
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

class _ClockPainter extends CustomPainter {
  final DateTime time;
  final ClockConfig config;

  _ClockPainter({
    required this.time,
    required this.config,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final textColor = config.effectiveTextColor;

    // Draw dial background
    final bgPaint = Paint()
      ..color = textColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw dial border
    final borderPaint = Paint()
      ..color = textColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // Draw ticks
    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * math.pi / 180;
      final isMainTick = i % 3 == 0;
      final tickStart = radius * (isMainTick ? 0.85 : 0.9);
      final tickEnd = radius * 0.95;

      final start = Offset(
        center.dx + tickStart * math.sin(angle),
        center.dy - tickStart * math.cos(angle),
      );
      final end = Offset(
        center.dx + tickEnd * math.sin(angle),
        center.dy - tickEnd * math.cos(angle),
      );

      final tickPaint = Paint()
        ..color = textColor.withOpacity(isMainTick ? 0.8 : 0.4)
        ..strokeWidth = isMainTick ? 3 : 1;
      canvas.drawLine(start, end, tickPaint);
    }

    // Draw hour hand
    final hourAngle = (time.hour % 12 + time.minute / 60) * 30 * math.pi / 180;
    _drawHand(canvas, center, radius * 0.5, hourAngle, textColor, 6);

    // Draw minute hand
    final minuteAngle = (time.minute + time.second / 60) * 6 * math.pi / 180;
    _drawHand(canvas, center, radius * 0.75, minuteAngle, textColor, 4);

    // Draw second hand
    if (config.showSeconds) {
      final secondAngle = time.second * 6 * math.pi / 180;
      _drawHand(canvas, center, radius * 0.85, secondAngle, Colors.red, 2);
    }

    // Draw center dot
    final centerPaint = Paint()
      ..color = textColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, centerPaint);
  }

  void _drawHand(Canvas canvas, Offset center, double length, double angle, Color color, double width) {
    final end = Offset(
      center.dx + length * math.sin(angle),
      center.dy - length * math.cos(angle),
    );

    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
