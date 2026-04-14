import 'dart:convert';
import 'package:flutter/material.dart';

/// 移动方向
enum Direction { up, down, left, right }

/// 难度等级
enum DifficultyLevel {
  easy(10, 25),
  medium(26, 50),
  hard(51, 100);

  final int minSize;
  final int maxSize;
  const DifficultyLevel(this.minSize, this.maxSize);

  static DifficultyLevel forSize(int size) {
    if (size <= easy.maxSize) return easy;
    if (size <= medium.maxSize) return medium;
    return hard;
  }

  String get displayName {
    switch (this) {
      case easy:
        return '简单';
      case medium:
        return '中等';
      case hard:
        return '困难';
    }
  }
}

/// 迷宫格子
class MazeCell {
  final int row;
  final int col;
  bool topWall;
  bool bottomWall;
  bool leftWall;
  bool rightWall;
  bool isStart;
  bool isEnd;
  bool isVisited;
  bool isOnPath;

  MazeCell({
    required this.row,
    required this.col,
    this.topWall = true,
    this.bottomWall = true,
    this.leftWall = true,
    this.rightWall = true,
    this.isStart = false,
    this.isEnd = false,
    this.isVisited = false,
    this.isOnPath = false,
  });

  /// 检查是否可以向指定方向移动
  bool canMove(Direction direction) {
    switch (direction) {
      case Direction.up:
        return !topWall;
      case Direction.down:
        return !bottomWall;
      case Direction.left:
        return !leftWall;
      case Direction.right:
        return !rightWall;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'row': row,
      'col': col,
      'topWall': topWall,
      'bottomWall': bottomWall,
      'leftWall': leftWall,
      'rightWall': rightWall,
      'isStart': isStart,
      'isEnd': isEnd,
      'isVisited': isVisited,
    };
  }

  factory MazeCell.fromJson(Map<String, dynamic> json) {
    return MazeCell(
      row: json['row'] as int,
      col: json['col'] as int,
      topWall: json['topWall'] as bool,
      bottomWall: json['bottomWall'] as bool,
      leftWall: json['leftWall'] as bool,
      rightWall: json['rightWall'] as bool,
      isStart: json['isStart'] as bool,
      isEnd: json['isEnd'] as bool,
      isVisited: json['isVisited'] as bool,
    );
  }
}

/// 最佳记录
class BestRecord {
  final DifficultyLevel level;
  final Duration bestTime;
  final DateTime date;

  BestRecord({
    required this.level,
    required this.bestTime,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'bestTimeMs': bestTime.inMilliseconds,
      'date': date.toIso8601String(),
    };
  }

  factory BestRecord.fromJson(Map<String, dynamic> json) {
    return BestRecord(
      level: DifficultyLevel.values.firstWhere((l) => l.name == json['level']),
      bestTime: Duration(milliseconds: json['bestTimeMs'] as int),
      date: DateTime.parse(json['date'] as String),
    );
  }

