# 数独功能设计文档

**日期**: 2026-03-24
**状态**: 待审核
**分类**: game

---

## 1. 功能概述

在 LittleGrid 应用中新增数独工具，支持四个难度级别的单人解题游戏。

### 1.1 核心功能

- **四个难度级别**：
  - 简单：36-40 个提示数
  - 中等：30-34 个提示数
  - 困难：25-29 个提示数
  - 专家：20-24 个提示数

- **算法实时生成题目**：使用回溯法生成，保证唯一解，无限题目数量

- **9×9 标准数独棋盘**

### 1.2 辅助功能（设置开关控制）

所有辅助功能开关统一放在右上角设置页面：

- **错误标记**：填入错误数字时，格子显示红色边框
- **候选数提示**：在空白格内显示可能的数字（小字）
- **自动排除**：自动移除已被同行/列/宫占用的候选数
- **提示功能**：点击提示按钮，自动填入一个正确数字

### 1.3 计时与记录

- 实时显示用时
- 按难度保存最佳成绩到本地存储

---

## 2. 界面设计

### 2.1 主页面布局

```
┌─────────────────────────────────────┐
│  ←  数独              [计时器] [⚙]  │  AppBar
├─────────────────────────────────────┤
│                                     │
│   ┌─────────────────────────────┐   │
│   │ 5 │ 3 │   │   │ 7 │   │   │   │   │
│   ├───┼───┼───┼───┼───┼───┼───┼───┤   │
│   │ 6 │   │   │ 1 │ 9 │ 5 │   │   │   │
│   ├───┼───┼───┼───┼───┼───┼───┼───┤   │
│   │   │ 9 │ 8 │   │   │   │   │ 6 │   │
│   ├───┼───┼───┼───┼───┼───┼───┼───┤   │  9×9 棋盘
│   │ 8 │   │   │   │ 6 │   │   │ 3 │   │
│   ├───┼───┼───┼───┼───┼───┼───┼───┤   │
│   │ 4 │   │   │ 8 │   │ 3 │   │ 1 │   │
│   ├───┼───┼───┼───┼───┼───┼───┼───┤   │
│   │ 7 │   │   │   │ 2 │   │   │ 6 │   │
│   ├───┼───┼───┼───┼───┼───┼───┼───┤   │
│   │   │ 6 │   │   │   │   │ 2 │ 8 │   │
│   ├───┼───┼───┼───┼───┼───┼───┼───┤   │
│   │   │   │   │ 4 │ 1 │ 9 │   │ 5 │   │
│   ├───┼───┼───┼───┼───┼───┼───┼───┤   │
│   │   │   │   │   │ 8 │   │   │ 7 │ 9 │
│   └─────────────────────────────┘   │
│                                     │
├─────────────────────────────────────┤
│  [1] [2] [3] [4] [5] [6] [7] [8] [9]│  数字键盘
├─────────────────────────────────────┤
│  [清除] [笔记模式] [提示] [撤销]    │  操作按钮
└─────────────────────────────────────┘
```

### 2.2 设置页面

点击右上角⚙图标进入设置页面：

```
┌─────────────────────────────────────┐
│  ←  设置                             │
├─────────────────────────────────────┤
│                                     │
│  辅助功能                           │
│  ─────────────────────────────────  │
│                                     │
│  错误标记            [开关]         │
│  填入错误数字时，格子显示红色边框   │
│                                     │
│  候选数提示          [开关]         │
│  在空白格内显示可能的数字（小字）   │
│                                     │
│  自动排除            [开关]         │
│  自动移除已被同行/列/宫占用的候选数│
│                                     │
│  提示功能            [开关]         │
│  点击提示按钮，自动填入一个正确数字│
│                                     │
├─────────────────────────────────────┤
│                                     │
│  游戏记录                           │
│  ─────────────────────────────────  │
│                                     │
│  简单    最佳: 03:24                │
│  中等    最佳: 08:15                │
│  困难    最佳: 15:32                │
│  专家    最佳: --:--                │
│                                     │
│           [清除所有记录]            │
│                                     │
└─────────────────────────────────────┘
```

### 2.3 视觉规范

