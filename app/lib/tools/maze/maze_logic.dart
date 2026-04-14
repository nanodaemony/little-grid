import 'dart:async';
import 'package:flutter/material.dart';
import 'maze_models.dart';
import 'maze_generator.dart';

/// 持续移动控制器
class ContinuousMovementController {
  Timer? _moveTimer;
  Direction? _currentDirection;
  VoidCallback? onMove;

  static const _moveInterval = Duration(milliseconds: 180);

  void start(Direction direction, VoidCallback moveCallback) {
    _currentDirection = direction;
    onMove = moveCallback;
    _moveTimer?.cancel();
    _moveTimer = Timer.periodic(_moveInterval, (_) {
      onMove?.call();
    });
    // 立即执行一次
    onMove?.call();
  }

  void updateDirection(Direction direction) {
    if (_currentDirection != direction) {
      _currentDirection = direction;
    }
  }

  void stop() {
    _moveTimer?.cancel();
    _moveTimer = null;
    _currentDirection = null;
    onMove = null;
  }

  Direction? get currentDirection => _currentDirection;
  bool get isMoving => _moveTimer != null;
}

/// 迷宫游戏逻辑
class MazeLogic {
  late MazeState state;
  final ContinuousMovementController movementController =
      ContinuousMovementController();
  Timer? _gameTimer;

  /// 初始化新游戏
  void initialize(int size, {int? seed}) {
    final actualSeed = seed ?? DateTime.now().millisecondsSinceEpoch;
    final cells = MazeGenerator.generate(size, size, seed: actualSeed);

    // 找到起点和终点
    int startRow = 1, startCol = 1;
    int endRow = cells.length - 2, endCol = cells[0].length - 2;

    for (var row = 0; row < cells.length; row++) {
      for (var col = 0; col < cells[0].length; col++) {
        if (cells[row][col].isStart) {
          startRow = row;
          startCol = col;
        }
        if (cells[row][col].isEnd) {
          endRow = row;
          endCol = col;
        }
      }
    }

    // 标记起点为已访问
    cells[startRow][startCol].isVisited = true;

    state = MazeState(
      rows: cells.length,
      cols: cells[0].length,
      cells: cells,
      seed: actualSeed,
      playerRow: startRow,
      playerCol: startCol,
    );
  }

  /// 从存档恢复游戏
  void restore(MazeSaveState saveState) {
    final cells = MazeGenerator.generate(saveState.rows, saveState.cols,
        seed: saveState.seed);

    // 恢复访问状态
    for (var row = 0; row < saveState.visitedCells.length; row++) {
      for (var col = 0; col < saveState.visitedCells[row].length; col++) {
        if (row < cells.length && col < cells[0].length) {
          cells[row][col].isVisited = saveState.visitedCells[row][col];
        }
      }
    }

    state = MazeState(
      rows: cells.length,
      cols: cells[0].length,
      cells: cells,
      seed: saveState.seed,
      playerRow: saveState.playerRow,
      playerCol: saveState.playerCol,
      moveCount: saveState.moveCount,
      elapsed: saveState.elapsed,
    );
  }

  /// 开始游戏计时
  void startTimer(VoidCallback onTick) {
    _gameTimer?.cancel();
    state.startTime ??= DateTime.now();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.startTime != null) {
        state.elapsed = DateTime.now().difference(state.startTime!);
      }
      onTick();
    });
  }

  /// 暂停游戏计时
  void pauseTimer() {
    _gameTimer?.cancel();
  }

  /// 尝试向指定方向移动
  bool tryMove(Direction direction) {
    if (state.isGameOver) return false;

    final cell = state.cells[state.playerRow][state.playerCol];
    if (!cell.canMove(direction)) return false;

    // 计算新位置
    int newRow = state.playerRow;
    int newCol = state.playerCol;

    switch (direction) {
      case Direction.up:
        newRow--;
        break;
      case Direction.down:
        newRow++;
        break;
      case Direction.left:
        newCol--;
        break;
      case Direction.right:
        newCol++;
        break;
    }

    // 更新位置
    state.playerRow = newRow;
    state.playerCol = newCol;
    state.moveCount++;

    // 标记为已访问
    state.cells[newRow][newCol].isVisited = true;

    // 清除路径高亮（移动后消失）
    if (state.showPath) {
      state.showPath = false;
      state.pathPoints = null;
      for (var row in state.cells) {
        for (var cell in row) {
          cell.isOnPath = false;
        }
      }
    }

    // 检查是否到达终点
    if (state.hasReachedEnd) {
      state.isGameOver = true;
      pauseTimer();
      movementController.stop();
    }

    return true;
  }

  /// 切换提示显示
  void toggleHint() {
    state.showHint = !state.showHint;
  }

  /// 计算并显示最短路径
  void showShortestPath() {
    // 找到起点和终点
    int? startRow, startCol, endRow, endCol;
    for (var row = 0; row < state.cells.length; row++) {
      for (var col = 0; col < state.cells[0].length; col++) {
        if (state.cells[row][col].isStart) {
          startRow = row;
          startCol = col;
        }
        if (state.cells[row][col].isEnd) {
          endRow = row;
          endCol = col;
        }
      }
    }

    if (startRow == null || endRow == null || endCol == null) return;

    // 从当前位置寻路
    final path = PathFinder.findPath(
      state.cells,
      state.playerRow,
      state.playerCol,
      endRow,
      endCol,
    );

    if (path != null) {
      state.pathPoints = path;
      state.showPath = true;

      // 标记路径上的格子
      for (var point in path) {
        final row = point.dy.toInt();
        final col = point.dx.toInt();
        if (row < state.cells.length && col < state.cells[0].length) {
          state.cells[row][col].isOnPath = true;
        }
      }
    }
  }

  /// 隐藏路径
  void hidePath() {
    state.showPath = false;
    state.pathPoints = null;
    for (var row in state.cells) {
      for (var cell in row) {
        cell.isOnPath = false;
      }
    }
  }

  /// 清理资源
  void dispose() {
    movementController.stop();
    _gameTimer?.cancel();
  }

  /// 获取存档状态
  MazeSaveState getSaveState() {
    final visitedCells = state.cells
        .map((row) => row.map((cell) => cell.isVisited).toList())
        .toList();

    return MazeSaveState(
      rows: state.rows,
      cols: state.cols,
      seed: state.seed,
      playerRow: state.playerRow,
      playerCol: state.playerCol,
      visitedCells: visitedCells,
      elapsed: state.elapsed,
      moveCount: state.moveCount,
      savedAt: DateTime.now(),
    );
  }
}
