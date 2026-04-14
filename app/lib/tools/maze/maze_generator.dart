import 'dart:math';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'maze_models.dart';

/// Prim 迷宫生成器
class MazeGenerator {
  /// 生成迷宫
  static List<List<MazeCell>> generate(int rows, int cols, {int? seed}) {
    final random = Random(seed ?? DateTime.now().millisecondsSinceEpoch);

    // 确保是奇数行列（墙-格子-墙模式）
    final effectiveRows = rows.isOdd ? rows : rows + 1;
    final effectiveCols = cols.isOdd ? cols : cols + 1;

    // 初始化所有格子都有墙
    final cells = List.generate(effectiveRows, (row) =>
      List.generate(effectiveCols, (col) => MazeCell(row: row, col: col)));

    // 设置起点和终点（确保在通道上）
    final startRow = 1;
    final startCol = 1;
    final endRow = effectiveRows - 2;
    final endCol = effectiveCols - 2;

    cells[startRow][startCol].isStart = true;
    cells[endRow][endCol].isEnd = true;

    // Prim 算法
    final visited = <MazeCell>{};
    final walls = <_Wall>[];

    // 从起点开始
    final startCell = cells[startRow][startCol];
    visited.add(startCell);

    // 添加起点的墙到列表
    _addWalls(startCell, walls, cells, effectiveRows, effectiveCols);

    while (walls.isNotEmpty) {
      // 随机选择一面墙
      final wallIndex = random.nextInt(walls.length);
      final wall = walls.removeAt(wallIndex);

      final cell1 = wall.cell;
      final cell2 = wall.adjacentCell;

      if (!visited.contains(cell2)) {
        // 拆除墙
        _removeWall(cell1, cell2, wall.direction);

        visited.add(cell2);
        _addWalls(cell2, walls, cells, effectiveRows, effectiveCols);
      }
    }

    return cells;
  }

  /// 添加格子的四堵墙到候选列表
  static void _addWalls(MazeCell cell, List<_Wall> walls,
      List<List<MazeCell>> cells, int rows, int cols) {
    final directions = [
      (Direction.up, -1, 0),
      (Direction.down, 1, 0),
      (Direction.left, 0, -1),
      (Direction.right, 0, 1),
    ];

    for (final dir in directions) {
      final newRow = cell.row + dir.$2;
      final newCol = cell.col + dir.$3;

      if (newRow >= 0 && newRow < rows &&
          newCol >= 0 && newCol < cols) {
        walls.add(_Wall(cell, cells[newRow][newCol], dir.$1));
      }
    }
  }

  /// 拆除两格之间的墙
  static void _removeWall(MazeCell cell1, MazeCell cell2, Direction direction) {
    switch (direction) {
      case Direction.up:
        cell1.topWall = false;
        cell2.bottomWall = false;
        break;
      case Direction.down:
        cell1.bottomWall = false;
        cell2.topWall = false;
        break;
      case Direction.left:
        cell1.leftWall = false;
        cell2.rightWall = false;
        break;
      case Direction.right:
        cell1.rightWall = false;
        cell2.leftWall = false;
        break;
    }
  }
}

/// 墙数据（内部使用）
class _Wall {
  final MazeCell cell;
  final MazeCell adjacentCell;
  final Direction direction;
  _Wall(this.cell, this.adjacentCell, this.direction);
}

/// BFS 最短路径寻路器
class PathFinder {
  /// 查找从起点到终点的最短路径
  static List<Offset>? findPath(List<List<MazeCell>> cells,
      int startRow, int startCol, int endRow, int endCol) {
    final rows = cells.length;
    final cols = cells[0].length;

    final visited = List.generate(rows, (_) => List.filled(cols, false));
    final parent = List.generate(rows, (_) =>
      List.generate(cols, (_) => const Offset(-1, -1)));

    final queue = Queue<Offset>();
    queue.add(Offset(startCol.toDouble(), startRow.toDouble()));
    visited[startRow][startCol] = true;

    final directions = [
      (Direction.up, -1, 0),
      (Direction.down, 1, 0),
      (Direction.left, 0, -1),
      (Direction.right, 0, 1),
    ];

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      final col = current.dx.toInt();
      final row = current.dy.toInt();

      if (row == endRow && col == endCol) {
        // 重建路径
        final path = <Offset>[];
        var r = endRow, c = endCol;
        while (r != -1 && c != -1) {
          path.add(Offset(c.toDouble(), r.toDouble()));
          final p = parent[r][c];
          r = p.dy.toInt();
          c = p.dx.toInt();
        }
        return path.reversed.toList();
      }

      final cell = cells[row][col];
      for (final dir in directions) {
        final newRow = row + dir.$2;
        final newCol = col + dir.$3;

        // 检查是否可以移动到该方向
        if (!_canMove(cell, dir.$1)) continue;
        if (newRow < 0 || newRow >= rows) continue;
        if (newCol < 0 || newCol >= cols) continue;
        if (visited[newRow][newCol]) continue;

        visited[newRow][newCol] = true;
        parent[newRow][newCol] = Offset(col.toDouble(), row.toDouble());
        queue.add(Offset(newCol.toDouble(), newRow.toDouble()));
      }
    }

    return null;
  }

  /// 检查是否可以向指定方向移动
  static bool _canMove(MazeCell cell, Direction direction) {
    switch (direction) {
      case Direction.up:
        return !cell.topWall;
      case Direction.down:
        return !cell.bottomWall;
      case Direction.left:
        return !cell.leftWall;
      case Direction.right:
        return !cell.rightWall;
    }
  }
}
