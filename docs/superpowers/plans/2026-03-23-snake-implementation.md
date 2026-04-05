# 贪吃蛇游戏实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现一个移动端贪吃蛇游戏，支持经典模式和增强模式，滑动手势控制。

**Architecture:** 采用与 Gomoku 相同的模式分离架构：Models 定义数据结构，Logic 处理游戏逻辑，Board 绘制游戏区域，Page 管理界面状态。游戏循环使用 Timer 驱动。

**Tech Stack:** Flutter, SharedPreferences (最高分存储), Timer (游戏循环)

---

## File Structure

```
app/lib/tools/snake/
├── snake_models.dart        # 数据模型：Direction, Position, PowerUpType, PowerUp, GameState, GameMode
├── snake_logic.dart         # 游戏逻辑：移动、碰撞检测、道具生成
├── snake_board.dart         # 游戏区域绘制：CustomPainter
├── snake_game_page.dart     # 游戏进行页面：手势控制、游戏循环
├── snake_page.dart          # 主页面：模式选择、开始界面
└── snake_tool.dart          # 工具注册入口

app/lib/main.dart            # 修改：注册 SnakeTool
```

---

### Task 1: 数据模型 (snake_models.dart)

**Files:**
- Create: `app/lib/tools/snake/snake_models.dart`

- [ ] **Step 1: 创建 snake_models.dart 文件**

```dart
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
    PowerUp? powerUp,
    PowerUp? activePowerUp,
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
      powerUp: powerUp,
      activePowerUp: activePowerUp,
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
```

- [ ] **Step 2: 提交数据模型**

```bash
git add app/lib/tools/snake/snake_models.dart
git commit -m "feat(snake): add snake game data models

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 2: 游戏逻辑 (snake_logic.dart)

**Files:**
- Create: `app/lib/tools/snake/snake_logic.dart`

- [ ] **Step 1: 创建 snake_logic.dart 文件**

```dart
import 'dart:math';
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
```

- [ ] **Step 2: 提交游戏逻辑**

```bash
git add app/lib/tools/snake/snake_logic.dart
git commit -m "feat(snake): add snake game logic

- Move snake with collision detection
- Power-ups: speed, shorten, magnet
- Progressive difficulty
- Obstacle generation for enhanced mode

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 3: 游戏区域绘制 (snake_board.dart)

**Files:**
- Create: `app/lib/tools/snake/snake_board.dart`

- [ ] **Step 1: 创建 snake_board.dart 文件**

```dart
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
```

- [ ] **Step 2: 提交游戏区域绘制**

