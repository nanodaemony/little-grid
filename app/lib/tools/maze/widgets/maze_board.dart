import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import '../maze_models.dart';
import '../maze_logic.dart';

/// 迷宫画布
class MazeBoard extends StatefulWidget {
  final MazeState state;
  final MazeThemeData theme;
  final TransformationController transformationController;

  const MazeBoard({
    super.key,
    required this.state,
    required this.theme,
    required this.transformationController,
  });

  @override
  State<MazeBoard> createState() => _MazeBoardState();
}

class _MazeBoardState extends State<MazeBoard> {
  static const double cellSize = 32.0;
  static const double wallThickness = 2.0;

  @override
  Widget build(BuildContext context) {
    final boardWidth = widget.state.cols * cellSize;
    final boardHeight = widget.state.rows * cellSize;

    return SizedBox(
      width: boardWidth,
      height: boardHeight,
      child: CustomPaint(
        painter: _MazePainter(
          state: widget.state,
          theme: widget.theme,
          cellSize: cellSize,
          wallThickness: wallThickness,
        ),
      ),
    );
  }
}

/// 迷宫绘制器
class _MazePainter extends CustomPainter {
  final MazeState state;
  final MazeThemeData theme;
  final double cellSize;
  final double wallThickness;

  _MazePainter({
    required this.state,
    required this.theme,
    required this.cellSize,
    required this.wallThickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景
    final bgPaint = Paint()..color = theme.pathColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 绘制路径高亮
    if (state.showPath) {
      final pathPaint = Paint()..color = theme.pathHighlightColor;
      for (var row = 0; row < state.cells.length; row++) {
        for (var col = 0; col < state.cells[row].length; col++) {
          final cell = state.cells[row][col];
          if (cell.isOnPath) {
            final rect = Rect.fromLTWH(
              col * cellSize,
              row * cellSize,
              cellSize,
              cellSize,
            );
            canvas.drawRect(rect, pathPaint);
          }
        }
      }
    }

    // 绘制已访问的路径
    final visitedPaint = Paint()..color = theme.visitedColor;
    for (var row = 0; row < state.cells.length; row++) {
      for (var col = 0; col < state.cells[row].length; col++) {
        final cell = state.cells[row][col];
        if (cell.isVisited && !cell.isOnPath) {
          final rect = Rect.fromLTWH(
            col * cellSize,
            row * cellSize,
            cellSize,
            cellSize,
          );
          canvas.drawRect(rect, visitedPaint);
        }
      }
    }

    // 绘制起点和终点
    _drawStartEnd(canvas);

    // 绘制墙
    _drawWalls(canvas);

    // 绘制提示（可行方向）
    if (state.showHint) {
      _drawHint(canvas);
    }

    // 绘制玩家
    _drawPlayer(canvas);
  }

  /// 绘制起点和终点
  void _drawStartEnd(Canvas canvas) {
    for (var row = 0; row < state.cells.length; row++) {
      for (var col = 0; col < state.cells[row].length; col++) {
        final cell = state.cells[row][col];
        if (cell.isStart || cell.isEnd) {
          final center = Offset(
            col * cellSize + cellSize / 2,
            row * cellSize + cellSize / 2,
          );
          final radius = cellSize * 0.3;
          final paint = Paint()
            ..color = cell.isStart ? theme.startColor : theme.endColor
            ..style = PaintingStyle.fill;
          canvas.drawCircle(center, radius, paint);
        }
      }
    }
  }

  /// 绘制墙
  void _drawWalls(Canvas canvas) {
    final wallPaint = Paint()
      ..color = theme.wallColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = wallThickness;

    for (var row = 0; row < state.cells.length; row++) {
      for (var col = 0; col < state.cells[row].length; col++) {
        final cell = state.cells[row][col];
        final left = col * cellSize;
        final top = row * cellSize;
        final right = left + cellSize;
        final bottom = top + cellSize;

        if (cell.topWall) {
          canvas.drawLine(Offset(left, top), Offset(right, top), wallPaint);
        }
        if (cell.bottomWall) {
          canvas.drawLine(Offset(left, bottom), Offset(right, bottom), wallPaint);
        }
        if (cell.leftWall) {
          canvas.drawLine(Offset(left, top), Offset(left, bottom), wallPaint);
        }
        if (cell.rightWall) {
          canvas.drawLine(Offset(right, top), Offset(right, bottom), wallPaint);
        }
      }
    }
  }

  /// 绘制提示
  void _drawHint(Canvas canvas) {
    final hintPaint = Paint()
      ..color = theme.hintColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final directions = state.availableDirections;
    final playerCenter = Offset(
      state.playerCol * cellSize + cellSize / 2,
      state.playerRow * cellSize + cellSize / 2,
    );
    final arrowSize = cellSize * 0.2;

    for (final dir in directions) {
      Offset arrowOffset;
      switch (dir) {
        case Direction.up:
          arrowOffset = Offset(0, -cellSize * 0.35);
          break;
        case Direction.down:
          arrowOffset = Offset(0, cellSize * 0.35);
          break;
        case Direction.left:
          arrowOffset = Offset(-cellSize * 0.35, 0);
          break;
        case Direction.right:
          arrowOffset = Offset(cellSize * 0.35, 0);
          break;
      }

      final arrowCenter = playerCenter + arrowOffset;
      canvas.drawCircle(arrowCenter, arrowSize, hintPaint);
    }
  }

  /// 绘制玩家
  void _drawPlayer(Canvas canvas) {
    final center = Offset(
      state.playerCol * cellSize + cellSize / 2,
      state.playerRow * cellSize + cellSize / 2,
    );
    final radius = cellSize * 0.35;

    final paint = Paint()
      ..color = theme.playerColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_MazePainter oldDelegate) {
    return oldDelegate.state != state || oldDelegate.theme != theme;
  }
}
