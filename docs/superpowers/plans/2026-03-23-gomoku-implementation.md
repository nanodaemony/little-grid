# 五子棋功能实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在小方格应用中新增五子棋对战游戏功能格子，支持双人对战，100×100 棋盘可拖动浏览。

**Architecture:** 使用 Flutter 的 InteractiveViewer + CustomPaint 实现大棋盘拖动浏览，游戏逻辑与 UI 分离，遵循现有 ToolModule 模式。

**Tech Stack:** Flutter, Dart, InteractiveViewer, CustomPaint

---

## File Structure

| 文件 | 职责 |
|------|------|
| `lib/tools/gomoku/gomoku_models.dart` | 数据模型：Stone 枚举、Position 类、GomokuState 类 |
| `lib/tools/gomoku/gomoku_logic.dart` | 游戏逻辑：落子、胜负判断、悔棋 |
| `lib/tools/gomoku/gomoku_board.dart` | 棋盘绘制：CustomPaint 绘制网格和棋子 |
| `lib/tools/gomoku/gomoku_page.dart` | 页面入口：UI 布局、交互处理 |
| `lib/tools/gomoku/gomoku_tool.dart` | ToolModule 实现：注册到工具列表 |
| `lib/main.dart` | 注册 GomokuTool |
| `test/tools/gomoku/gomoku_logic_test.dart` | 游戏逻辑单元测试 |

---

### Task 1: 数据模型

**Files:**
- Create: `lib/tools/gomoku/gomoku_models.dart`

- [ ] **Step 1: 创建数据模型文件**

```dart
/// 棋子状态
enum Stone { empty, black, white }

/// 坐标位置
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position && row == other.row && col == other.col;

  @override
  int get hashCode => Object.hash(row, col);
}

/// 游戏状态
class GomokuState {
  final List<List<Stone>> board;
  final Stone currentPlayer;
  final List<Position> history;
  final bool isGameOver;
  final Stone? winner;

  GomokuState({
    required this.board,
    required this.currentPlayer,
    required this.history,
    this.isGameOver = false,
    this.winner,
  });

  /// 创建初始状态（100×100 空棋盘）
  factory GomokuState.initial() {
    const boardSize = 100;
    final board = List.generate(
      boardSize,
      (_) => List.generate(boardSize, (_) => Stone.empty),
    );
    return GomokuState(
      board: board,
      currentPlayer: Stone.black,
      history: [],
    );
  }

  /// 复制并修改状态
  GomokuState copyWith({
    List<List<Stone>>? board,
    Stone? currentPlayer,
    List<Position>? history,
    bool? isGameOver,
    Stone? winner,
  }) {
    return GomokuState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      history: history ?? this.history,
      isGameOver: isGameOver ?? this.isGameOver,
      winner: winner ?? this.winner,
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add lib/tools/gomoku/gomoku_models.dart
git commit -m "feat(gomoku): add data models (Stone, Position, GomokuState)"
```

---

### Task 2: 游戏逻辑

**Files:**
- Create: `lib/tools/gomoku/gomoku_logic.dart`
- Create: `test/tools/gomoku/gomoku_logic_test.dart`

- [ ] **Step 1: 创建测试文件**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/tools/gomoku/gomoku_models.dart';
import 'package:littlegrid/tools/gomoku/gomoku_logic.dart';