```bash
git add app/lib/tools/snake/snake_board.dart
git commit -m "feat(snake): add snake game board widget

- CustomPainter for efficient rendering
- Snake with eyes and gradient body
- Power-ups with icons
- Magnet range indicator

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 4: 游戏页面 (snake_game_page.dart)

**Files:**
- Create: `app/lib/tools/snake/snake_game_page.dart`

- [ ] **Step 1: 创建 snake_game_page.dart 文件**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'snake_logic.dart';
import 'snake_models.dart';
import 'snake_board.dart';

class SnakeGamePage extends StatefulWidget {
  final GameMode mode;

  const SnakeGamePage({super.key, required this.mode});

  @override
  State<SnakeGamePage> createState() => _SnakeGamePageState();
}

class _SnakeGamePageState extends State<SnakeGamePage> {
  late SnakeLogic _logic;
  Timer? _gameTimer;
  double? _swipeStartX;
  double? _swipeStartY;

  @override
  void initState() {
    super.initState();
    _logic = SnakeLogic(mode: widget.mode);
    _loadHighScore();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final key = widget.mode == GameMode.classic
        ? 'snake_high_score_classic'
        : 'snake_high_score_enhanced';
    final highScore = prefs.getInt(key) ?? 0;
    setState(() {
      _logic.updateHighScore(highScore);
    });
  }

  Future<void> _saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final key = widget.mode == GameMode.classic
        ? 'snake_high_score_classic'
        : 'snake_high_score_enhanced';
    await prefs.setInt(key, _logic.state.highScore);
  }

  void _startGame() {
    setState(() {
      _logic.start();
    });
    _startGameLoop();
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    _updateGameLoop();
  }

  void _updateGameLoop() {
    final interval = _logic.state.moveInterval;

    // 加速道具效果
    var actualInterval = interval;
    if (_logic.state.activePowerUp?.type == PowerUpType.speed) {
      actualInterval = (interval * 0.6).round();
    }

    _gameTimer = Timer(Duration(milliseconds: actualInterval), () {
      if (_logic.state.isPlaying && !_logic.state.isPaused) {
        setState(() {
          _logic.move();
        });

        if (_logic.state.isGameOver) {
          _gameTimer?.cancel();
          _saveHighScore();
          _showGameOverDialog();
        } else {
          _updateGameLoop();
        }
      } else if (_logic.state.isPaused) {
        // 暂停时不移动，但继续循环等待恢复
        _updateGameLoop();
      }
    });
  }

  void _togglePause() {
    setState(() {
      _logic.togglePause();
    });
  }

  void _reset() {
    _gameTimer?.cancel();
    setState(() {
      _logic.reset();
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('游戏结束'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('本次得分: ${_logic.state.score}'),
            Text('最高记录: ${_logic.state.highScore}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('返回'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _reset();
              _startGame();
            },
            child: const Text('再来一局'),
          ),
        ],
      ),
    );
  }

  void _handleSwipe(DragEndDetails details) {
    if (!_logic.state.isPlaying || _logic.state.isPaused) return;

    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.dx.abs() > velocity.dy.abs()) {
      // 水平滑动
      if (velocity.dx > 0) {
        _logic.changeDirection(Direction.right);
      } else {
        _logic.changeDirection(Direction.left);
      }
    } else {
      // 垂直滑动
      if (velocity.dy > 0) {
        _logic.changeDirection(Direction.down);
      } else {
        _logic.changeDirection(Direction.up);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == GameMode.classic ? '贪吃蛇 - 经典' : '贪吃蛇 - 增强'),
        actions: [
          if (_logic.state.isPlaying && !_logic.state.isGameOver)
            IconButton(
              icon: Icon(_logic.state.isPaused ? Icons.play_arrow : Icons.pause),
              onPressed: _togglePause,
              tooltip: _logic.state.isPaused ? '继续' : '暂停',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _logic.state.isPlaying ? _reset : null,
            tooltip: '重新开始',
          ),
        ],
      ),
      body: GestureDetector(
        onVerticalDragEnd: _handleSwipe,
        onHorizontalDragEnd: _handleSwipe,
        child: Container(
          color: colorScheme.surface,
          width: double.infinity,
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 状态栏
              if (_logic.state.isPlaying && !_logic.state.isGameOver)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('分数', '${_logic.state.score}'),
                      _buildStatItem('长度', '${_logic.state.snake.length}'),
                      _buildStatItem('最高', '${_logic.state.highScore}'),
                      if (_logic.state.activePowerUp != null)
                        _buildActivePowerUp(),
                    ],
                  ),
                ),

              // 游戏区域
              SnakeBoard(state: _logic.state),

              // 开始界面
              if (!_logic.state.isPlaying)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        '最高分: ${_logic.state.highScore}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _startGame,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('开始游戏'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '滑动屏幕控制方向',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildActivePowerUp() {
    String label;
    IconData icon;

    switch (_logic.state.activePowerUp!.type) {
      case PowerUpType.speed:
        label = '加速中';
        icon = Icons.bolt;
        break;
      case PowerUpType.shorten:
        label = '缩短';
        icon = Icons.content_cut;
        break;
      case PowerUpType.magnet:
        label = '磁铁';
        icon = Icons.attractions;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 提交游戏页面**

```bash
git add app/lib/tools/snake/snake_game_page.dart
git commit -m "feat(snake): add snake game page

- Swipe gesture controls
- Game loop with progressive speed
- High score persistence
- Game over dialog

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 5: 主页面 (snake_page.dart)

**Files:**
- Create: `app/lib/tools/snake/snake_page.dart`

- [ ] **Step 1: 创建 snake_page.dart 文件**

