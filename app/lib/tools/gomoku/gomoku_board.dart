import 'package:flutter/material.dart';
import 'gomoku_models.dart';

class GomokuBoard extends StatelessWidget {
  final GomokuState state;
  final void Function(int row, int col) onPlaceStone;

  const GomokuBoard({
    super.key,
    required this.state,
    required this.onPlaceStone,
  });

  static const double cellSize = 40.0;
  static const int boardSize = 100;
  static const double boardPixelSize = cellSize * boardSize;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) {
        final localPosition = details.localPosition;
        final col = (localPosition.dx / cellSize).floor();
        final row = (localPosition.dy / cellSize).floor();
        if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
          onPlaceStone(row, col);
        }
      },
      child: SizedBox(
        width: boardPixelSize,
        height: boardPixelSize,
        child: CustomPaint(
          painter: _BoardPainter(state),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final GomokuState state;

  _BoardPainter(this.state);

  @override
  void paint(Canvas canvas, Size size) {
    final gridSize = GomokuBoard.boardSize;
    final cellSize = GomokuBoard.cellSize;

    // 绘制背景
    final bgPaint = Paint()..color = const Color(0xFFDEB887);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      bgPaint,
    );

    // 绘制网格线
    final linePaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;

    for (int i = 0; i < gridSize; i++) {
      // 水平线
      canvas.drawLine(
        Offset(cellSize / 2, cellSize / 2 + i * cellSize),
        Offset(size.width - cellSize / 2, cellSize / 2 + i * cellSize),
        linePaint,
      );
      // 垂直线
      canvas.drawLine(
        Offset(cellSize / 2 + i * cellSize, cellSize / 2),
        Offset(cellSize / 2 + i * cellSize, size.height - cellSize / 2),
        linePaint,
      );
    }

    // 绘制棋子
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final stone = state.board[row][col];
        if (stone != Stone.empty) {
          _drawStone(canvas, row, col, stone);
        }
      }
    }

    // 标记最后一步
    if (state.history.isNotEmpty) {
      final last = state.history.last;
      final centerX = cellSize / 2 + last.col * cellSize;
      final centerY = cellSize / 2 + last.row * cellSize;

      final markPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: 8,
          height: 8,
        ),
        markPaint,
      );
    }
  }

  void _drawStone(Canvas canvas, int row, int col, Stone stone) {
    final cellSize = GomokuBoard.cellSize;
    final centerX = cellSize / 2 + col * cellSize;
    final centerY = cellSize / 2 + row * cellSize;
    final radius = cellSize * 0.4;

    final paint = Paint()
      ..color = stone == Stone.black ? Colors.black : Colors.white
      ..style = PaintingStyle.fill;

    // 阴影
    canvas.drawCircle(
      Offset(centerX + 2, centerY + 2),
      radius,
      Paint()..color = Colors.black26,
    );

    // 棋子
    canvas.drawCircle(Offset(centerX, centerY), radius, paint);

    // 白棋边框
    if (stone == Stone.white) {
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius,
        Paint()
          ..color = Colors.black38
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) {
    return oldDelegate.state != state;
  }
}