**颜色**：
- 提示数（固定）：深色，不可修改
- 用户填入数：主题色
- 错误标记：红色边框
- 选中格子：蓝色边框
- 关联高亮：浅色背景（同行/列/宫）
- 候选数：小字号灰色

**字体**：
- 主数字：24px，加粗
- 候选数：10px，普通

---

## 3. 技术架构

### 3.1 目录结构

```
lib/tools/sudoku/
├── sudoku_tool.dart              # ToolModule 实现
├── sudoku_page.dart              # 主页面
├── sudoku_settings_page.dart     # 设置页面
├── models/
│   ├── sudoku_cell.dart          # 单元格模型
│   ├── sudoku_board.dart         # 棋盘状态
│   └── sudoku_settings.dart      # 设置状态
├── services/
│   ├── sudoku_generator.dart     # 题目生成算法
│   ├── sudoku_solver.dart        # 求解算法
│   └── sudoku_validator.dart     # 验证逻辑
├── widgets/
│   ├── sudoku_board_widget.dart  # 棋盘绘制
│   ├── sudoku_cell_widget.dart   # 单元格绘制
│   ├── number_keyboard.dart      # 数字键盘
│   └── action_buttons.dart       # 操作按钮
└── utils/
    └── sudoku_storage.dart       # 本地存储
```

### 3.2 数据模型

**SudokuCell（单元格）**
```dart
class SudokuCell {
  final int? answer;           // 正确答案（1-9，null 表示空）
  int? userValue;              // 用户填入的值
  Set<int> notes;              // 笔记（候选数）
  bool isFixed;                // 是否是提示数（不可修改）
  bool isError;                // 是否填错
}
```

**SudokuBoard（棋盘状态）**
```dart
class SudokuBoard {
  final List<List<SudokuCell>> cells;  // 9×9 网格
  final Difficulty difficulty;          // 难度
  final Duration elapsedTime;           // 用时
  final List<Move> history;             // 操作历史（用于撤销）
  final bool isCompleted;               // 是否完成
}

enum Difficulty { easy, medium, hard, expert }
```

**SudokuSettings（设置）**
```dart
class SudokuSettings {
  bool showErrorHighlight;     // 错误标记
  bool showCandidates;         // 候选数提示
  bool autoEliminate;          // 自动排除
  bool enableHint;             // 提示功能
}
```

**Move（操作记录）**
```dart
class Move {
  final int row;
  final int col;
  final int? previousValue;    // 之前的值
  final int? newValue;         // 新值
  final Set<int> previousNotes; // 之前的笔记
}
```

### 3.3 ToolModule 实现

```dart
class SudokuTool implements ToolModule {
  @override
  String get id => 'sudoku';

  @override
  String get name => '数独';

  @override
  IconData get icon => Icons.grid_3x3;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) => const SudokuPage();
}
```

---

## 4. 核心算法

### 4.1 题目生成算法（回溯法）

**生成流程**：
1. 创建一个完整的有效数独解（填充整个 9×9 网格）
2. 根据难度随机挖空一定数量的格子
3. 确保挖空后仍有唯一解

**难度与挖空数量**：

| 难度 | 提示数 | 挖空数 |
|------|--------|--------|
| 简单 | 36-40 | 41-45 |
| 中等 | 30-34 | 47-51 |
| 困难 | 25-29 | 52-56 |
| 专家 | 20-24 | 57-61 |

**生成完整解（回溯填充）**：
```dart
bool fillBoard(List<List<int>> board, int row, int col) {
  if (row == 9) return true;  // 填充完成
  if (col == 9) return fillBoard(board, row + 1, 0);
  if (board[row][col] != 0) return fillBoard(board, row, col + 1);

  // 随机打乱 1-9
  List<int> numbers = [1,2,3,4,5,6,7,8,9]..shuffle();

  for (int num in numbers) {
    if (isValid(board, row, col, num)) {
      board[row][col] = num;
      if (fillBoard(board, row, col + 1)) return true;
      board[row][col] = 0;
    }
  }
  return false;
}
```

### 4.2 唯一解验证

挖空时需要确保唯一解：