```dart
import 'package:flutter/material.dart';
import 'snake_game_page.dart';
import 'snake_models.dart';

class SnakePage extends StatelessWidget {
  const SnakePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('贪吃蛇'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 游戏图标
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.videogame_asset,
                  size: 60,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 模式选择标题
            Text(
              '选择游戏模式',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // 经典模式
            _ModeCard(
              title: '经典模式',
              description: '传统贪吃蛇，吃食物变长，撞墙或撞自己游戏结束',
              icon: Icons.games,
              onTap: () => _startGame(context, GameMode.classic),
            ),
            const SizedBox(height: 12),

            // 增强模式
            _ModeCard(
              title: '增强模式',
              description: '包含加速、缩短、磁铁道具和障碍物，更具挑战性',
              icon: Icons.extension,
              onTap: () => _startGame(context, GameMode.enhanced),
            ),

            const Spacer(),

            // 操作提示
            Center(
              child: Text(
                '进入游戏后滑动屏幕控制方向',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame(BuildContext context, GameMode mode) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SnakeGamePage(mode: mode),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 提交主页面**

```bash
git add app/lib/tools/snake/snake_page.dart
git commit -m "feat(snake): add snake main page with mode selection

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 6: 工具注册 (snake_tool.dart)

**Files:**
- Create: `app/lib/tools/snake/snake_tool.dart`

- [ ] **Step 1: 创建 snake_tool.dart 文件**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'snake_page.dart';

class SnakeTool implements ToolModule {
  @override
  String get id => 'snake';

  @override
  String get name => '贪吃蛇';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.videogame_asset;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const SnakePage();
  }

  @override
  ToolSettings? get settings => null;

  @override
  Future<void> onInit() async {}

  @override
  Future<void> onDispose() async {}

  @override
  void onEnter() {}

  @override
  void onExit() {}
}
```

- [ ] **Step 2: 提交工具注册**

```bash
git add app/lib/tools/snake/snake_tool.dart
git commit -m "feat(snake): add snake tool registration

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 7: 注册到主应用

**Files:**
- Modify: `app/lib/main.dart`

- [ ] **Step 1: 在 main.dart 中注册 SnakeTool**

在第 19 行 `import 'tools/pomodoro/pomodoro_tool.dart';` 后添加一行：
```dart
import 'tools/snake/snake_tool.dart';
```

在第 36 行 `ToolRegistry.register(PomodoroTool());` 后添加一行：
```dart
ToolRegistry.register(SnakeTool());
```

完整的修改后代码片段：
```dart
// 导入区域（约第 20 行）
import 'tools/pomodoro/pomodoro_tool.dart';
import 'tools/pomodoro/services/pomodoro_service.dart';
import 'tools/snake/snake_tool.dart';  // 新增

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 注册工具
  ToolRegistry.register(CoinTool());
  // ... 其他工具 ...
  ToolRegistry.register(PomodoroTool());
  ToolRegistry.register(SnakeTool());  // 新增

  runApp(const MyApp());
}
```

- [ ] **Step 2: 提交主应用修改**

```bash
git add app/lib/main.dart
git commit -m "feat(snake): register snake tool in main app

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 8: 验证与测试

- [ ] **Step 1: 运行 Flutter 分析**

```bash
cd /home/nano/littlegrid/app && flutter analyze
```

Expected: No issues found

- [ ] **Step 2: 运行应用验证**

```bash
cd /home/nano/littlegrid/app && flutter run -d chrome --web-port=8080
```

手动测试：
1. 首页格子页出现贪吃蛇工具
2. 点击进入贪吃蛇页面
3. 选择经典模式开始游戏
4. 滑动控制蛇移动
5. 吃食物得分，撞墙游戏结束
6. 选择增强模式测试道具和障碍物

- [ ] **Step 3: 最终提交**

```bash
git add -A
git commit -m "feat(snake): complete snake game implementation

- Classic and enhanced game modes
- Swipe gesture controls
- Progressive difficulty
- Power-ups: speed, shorten, magnet
- Obstacles in enhanced mode
- High score persistence

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | 数据模型 | snake_models.dart |
| 2 | 游戏逻辑 | snake_logic.dart |
| 3 | 游戏区域绘制 | snake_board.dart |
| 4 | 游戏页面 | snake_game_page.dart |
| 5 | 主页面 | snake_page.dart |
| 6 | 工具注册 | snake_tool.dart |
| 7 | 主应用修改 | main.dart |
| 8 | 验证测试 | - |