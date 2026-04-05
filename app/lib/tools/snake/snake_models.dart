import 'dart:ui';

/// 移动方向
enum Direction { up, down, left, right }

/// 游戏模式
enum GameMode { classic, enhanced }

/// 道具类型
enum PowerUpType { speed, shorten, magnet }

/// 道具
class PowerUp {
  final Offset position;
  final PowerUpType type;

  const PowerUp({required this.position, required this.type});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PowerUp && position == other.position && type == other.type;

  @override
  int get hashCode => Object.hash(position, type);
}

/// 游戏状态
class SnakeState {
  final List<Offset> snake;        // 蛇身各节位置（头部在前）
  final Direction direction;        // 当前移动方向
  final Offset food;                // 食物位置
  final List<Offset> obstacles;     // 障碍物（增强模式）
  final PowerUp? powerUp;           // 当前场上的道具
  final PowerUp? activePowerUp;     // 激活的道具效果
  final int activePowerUpEndTime;   // 道具效果结束时间（毫秒）
  final int score;                  // 当前分数
  final int highScore;              // 最高分
  final GameMode mode;              // 游戏模式
  final bool isPlaying;             // 是否游戏中
  final bool isPaused;              // 是否暂停
  final bool isGameOver;            // 是否游戏结束
  final int gridSize;               // 网格大小

  const SnakeState({
    required this.snake,
    required this.direction,
    required this.food,
    required this.obstacles,
    this.powerUp,
    this.activePowerUp,
    this.activePowerUpEndTime = 0,
    required this.score,
    required this.highScore,
    required this.mode,
    required this.isPlaying,
    required this.isPaused,
    required this.isGameOver,
    required this.gridSize,
  });

  /// 创建初始状态
  factory SnakeState.initial({
    GameMode mode = GameMode.classic,
    int highScore = 0,
    int gridSize = 20,
  }) {
    // 蛇初始位置在中间
    final centerX = gridSize ~/ 2;
    final centerY = gridSize ~/ 2;
    final snake = [
      Offset(centerX.toDouble(), centerY.toDouble()),
      Offset(centerX.toDouble() - 1, centerY.toDouble()),
      Offset(centerX.toDouble() - 2, centerY.toDouble()),
    ];

    return SnakeState(
      snake: snake,
      direction: Direction.right,
      food: _randomPosition(gridSize, snake, []),
      obstacles: [],
      score: 0,
      highScore: highScore,
      mode: mode,
      isPlaying: false,
      isPaused: false,
      isGameOver: false,
      gridSize: gridSize,
    );
  }

  /// 生成随机位置（避开已有的）
  static Offset _randomPosition(int gridSize, List<Offset> avoid, List<Offset> obstacles) {
    final random = DateTime.now().microsecondsSinceEpoch;
    for (int i = 0; i < 100; i++) {
      final x = ((random + i * 17) % gridSize).toDouble();
      final y = ((random + i * 31) % gridSize).toDouble();
      final pos = Offset(x, y);
      if (!avoid.contains(pos) && !obstacles.contains(pos)) {
        return pos;
      }
    }
    return Offset(0, 0);
  }

  /// 计算当前移动间隔（毫秒）
  int get moveInterval {
    // 初始 200ms，每10分减少10ms，最短 80ms
    final interval = 200 - (score ~/ 10) * 10;
    return interval.clamp(80, 200);
  }

  /// 复制并修改状态
  SnakeState copyWith({
    List<Offset>? snake,
    Direction? direction,
    Offset? food,
    List<Offset>? obstacles,
    Object? powerUp = _unset,
    Object? activePowerUp = _unset,
    int? activePowerUpEndTime,
    int? score,
    int? highScore,
    GameMode? mode,
    bool? isPlaying,
    bool? isPaused,
    bool? isGameOver,
    int? gridSize,
  }) {
    return SnakeState(
      snake: snake ?? this.snake,
      direction: direction ?? this.direction,
      food: food ?? this.food,
      obstacles: obstacles ?? this.obstacles,
      powerUp: powerUp == _unset ? this.powerUp : powerUp as PowerUp?,
      activePowerUp: activePowerUp == _unset ? this.activePowerUp : activePowerUp as PowerUp?,
      activePowerUpEndTime: activePowerUpEndTime ?? this.activePowerUpEndTime,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      mode: mode ?? this.mode,
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isGameOver: isGameOver ?? this.isGameOver,
      gridSize: gridSize ?? this.gridSize,
    );
  }
}

// Sentinel value for distinguishing "not provided" from "explicitly null"
const _unset = Object();