```dart
int countSolutions(List<List<int>> board, {int limit = 2}) {
  int count = 0;
  void solve(List<List<int>> b) {
    if (count >= limit) return;
    // 找到第一个空格
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (b[i][j] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (isValid(b, i, j, num)) {
              b[i][j] = num;
              solve(b);
              b[i][j] = 0;
            }
          }
          return;
        }
      }
    }
    count++;
  }
  solve(board);
  return count;
}
```

### 4.3 候选数计算

```dart
Set<int> getCandidates(List<List<SudokuCell>> board, int row, int col) {
  if (board[row][col].userValue != null) return {};

  Set<int> used = {};
  // 同行已用数字
  for (int c = 0; c < 9; c++) {
    if (board[row][c].userValue != null) {
      used.add(board[row][c].userValue!);
    }
  }
  // 同列已用数字
  for (int r = 0; r < 9; r++) {
    if (board[r][col].userValue != null) {
      used.add(board[r][col].userValue!);
    }
  }
  // 同宫已用数字
  int boxRow = (row ~/ 3) * 3;
  int boxCol = (col ~/ 3) * 3;
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (board[boxRow + i][boxCol + j].userValue != null) {
        used.add(board[boxRow + i][boxCol + j].userValue!);
      }
    }
  }

  return {1,2,3,4,5,6,7,8,9}.difference(used);
}
```

### 4.4 验证函数

```dart
bool isValid(List<List<int>> board, int row, int col, int num) {
  // 检查行
  for (int c = 0; c < 9; c++) {
    if (board[row][c] == num) return false;
  }
  // 检查列
  for (int r = 0; r < 9; r++) {
    if (board[r][col] == num) return false;
  }
  // 检查宫
  int boxRow = (row ~/ 3) * 3;
  int boxCol = (col ~/ 3) * 3;
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (board[boxRow + i][boxCol + j] == num) return false;
    }
  }
  return true;
}
```

---

## 5. 交互设计

### 5.1 单元格选中与输入

- **点击格子**：选中该格子，高亮显示（蓝色边框）
- **点击数字键盘**：将数字填入选中格子
- **长按格子**：进入笔记模式，填入候选数

### 5.2 高亮联动

选中某格时，高亮相关的行、列、宫（浅色背景），帮助玩家观察：
- 同行所有格子
- 同列所有格子
- 同宫所有格子

### 5.3 笔记模式

- **开启笔记模式后**：点击数字键盘，数字以小字显示在格子内（不覆盖答案）
- **同一数字再点一次**：移除该候选数
- **关闭笔记模式后**：恢复正常填数

### 5.4 撤销功能

- 保存操作历史，支持撤销到上一步
- 最多保存 100 步历史

### 5.5 完成判定

- 所有格子填满且正确 → 弹窗祝贺，显示用时
- 询问是否保存成绩、开始新游戏

---

## 6. 本地存储

使用 `shared_preferences` 存储以下数据：

**设置数据**：
```dart
// 键名
const String keyShowErrorHighlight = 'sudoku_show_error_highlight';
const String keyShowCandidates = 'sudoku_show_candidates';
const String keyAutoEliminate = 'sudoku_auto_eliminate';
const String keyEnableHint = 'sudoku_enable_hint';
```

**最佳成绩**：
```dart
// 键名：sudoku_best_{difficulty}
// 值：秒数（int）
const String keyBestEasy = 'sudoku_best_easy';
const String keyBestMedium = 'sudoku_best_medium';
const String keyBestHard = 'sudoku_best_hard';
const String keyBestExpert = 'sudoku_best_expert';
```

---

## 7. 依赖项

```yaml
dependencies:
  shared_preferences: ^2.2.2  # 本地存储最佳成绩和设置
  # 其他使用 Flutter 内置组件即可
```

---

## 8. 验收标准

- [ ] 四个难度级别可正常切换
- [ ] 题目生成算法正确，保证唯一解
- [ ] 数独规则验证正确（行、列、宫不重复）
- [ ] 错误标记功能正常
- [ ] 候选数提示功能正常
- [ ] 自动排除功能正常
- [ ] 提示功能正常
- [ ] 计时功能正常
- [ ] 最佳成绩保存和显示正常
- [ ] 撤销功能正常
- [ ] 笔记模式正常
- [ ] 设置页面开关正常工作
- [ ] 视觉风格与现有应用一致