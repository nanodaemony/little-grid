import 'package:flutter/material.dart';
import 'snake_models.dart';

class SnakeBoard extends StatelessWidget {
  final SnakeState state;

  const SnakeBoard({super.key, required this.state});

  static const double cellSize = 20.0;

  double get boardPixelSize => cellSize * state.gridSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CustomPaint(
          size: Size(boardPixelSize, boardPixelSize),
          painter: _SnakePainter(state, Theme.of(context)),
        ),
      ),
    );
  }
}

class _SnakePainter extends CustomPainter {
  final SnakeState state;
  final ThemeData theme;

  _SnakePainter(this.state, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = SnakeBoard.cellSize;

    // 绘制背景
    final bgPaint = Paint()..color = theme.colorScheme.surfaceContainerLowest;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 绘制网格
    final gridPaint = Paint()
      ..color = theme.colorScheme.outlineVariant.withOpacity(0.3)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= state.gridSize; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        gridPaint,
      );
    }

    // 绘制障碍物
    for (final obstacle in state.obstacles) {
      _drawObstacle(canvas, obstacle);
    }

    // 绘制食物
    _drawFood(canvas, state.food);

    // 绘制道具
    if (state.powerUp != null) {
      _drawPowerUp(canvas, state.powerUp!);
    }

    // 绘制蛇
    _drawSnake(canvas);

    // 如果有磁铁效果，绘制范围指示
    if (state.activePowerUp?.type == PowerUpType.magnet) {
      _drawMagnetRange(canvas);
    }
  }

  void _drawSnake(Canvas canvas) {
    final cellSize = SnakeBoard.cellSize;
    final colorScheme = theme.colorScheme;

    for (int i = 0; i < state.snake.length; i++) {
      final segment = state.snake[i];
      final rect = Rect.fromLTWH(
        segment.dx * cellSize + 1,
        segment.dy * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );

      // 蛇头用不同颜色
      final isHead = i == 0;
      final paint = Paint()
        ..color = isHead
            ? colorScheme.primary
            : colorScheme.primaryContainer
        ..style = PaintingStyle.fill;

      // 绘制圆角矩形
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
      canvas.drawRRect(rrect, paint);

      // 蛇头眼睛
      if (isHead) {
        _drawEyes(canvas, segment);
      }
    }
  }

  void _drawEyes(Canvas canvas, Offset head) {
    final cellSize = SnakeBoard.cellSize;
    final eyeSize = 3.0;
    final eyePaint = Paint()..color = Colors.white;

    double eyeOffsetX = 0;
    double eyeOffsetY = 0;

    switch (state.direction) {
      case Direction.up:
        eyeOffsetY = -3;
        break;
      case Direction.down:
        eyeOffsetY = 3;
        break;
      case Direction.left:
        eyeOffsetX = -3;
        break;
      case Direction.right:
        eyeOffsetX = 3;
        break;
    }

    final centerX = head.dx * cellSize + cellSize / 2;
    final centerY = head.dy * cellSize + cellSize / 2;

    // 左眼
    canvas.drawCircle(
      Offset(centerX - 4 + eyeOffsetX, centerY - 2 + eyeOffsetY),
      eyeSize,
      eyePaint,
    );
    // 右眼
    canvas.drawCircle(
      Offset(centerX + 4 + eyeOffsetX, centerY - 2 + eyeOffsetY),
      eyeSize,
      eyePaint,
    );
  }

  void _drawFood(Canvas canvas, Offset food) {
    final cellSize = SnakeBoard.cellSize;
    final centerX = food.dx * cellSize + cellSize / 2;
    final centerY = food.dy * cellSize + cellSize / 2;
    final radius = cellSize * 0.35;

    final paint = Paint()
      ..color = Colors.redAccent
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // 高光
    canvas.drawCircle(
      Offset(centerX - radius * 0.3, centerY - radius * 0.3),
      radius * 0.2,
      Paint()..color = Colors.white.withOpacity(0.5),
    );
  }

  void _drawObstacle(Canvas canvas, Offset obstacle) {
    final cellSize = SnakeBoard.cellSize;
    final rect = Rect.fromLTWH(
      obstacle.dx * cellSize + 1,
      obstacle.dy * cellSize + 1,
      cellSize - 2,
      cellSize - 2,
    );

    final paint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  void _drawPowerUp(Canvas canvas, PowerUp powerUp) {
    final cellSize = SnakeBoard.cellSize;
    final centerX = powerUp.position.dx * cellSize + cellSize / 2;
    final centerY = powerUp.position.dy * cellSize + cellSize / 2;
    final radius = cellSize * 0.4;

    Color color;
    switch (powerUp.type) {
      case PowerUpType.speed:
        color = Colors.amber;
        break;
      case PowerUpType.shorten:
        color = Colors.purple;
        break;
      case PowerUpType.magnet:
        color = Colors.blue;
        break;
    }

    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // 绘制图标（简化为符号）
    final textPainter = TextPainter(
      text: TextSpan(
        text: powerUp.type == PowerUpType.speed
            ? '⚡'
            : powerUp.type == PowerUpType.shorten
                ? '—'
                : '◎',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(centerX - textPainter.width / 2, centerY - textPainter.height / 2),
    );
  }

  void _drawMagnetRange(Canvas canvas) {
    final cellSize = SnakeBoard.cellSize;
    final head = state.snake.first;
    final centerX = head.dx * cellSize + cellSize / 2;
    final centerY = head.dy * cellSize + cellSize / 2;

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(centerX, centerY),
      cellSize * 2.5,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _SnakePainter oldDelegate) {
    return oldDelegate.state != state;
  }
}