void main() {
  group('GomokuLogic', () {
    test('initial state should have empty board and black player first', () {
      final logic = GomokuLogic();
      expect(logic.state.currentPlayer, Stone.black);
      expect(logic.state.history.isEmpty, true);
      expect(logic.state.isGameOver, false);
    });

    test('placeStone should place stone and switch player', () {
      final logic = GomokuLogic();
      logic.placeStone(50, 50);

      expect(logic.state.board[50][50], Stone.black);
      expect(logic.state.currentPlayer, Stone.white);
      expect(logic.state.history.length, 1);
    });

    test('placeStone should not work on occupied cell', () {
      final logic = GomokuLogic();
      logic.placeStone(50, 50);
      logic.placeStone(50, 50);

      expect(logic.state.board[50][50], Stone.black);
      expect(logic.state.currentPlayer, Stone.white);
    });

    test('undo should remove last stone', () {
      final logic = GomokuLogic();
      logic.placeStone(50, 50);
      logic.undo();

      expect(logic.state.board[50][50], Stone.empty);
      expect(logic.state.currentPlayer, Stone.black);
      expect(logic.state.history.isEmpty, true);
    });

    test('detect horizontal win', () {
      final logic = GomokuLogic();
      // Black places 5 stones horizontally
      for (int i = 0; i < 5; i++) {
        logic.placeStone(50, 50 + i);
        if (i < 4) logic.placeStone(51, 50 + i); // White places elsewhere
      }

      expect(logic.state.isGameOver, true);
      expect(logic.state.winner, Stone.black);
    });

    test('detect vertical win', () {
      final logic = GomokuLogic();
      for (int i = 0; i < 5; i++) {
        logic.placeStone(50 + i, 50);
        if (i < 4) logic.placeStone(50 + i, 51);
      }

      expect(logic.state.isGameOver, true);
      expect(logic.state.winner, Stone.black);
    });

    test('detect diagonal win', () {
      final logic = GomokuLogic();
      for (int i = 0; i < 5; i++) {
        logic.placeStone(50 + i, 50 + i);
        if (i < 4) logic.placeStone(50 + i, 52);
      }

      expect(logic.state.isGameOver, true);
      expect(logic.state.winner, Stone.black);
    });

    test('reset should clear the board', () {
      final logic = GomokuLogic();
      logic.placeStone(50, 50);
      logic.reset();

      expect(logic.state.board[50][50], Stone.empty);
      expect(logic.state.currentPlayer, Stone.black);
      expect(logic.state.history.isEmpty, true);
      expect(logic.state.isGameOver, false);
    });
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `cd /root/littlegrid/app && flutter test test/tools/gomoku/gomoku_logic_test.dart`
Expected: FAIL (文件不存在)

- [ ] **Step 3: 创建游戏逻辑文件**

```dart
import 'gomoku_models.dart';

class GomokuLogic {
  GomokuState _state = GomokuState.initial();

  GomokuState get state => _state;

  /// 落子
  void placeStone(int row, int col) {
    if (_state.isGameOver) return;
    if (_state.board[row][col] != Stone.empty) return;

    // 创建新棋盘
    final newBoard = _state.board.map((r) => r.toList()).toList();
    newBoard[row][col] = _state.currentPlayer;

    // 记录历史
    final newHistory = [..._state.history, Position(row, col)];

    // 检查胜负
    final winner = _checkWin(row, col, newBoard)
        ? _state.currentPlayer
        : null;

    _state = _state.copyWith(
      board: newBoard,
      currentPlayer: _state.currentPlayer == Stone.black
          ? Stone.white
          : Stone.black,
      history: newHistory,
      isGameOver: winner != null,
      winner: winner,
    );
  }

  /// 悔棋
  void undo() {
    if (_state.history.isEmpty) return;
    if (_state.isGameOver) return;

    final lastMove = _state.history.last;
    final newBoard = _state.board.map((r) => r.toList()).toList();
    newBoard[lastMove.row][lastMove.col] = Stone.empty;

    final newHistory = _state.history.sublist(0, _state.history.length - 1);

    _state = _state.copyWith(
      board: newBoard,
      currentPlayer: _state.currentPlayer == Stone.black
          ? Stone.white
          : Stone.black,
      history: newHistory,
    );
  }

  /// 重新开始
  void reset() {
    _state = GomokuState.initial();
  }

  /// 检查是否获胜
  bool _checkWin(int row, int col, List<List<Stone>> board) {
    final stone = board[row][col];

    // 四个方向：水平、垂直、主对角线、副对角线
    final directions = [
      [(0, 1), (0, -1)],   // 水平
      [(1, 0), (-1, 0)],   // 垂直
      [(1, 1), (-1, -1)],  // 主对角线
      [(1, -1), (-1, 1)],  // 副对角线
    ];

    for (final dir in directions) {
      int count = 1;

      // 正方向计数
      count += _countInDirection(row, col, dir[0].$1, dir[0].$2, stone, board);
      // 反方向计数
      count += _countInDirection(row, col, dir[1].$1, dir[1].$2, stone, board);

      if (count >= 5) return true;
    }

    return false;
  }

  /// 在指定方向上计数连续同色棋子
  int _countInDirection(
    int row,
    int col,
    int dRow,
    int dCol,
    Stone stone,
    List<List<Stone>> board,
  ) {
    int count = 0;
    int r = row + dRow;
    int c = col + dCol;

    while (r >= 0 && r < 100 && c >= 0 && c < 100 && board[r][c] == stone) {
      count++;
      r += dRow;
      c += dCol;
    }

    return count;
  }
}
```

- [ ] **Step 4: 运行测试确认通过**

Run: `cd /root/littlegrid/app && flutter test test/tools/gomoku/gomoku_logic_test.dart`
Expected: PASS

- [ ] **Step 5: 提交**

```bash
git add lib/tools/gomoku/gomoku_logic.dart test/tools/gomoku/gomoku_logic_test.dart
git commit -m "feat(gomoku): add game logic with tests"
```

---

### Task 3: 棋盘绘制组件

**Files:**
- Create: `lib/tools/gomoku/gomoku_board.dart`

- [ ] **Step 1: 创建棋盘绘制组件**

```dart
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
```

- [ ] **Step 2: 提交**

```bash
git add lib/tools/gomoku/gomoku_board.dart
git commit -m "feat(gomoku): add board painting widget with CustomPaint"
```

---

### Task 4: 页面入口

**Files:**
- Create: `lib/tools/gomoku/gomoku_page.dart`

- [ ] **Step 1: 创建页面组件**

```dart
import 'package:flutter/material.dart';
import 'gomoku_board.dart';
import 'gomoku_logic.dart';
import 'gomoku_models.dart';

class GomokuPage extends StatefulWidget {
  const GomokuPage({super.key});

  @override
  State<GomokuPage> createState() => _GomokuPageState();
}

class _GomokuPageState extends State<GomokuPage> {
  late GomokuLogic _logic;
  late TransformationController _transformController;

  @override
  void initState() {
    super.initState();
    _logic = GomokuLogic();
    _transformController = TransformationController();
    _centerBoard();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  /// 将视图定位到棋盘中心
  void _centerBoard() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      final boardPixelSize = GomokuBoard.boardPixelSize;

      final offsetX = (boardPixelSize - screenSize.width) / 2;
      final offsetY = (boardPixelSize - screenSize.height + kToolbarHeight) / 2;

      _transformController.value = Matrix4.translation(
        Offset(-offsetX, -offsetY),
      );
    });
  }

  void _placeStone(int row, int col) {
    setState(() {
      _logic.placeStone(row, col);
    });

    if (_logic.state.isGameOver) {
      _showWinDialog();
    }
  }

  void _undo() {
    setState(() {
      _logic.undo();
    });
  }

  void _reset() {
    setState(() {
      _logic.reset();
    });
    _centerBoard();
  }

  void _showWinDialog() {
    final winner = _logic.state.winner == Stone.black ? '黑棋' : '白棋';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('游戏结束'),
        content: Text('$winner 获胜!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _reset();
            },
            child: const Text('再来一局'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('五子棋'),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: _logic.state.history.isEmpty || _logic.state.isGameOver
                ? null
                : _undo,
            tooltip: '悔棋',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: '重新开始',
          ),
        ],
      ),
      body: Column(
        children: [
          // 当前玩家指示
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: _logic.state.currentPlayer == Stone.black
                        ? Colors.black
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black38),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_logic.state.currentPlayer == Stone.black ? "黑棋" : "白棋"} 轮流',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          // 棋盘
          Expanded(
            child: InteractiveViewer(
              transformationController: _transformController,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.5,
              maxScale: 2.0,
              child: GomokuBoard(
                state: _logic.state,
                onPlaceStone: _placeStone,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add lib/tools/gomoku/gomoku_page.dart
git commit -m "feat(gomoku): add game page with InteractiveViewer"
```

---

### Task 5: ToolModule 实现

**Files:**
- Create: `lib/tools/gomoku/gomoku_tool.dart`

- [ ] **Step 1: 创建 ToolModule 实现**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'gomoku_page.dart';

class GomokuTool implements ToolModule {
  @override
  String get id => 'gomoku';

  @override
  String get name => '五子棋';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.grid_on;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const GomokuPage();
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

- [ ] **Step 2: 提交**

```bash
git add lib/tools/gomoku/gomoku_tool.dart
git commit -m "feat(gomoku): add GomokuTool module implementation"
```

---

### Task 6: 注册工具

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: 在 main.dart 中注册 GomokuTool**

在文件顶部添加导入：
```dart
import 'tools/gomoku/gomoku_tool.dart';
```

在 `main()` 函数中添加注册（在其他工具注册之后）：
```dart
ToolRegistry.register(GomokuTool());
```

完整修改后的 `main.dart`：
```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/services/tool_registry.dart';
import 'core/ui/theme.dart';
import 'pages/grid_page.dart';
import 'pages/profile_page.dart';
import 'providers/app_provider.dart';
import 'tools/coin/coin_tool.dart';
import 'tools/dice/dice_tool.dart';
import 'tools/card/card_tool.dart';
import 'tools/todo/todo_tool.dart';
import 'tools/calculator/calculator_tool.dart';
import 'tools/calendar/calendar_tool.dart';
import 'tools/weather/weather_tool.dart';
import 'tools/gomoku/gomoku_tool.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 注册工具
  ToolRegistry.register(CoinTool());
  ToolRegistry.register(DiceTool());
  ToolRegistry.register(CardTool());
  ToolRegistry.register(TodoTool());
  ToolRegistry.register(CalculatorTool());
  ToolRegistry.register(CalendarTool());
  ToolRegistry.register(WeatherTool());
  ToolRegistry.register(GomokuTool());

  runApp(const MyApp());
}
```

- [ ] **Step 2: 提交**

```bash
git add lib/main.dart
git commit -m "feat(gomoku): register GomokuTool in main.dart"
```

---

### Task 7: 验证运行

- [ ] **Step 1: 运行应用验证功能**

Run: `cd /root/littlegrid/app && flutter run -d chrome --web-port=8080` (或其他可用设备)

验证项：
1. 主页格子中显示"五子棋"图标
2. 点击进入五子棋页面
3. 棋盘初始居中显示
4. 点击格子可以落子（黑白交替）
5. 拖动可以浏览棋盘不同区域
6. 悔棋功能正常
7. 重新开始功能正常
8. 五子连珠后弹出胜利提示

- [ ] **Step 2: 运行所有测试**

Run: `cd /root/littlegrid/app && flutter test`

Expected: All tests pass

- [ ] **Step 3: 最终提交**

```bash
git add -A
git commit -m "feat(gomoku): complete gomoku game feature"
```