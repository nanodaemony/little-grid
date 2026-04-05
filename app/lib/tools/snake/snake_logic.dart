import 'dart:math';
import 'dart:ui';

import 'snake_models.dart';

class SnakeLogic {
  SnakeState _state;

  SnakeLogic({
    GameMode mode = GameMode.classic,
    int highScore = 0,
  }) : _state = SnakeState.initial(mode: mode, highScore: highScore);

  SnakeState get state => _state;

  final Random _random = Random();

  /// 开始游戏
  void start() {
    _state = _state.copyWith(isPlaying: true, isGameOver: false);
    // 增强模式初始化障碍物
    if (_state.mode == GameMode.enhanced) {
      _generateObstacles();
    }
  }

  /// 暂停/继续
  void togglePause() {
    if (!_state.isPlaying || _state.isGameOver) return;
    _state = _state.copyWith(isPaused: !_state.isPaused);
  }

  /// 移动蛇（游戏循环调用）
  void move() {
    if (!_state.isPlaying || _state.isPaused || _state.isGameOver) return;

    final head = _state.snake.first;
    Offset newHead;

    switch (_state.direction) {
      case Direction.up:
        newHead = Offset(head.dx, head.dy - 1);
        break;
      case Direction.down:
        newHead = Offset(head.dx, head.dy + 1);
        break;
      case Direction.left:
        newHead = Offset(head.dx - 1, head.dy);
        break;
      case Direction.right:
        newHead = Offset(head.dx + 1, head.dy);
        break;
    }

    // 检查碰撞
    if (_checkCollision(newHead)) {
      _gameOver();
      return;
    }

    // 移动蛇身
    List<Offset> newSnake = [newHead, ..._state.snake];
    bool ate = false;

    // 磁铁效果：自动吸引食物
    if (_state.activePowerUp?.type == PowerUpType.magnet) {
      if (_isNear(newHead, _state.food, 2)) {
        ate = true;
      }
    }

    // 检查是否吃到食物
    if (newHead == _state.food) {
      ate = true;
    }

    // 检查是否吃到道具
    PowerUp? newPowerUp = _state.powerUp;
    PowerUp? newActivePowerUp = _state.activePowerUp;
    int newActivePowerUpEndTime = _state.activePowerUpEndTime;
    int newScore = _state.score;

    if (_state.powerUp != null && newHead == _state.powerUp!.position) {
      newScore += 2;
      newActivePowerUp = _state.powerUp;
      newActivePowerUpEndTime = DateTime.now().millisecondsSinceEpoch + 5000;
      newPowerUp = null;

      // 缩短道具立即生效
      if (_state.powerUp!.type == PowerUpType.shorten) {
        if (newSnake.length > 3) {
          newSnake.removeLast();
          newSnake.removeLast();
        }
        newActivePowerUp = null;
      }
    }

    if (!ate) {
      newSnake.removeLast();
    } else {
      newScore += 1;
    }

    // 更新状态
    _state = _state.copyWith(
      snake: newSnake,
      score: newScore,
      highScore: newScore > _state.highScore ? newScore : _state.highScore,
      food: ate ? _randomEmptyPosition(newSnake, _state.obstacles) : _state.food,
      powerUp: newPowerUp,
      activePowerUp: newActivePowerUp,
      activePowerUpEndTime: newActivePowerUpEndTime,
    );

    // 随机生成道具（增强模式）
    if (_state.mode == GameMode.enhanced && _state.powerUp == null && _random.nextDouble() < 0.02) {
      _generatePowerUp();
    }

    // 检查道具效果是否过期
    if (_state.activePowerUp != null) {
      if (DateTime.now().millisecondsSinceEpoch > _state.activePowerUpEndTime) {
        _state = _state.copyWith(activePowerUp: null);
      }
    }
  }

  /// 改变方向
  void changeDirection(Direction newDirection) {
    if (!_state.isPlaying || _state.isPaused || _state.isGameOver) return;

    // 不能反向
    if (_isOpposite(_state.direction, newDirection)) return;

    _state = _state.copyWith(direction: newDirection);
  }

  /// 重置游戏
  void reset() {
    _state = SnakeState.initial(
      mode: _state.mode,
      highScore: _state.highScore,
    );
  }

  /// 切换模式
  void setMode(GameMode mode) {
    _state = SnakeState.initial(
      mode: mode,
      highScore: _state.highScore,
    );
  }

  /// 更新最高分（从存储加载）
  void updateHighScore(int highScore) {
    _state = _state.copyWith(highScore: highScore);
  }

  // === 私有方法 ===

  bool _checkCollision(Offset head) {
    // 撞墙
    if (head.dx < 0 || head.dx >= _state.gridSize ||
        head.dy < 0 || head.dy >= _state.gridSize) {
      return true;
    }

    // 撞自己
    if (_state.snake.contains(head)) {
      return true;
    }

    // 撞障碍物
    if (_state.obstacles.contains(head)) {
      return true;
    }

    return false;
  }

  bool _isOpposite(Direction a, Direction b) {
    return (a == Direction.up && b == Direction.down) ||
           (a == Direction.down && b == Direction.up) ||
           (a == Direction.left && b == Direction.right) ||
           (a == Direction.right && b == Direction.left);
  }

  bool _isNear(Offset a, Offset b, int distance) {
    return (a.dx - b.dx).abs() <= distance && (a.dy - b.dy).abs() <= distance;
  }

  void _gameOver() {
    _state = _state.copyWith(
      isPlaying: false,
      isGameOver: true,
    );
  }

  Offset _randomEmptyPosition(List<Offset> snake, List<Offset> obstacles) {
    for (int i = 0; i < 100; i++) {
      final x = _random.nextInt(_state.gridSize).toDouble();
      final y = _random.nextInt(_state.gridSize).toDouble();
      final pos = Offset(x, y);
      if (!snake.contains(pos) && !obstacles.contains(pos)) {
        return pos;
      }
    }
    return const Offset(0, 0);
  }

  void _generateObstacles() {
    final obstacles = <Offset>[];
    // 生成 3-5 个障碍物
    final count = 3 + _random.nextInt(3);
    for (int i = 0; i < count; i++) {
      final pos = _randomEmptyPosition(_state.snake, obstacles);
      obstacles.add(pos);
    }
    _state = _state.copyWith(obstacles: obstacles);
  }

  void _generatePowerUp() {
    final types = PowerUpType.values;
    final type = types[_random.nextInt(types.length)];
    final pos = _randomEmptyPosition(_state.snake, _state.obstacles);
    _state = _state.copyWith(powerUp: PowerUp(position: pos, type: type));
  }
}