  String get formattedTime {
    final minutes = bestTime.inMinutes;
    final seconds = bestTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// 存档状态
class MazeSaveState {
  final int rows;
  final int cols;
  final int seed;
  final int playerRow;
  final int playerCol;
  final List<List<bool>> visitedCells;
  final Duration elapsed;
  final int moveCount;
  final DateTime savedAt;

  MazeSaveState({
    required this.rows,
    required this.cols,
    required this.seed,
    required this.playerRow,
    required this.playerCol,
    required this.visitedCells,
    required this.elapsed,
    required this.moveCount,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'rows': rows,
      'cols': cols,
      'seed': seed,
      'playerRow': playerRow,
      'playerCol': playerCol,
      'visitedCells': visitedCells.map((row) => row.toList()).toList(),
      'elapsedMs': elapsed.inMilliseconds,
      'moveCount': moveCount,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory MazeSaveState.fromJson(Map<String, dynamic> json) {
    final visitedCellsJson = json['visitedCells'] as List;
    final visitedCells = visitedCellsJson
        .map((row) => (row as List).cast<bool>())
        .toList();

    return MazeSaveState(
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      seed: json['seed'] as int,
      playerRow: json['playerRow'] as int,
      playerCol: json['playerCol'] as int,
      visitedCells: visitedCells,
      elapsed: Duration(milliseconds: json['elapsedMs'] as int),
      moveCount: json['moveCount'] as int,
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }

  /// 计算进度百分比
  double get progressPercent {
    int total = 0;
    int visited = 0;
    for (var row in visitedCells) {
      for (var cell in row) {
        total++;
        if (cell) visited++;
      }
    }
    return total > 0 ? visited / total : 0;
  }
}

/// 游戏状态
class MazeState {
  final int rows;
  final int cols;
  final List<List<MazeCell>> cells;
  final int seed;

  int playerRow;
  int playerCol;
  bool isGameOver;
  int moveCount;
  Duration elapsed;
  DateTime? startTime;

  bool showHint;
  bool showPath;
  List<Offset>? pathPoints;

  MazeState({
    required this.rows,
    required this.cols,
    required this.cells,
    required this.seed,
    required this.playerRow,
    required this.playerCol,
    this.isGameOver = false,
    this.moveCount = 0,
    this.elapsed = Duration.zero,
    this.startTime,
    this.showHint = false,
    this.showPath = false,
    this.pathPoints,
  });

  /// 获取当前玩家位置的格子
  MazeCell get currentCell => cells[playerRow][playerCol];

  /// 检查是否到达终点
  bool get hasReachedEnd => cells[playerRow][playerCol].isEnd;

  /// 获取可行的方向列表
  List<Direction> get availableDirections {
    final result = <Direction>[];
    final cell = currentCell;
    if (cell.canMove(Direction.up)) result.add(Direction.up);
    if (cell.canMove(Direction.down)) result.add(Direction.down);
    if (cell.canMove(Direction.left)) result.add(Direction.left);
    if (cell.canMove(Direction.right)) result.add(Direction.right);
    return result;
  }
}

/// 迷宫主题
enum MazeTheme {
  defaultTheme,
  classic,
  dark,
  fresh,
}

/// 主题配色数据
class MazeThemeData {
  final Color wallColor;
  final Color pathColor;
  final Color visitedColor;
  final Color playerColor;
  final Color startColor;
  final Color endColor;
  final Color hintColor;
  final Color pathHighlightColor;
  final Color backgroundColor;

  MazeThemeData({
    required this.wallColor,
    required this.pathColor,
    required this.visitedColor,
    required this.playerColor,
    required this.startColor,
    required this.endColor,
    required this.hintColor,
    required this.pathHighlightColor,
    required this.backgroundColor,
  });

  static MazeThemeData of(MazeTheme theme) {
    switch (theme) {
      case MazeTheme.defaultTheme:
        return MazeThemeData(
          wallColor: Colors.grey.shade800,
          pathColor: Colors.white,
          visitedColor: Colors.blue.withValues(alpha: 0.1),
          playerColor: Colors.blue.shade600,
          startColor: Colors.green.shade500,
          endColor: Colors.red.shade500,
          hintColor: Colors.amber.shade500,
          pathHighlightColor: Colors.green.withValues(alpha: 0.3),
          backgroundColor: Colors.grey.shade100,
        );
      case MazeTheme.classic:
        return MazeThemeData(
          wallColor: Colors.black,
          pathColor: Colors.white,
          visitedColor: Colors.grey.shade200,
          playerColor: Colors.black,
          startColor: Colors.green,
          endColor: Colors.red,
          hintColor: Colors.blue,
          pathHighlightColor: Colors.green.withValues(alpha: 0.4),
          backgroundColor: Colors.white,
        );
      case MazeTheme.dark:
        return MazeThemeData(
          wallColor: Colors.grey.shade600,
          pathColor: Colors.grey.shade900,
          visitedColor: Colors.blue.shade900.withValues(alpha: 0.3),
          playerColor: Colors.blue.shade400,
          startColor: Colors.green.shade400,
          endColor: Colors.red.shade400,
          hintColor: Colors.amber.shade400,
          pathHighlightColor: Colors.green.shade700.withValues(alpha: 0.5),
          backgroundColor: Colors.grey.shade950,
        );
      case MazeTheme.fresh:
        return MazeThemeData(
          wallColor: Colors.green.shade300,
          pathColor: Colors.pink.shade50,
          visitedColor: Colors.green.withValues(alpha: 0.1),
          playerColor: Colors.pink.shade400,
          startColor: Colors.green.shade400,
          endColor: Colors.pink.shade500,
          hintColor: Colors.orange.shade400,
          pathHighlightColor: Colors.green.shade200,
          backgroundColor: Colors.pink.shade50,
        );
    }
  }

  String get displayName {
    switch (this as MazeTheme) {
      case MazeTheme.defaultTheme:
        return '默认';
      case MazeTheme.classic:
        return '经典';
      case MazeTheme.dark:
        return '深色';
      case MazeTheme.fresh:
        return '清新';
    }
  }
}
