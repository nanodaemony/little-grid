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