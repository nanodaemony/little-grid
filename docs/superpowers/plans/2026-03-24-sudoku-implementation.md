# 数独功能实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 LittleGrid 应用中新增数独工具，支持四难度单人解题游戏，包含辅助功能和计时记录。

**Architecture:** 使用回溯法生成数独题目，保证唯一解。状态管理参考 Gomoku 模式（Logic + State），UI 使用 CustomPaint 绘制棋盘。辅助功能开关和最佳成绩通过 SharedPreferences 存储。

**Tech Stack:** Flutter, SharedPreferences, Dart

---

## 文件结构

```
app/lib/tools/sudoku/
├── sudoku_tool.dart           # ToolModule 实现
├── sudoku_models.dart         # 数据模型
├── sudoku_generator.dart      # 题目生成算法
├── sudoku_logic.dart          # 游戏逻辑
├── sudoku_board.dart          # 棋盘绘制组件
├── sudoku_page.dart           # 主页面
├── sudoku_settings_page.dart  # 设置页面
└── sudoku_storage.dart        # 本地存储服务

app/test/tools/sudoku/
├── sudoku_generator_test.dart # 生成算法测试
├── sudoku_logic_test.dart     # 游戏逻辑测试
└── sudoku_storage_test.dart   # 存储测试
```

---

### Task 1: 数据模型

**Files:**
- Create: `app/lib/tools/sudoku/sudoku_models.dart`
- Test: `app/test/tools/sudoku/sudoku_models_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// app/test/tools/sudoku/sudoku_models_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/tools/sudoku/sudoku_models.dart';

void main() {
  group('SudokuCell', () {
    test('creates empty cell', () {
      final cell = SudokuCell.empty();
      expect(cell.answer, isNull);
      expect(cell.userValue, isNull);
      expect(cell.notes.isEmpty, true);
      expect(cell.isFixed, false);
    });

    test('creates fixed cell with answer', () {
      final cell = SudokuCell.fixed(5);
      expect(cell.answer, 5);
      expect(cell.isFixed, true);
      expect(cell.userValue, isNull);
    });

    test('isCorrect returns true when userValue matches answer', () {
      final cell = SudokuCell(answer: 5, isFixed: false);
      expect(cell.isCorrect, isNull); // userValue is null

      final filledCell = cell.copyWith(userValue: 5);
      expect(filledCell.isCorrect, true);

      final wrongCell = cell.copyWith(userValue: 3);
      expect(wrongCell.isCorrect, false);
    });
  });

  group('Difficulty', () {
    test('easy has 36-40 clues', () {
      final clues = Difficulty.easy.clueCount;
      expect(clues, greaterThanOrEqualTo(36));
      expect(clues, lessThanOrEqualTo(40));
    });

    test('expert has 20-24 clues', () {
      final clues = Difficulty.expert.clueCount;
      expect(clues, greaterThanOrEqualTo(20));
      expect(clues, lessThanOrEqualTo(24));
    });
  });

  group('Move', () {
    test('records value change', () {
      final move = Move(
        row: 2,
        col: 3,
        previousValue: null,
        newValue: 5,
        previousNotes: {},
      );
      expect(move.row, 2);
      expect(move.col, 3);
      expect(move.previousValue, isNull);
      expect(move.newValue, 5);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/tools/sudoku/sudoku_models_test.dart`
Expected: FAIL with "Error: Could not resolve 'package:littlegrid/tools/sudoku/sudoku_models.dart'"

- [ ] **Step 3: Write minimal implementation**

```dart
// app/lib/tools/sudoku/sudoku_models.dart
import 'dart:math';

/// 难度级别
enum Difficulty {
  easy(36, 40),
  medium(30, 34),
  hard(25, 29),
  expert(20, 24);

  final int minClues;
  final int maxClues;

  const Difficulty(this.minClues, this.maxClues);

  /// 随机生成提示数
  int get clueCount => minClues + Random().nextInt(maxClues - minClues + 1);
}

/// 数独单元格
class SudokuCell {
  final int? answer;        // 正确答案
  final int? userValue;     // 用户填入的值
  final Set<int> notes;     // 笔记（候选数）
  final bool isFixed;       // 是否是提示数

  const SudokuCell({
    this.answer,
    this.userValue,
    this.notes = const {},
    this.isFixed = false,
  });

  /// 创建空单元格
  factory SudokuCell.empty() => const SudokuCell();

  /// 创建提示数单元格
  factory SudokuCell.fixed(int value) => SudokuCell(
    answer: value,
    isFixed: true,
  );

  /// 是否填入正确（null 表示未填）
  bool? get isCorrect {
    if (userValue == null) return null;
    return userValue == answer;
  }

  /// 是否有值
  bool get hasValue => userValue != null;

  /// 复制并修改
  SudokuCell copyWith({
    int? answer,
    int? userValue,
    Set<int>? notes,
    bool? isFixed,
    bool clearUserValue = false,
    bool clearNotes = false,
  }) {
    return SudokuCell(
      answer: answer ?? this.answer,
      userValue: clearUserValue ? null : (userValue ?? this.userValue),
      notes: clearNotes ? {} : (notes ?? this.notes),
      isFixed: isFixed ?? this.isFixed,
    );
  }
}

/// 操作记录（用于撤销）
class Move {
  final int row;
  final int col;
  final int? previousValue;
  final int? newValue;
  final Set<int> previousNotes;

  const Move({
    required this.row,
    required this.col,
    this.previousValue,
    this.newValue,
    this.previousNotes = const {},
  });
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test test/tools/sudoku/sudoku_models_test.dart`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add app/lib/tools/sudoku/sudoku_models.dart app/test/tools/sudoku/sudoku_models_test.dart
git commit -m "feat(sudoku): add data models for sudoku cell, difficulty, and move"
```

---

### Task 2: 验证函数

**Files:**
- Create: `app/lib/tools/sudoku/sudoku_validator.dart`
- Test: `app/test/tools/sudoku/sudoku_validator_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// app/test/tools/sudoku/sudoku_validator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/tools/sudoku/sudoku_validator.dart';

void main() {
  group('SudokuValidator', () {
    group('isValidPlacement', () {
      test('returns true for empty cell', () {
        final board = List.generate(9, (_) => List.generate(9, (_) => 0));
        expect(SudokuValidator.isValidPlacement(board, 0, 0, 5), true);
      });

      test('returns false when number exists in same row', () {
        final board = List.generate(9, (_) => List.generate(9, (_) => 0));
        board[0][3] = 5;
        expect(SudokuValidator.isValidPlacement(board, 0, 0, 5), false);
      });

      test('returns false when number exists in same column', () {
        final board = List.generate(9, (_) => List.generate(9, (_) => 0));
        board[3][0] = 5;
        expect(SudokuValidator.isValidPlacement(board, 0, 0, 5), false);
      });

      test('returns false when number exists in same box', () {
        final board = List.generate(9, (_) => List.generate(9, (_) => 0));
        board[1][1] = 5; // same 3x3 box as (0,0)
        expect(SudokuValidator.isValidPlacement(board, 0, 0, 5), false);
      });

      test('returns true when number not in row/col/box', () {
        final board = List.generate(9, (_) => List.generate(9, (_) => 0));
        board[0][3] = 1;
        board[3][0] = 2;
        board[1][1] = 3;
        expect(SudokuValidator.isValidPlacement(board, 0, 0, 5), true);
      });
    });

    group('isValidBoard', () {
      test('returns true for valid complete board', () {
        final board = [
          [5,3,4,6,7,8,9,1,2],
          [6,7,2,1,9,5,3,4,8],
          [1,9,8,3,4,2,5,6,7],
          [8,5,9,7,6,1,4,2,3],
          [4,2,6,8,5,3,7,9,1],
          [7,1,3,9,2,4,8,5,6],
          [9,6,1,5,3,7,2,8,4],
          [2,8,7,4,1,9,6,3,5],
          [3,4,5,2,8,6,1,7,9],
        ];
        expect(SudokuValidator.isValidBoard(board), true);
      });

      test('returns false for invalid board with duplicate in row', () {
        final board = List.generate(9, (i) => List.generate(9, (j) => (i * 9 + j) % 9 + 1));
        expect(SudokuValidator.isValidBoard(board), false);
      });
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/tools/sudoku/sudoku_validator_test.dart`
Expected: FAIL with "Error: Could not resolve 'package:littlegrid/tools/sudoku/sudoku_validator.dart'"

- [ ] **Step 3: Write minimal implementation**

```dart
// app/lib/tools/sudoku/sudoku_validator.dart
/// 数独验证工具类
class SudokuValidator {
  /// 检查在指定位置放置数字是否有效
  static bool isValidPlacement(List<List<int>> board, int row, int col, int num) {
    // 检查行
    for (int c = 0; c < 9; c++) {
      if (board[row][c] == num) return false;
    }

    // 检查列
    for (int r = 0; r < 9; r++) {
      if (board[r][col] == num) return false;
    }

    // 检查 3x3 宫
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[boxRow + i][boxCol + j] == num) return false;
      }
    }

    return true;
  }

  /// 验证整个棋盘是否有效
  static bool isValidBoard(List<List<int>> board) {
    for (int i = 0; i < 9; i++) {
      // 检查每行
      final rowSet = <int>{};
      for (int j = 0; j < 9; j++) {
        final val = board[i][j];
        if (val < 1 || val > 9 || !rowSet.add(val)) return false;
      }

      // 检查每列
      final colSet = <int>{};
      for (int j = 0; j < 9; j++) {
        final val = board[j][i];
        if (val < 1 || val > 9 || !colSet.add(val)) return false;
      }
    }

    // 检查每个 3x3 宫
    for (int boxRow = 0; boxRow < 3; boxRow++) {
      for (int boxCol = 0; boxCol < 3; boxCol++) {
        final boxSet = <int>{};
        for (int i = 0; i < 3; i++) {
          for (int j = 0; j < 3; j++) {
            final val = board[boxRow * 3 + i][boxCol * 3 + j];
            if (val < 1 || val > 9 || !boxSet.add(val)) return false;
          }
        }
      }
    }

    return true;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test test/tools/sudoku/sudoku_validator_test.dart`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add app/lib/tools/sudoku/sudoku_validator.dart app/test/tools/sudoku/sudoku_validator_test.dart
git commit -m "feat(sudoku): add validator for placement and board validation"
```

---

### Task 3: 题目生成算法

**Files:**
- Create: `app/lib/tools/sudoku/sudoku_generator.dart`
- Test: `app/test/tools/sudoku/sudoku_generator_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// app/test/tools/sudoku/sudoku_generator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/tools/sudoku/sudoku_generator.dart';
import 'package:littlegrid/tools/sudoku/sudoku_models.dart';
import 'package:littlegrid/tools/sudoku/sudoku_validator.dart';

void main() {
  group('SudokuGenerator', () {
    group('generateFullBoard', () {
      test('generates a valid complete 9x9 board', () {
        final board = SudokuGenerator.generateFullBoard();
        expect(board.length, 9);
        for (final row in board) {
          expect(row.length, 9);
        }
        expect(SudokuValidator.isValidBoard(board), true);
      });

      test('generates different boards on multiple calls', () {
        final board1 = SudokuGenerator.generateFullBoard();
        final board2 = SudokuGenerator.generateFullBoard();
        // 至少有一个格子不同（极大概率）
        bool hasDifference = false;
        for (int i = 0; i < 9 && !hasDifference; i++) {
          for (int j = 0; j < 9 && !hasDifference; j++) {
            if (board1[i][j] != board2[i][j]) hasDifference = true;
          }
        }
        expect(hasDifference, true);
      });
    });

    group('generate', () {
      test('generates puzzle with correct number of clues for easy', () {
        final puzzle = SudokuGenerator.generate(Difficulty.easy);
        int clueCount = 0;
        for (final row in puzzle.cells) {
          for (final cell in row) {
            if (cell.isFixed) clueCount++;
          }
        }
        expect(clueCount, greaterThanOrEqualTo(36));
        expect(clueCount, lessThanOrEqualTo(40));
      });

      test('generates puzzle with correct number of clues for expert', () {
        final puzzle = SudokuGenerator.generate(Difficulty.expert);
        int clueCount = 0;
        for (final row in puzzle.cells) {
          for (final cell in row) {
            if (cell.isFixed) clueCount++;
          }
        }
        expect(clueCount, greaterThanOrEqualTo(20));
        expect(clueCount, lessThanOrEqualTo(24));
      });

      test('generated puzzle has unique solution', () {
        final puzzle = SudokuGenerator.generate(Difficulty.medium);
        // 转换为整数棋盘
        final board = puzzle.cells.map(
          (row) => row.map((cell) => cell.answer ?? 0).toList()
        ).toList();

        final solutionCount = SudokuGenerator.countSolutions(board, limit: 2);
        expect(solutionCount, 1);
      });
    });

    group('countSolutions', () {
      test('complete board has exactly one solution', () {
        final board = SudokuGenerator.generateFullBoard();
        expect(SudokuGenerator.countSolutions(board, limit: 2), 1);
      });

      test('empty board has many solutions', () {
        final board = List.generate(9, (_) => List.generate(9, (_) => 0));
        final count = SudokuGenerator.countSolutions(board, limit: 10);
        expect(count, greaterThanOrEqualTo(10));
      });
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/tools/sudoku/sudoku_generator_test.dart`
Expected: FAIL with "Error: Could not resolve 'package:littlegrid/tools/sudoku/sudoku_generator.dart'"

- [ ] **Step 3: Write minimal implementation**

```dart
// app/lib/tools/sudoku/sudoku_generator.dart
import 'dart:math';
import 'sudoku_models.dart';
import 'sudoku_validator.dart';

/// 数独题目生成器
class SudokuGenerator {
  static final Random _random = Random();

  /// 生成完整的数独解
  static List<List<int>> generateFullBoard() {
    final board = List.generate(9, (_) => List.generate(9, (_) => 0));
    _fillBoard(board, 0, 0);
    return board;
  }

  /// 回溯填充棋盘
  static bool _fillBoard(List<List<int>> board, int row, int col) {
    if (row == 9) return true;
    if (col == 9) return _fillBoard(board, row + 1, 0);

    final numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]..shuffle(_random);

    for (final num in numbers) {
      if (SudokuValidator.isValidPlacement(board, row, col, num)) {
        board[row][col] = num;
        if (_fillBoard(board, row, col + 1)) return true;
        board[row][col] = 0;
      }
    }

    return false;
  }

  /// 生成数独题目
  static SudokuPuzzle generate(Difficulty difficulty) {
    final solution = generateFullBoard();
    final puzzle = solution.map((row) => row.toList()).toList();

    final clueCount = difficulty.clueCount;
    final cellsToRemove = 81 - clueCount;

    // 获取所有位置并打乱
    final positions = <int>[];
    for (int i = 0; i < 81; i++) {
      positions.add(i);
    }
    positions.shuffle(_random);

    int removed = 0;
    for (final pos in positions) {
      if (removed >= cellsToRemove) break;

      final row = pos ~/ 9;
      final col = pos % 9;

      final backup = puzzle[row][col];
      puzzle[row][col] = 0;

      // 检查唯一解
      if (countSolutions(puzzle.map((r) => r.toList()).toList(), limit: 2) == 1) {
        removed++;
      } else {
        puzzle[row][col] = backup;
      }
    }

    // 转换为 SudokuPuzzle
    final cells = List.generate(9, (r) =>
      List.generate(9, (c) {
        if (puzzle[r][c] != 0) {
          return SudokuCell.fixed(puzzle[r][c]);
        }
        return SudokuCell(answer: solution[r][c]);
      })
    );

    return SudokuPuzzle(cells: cells, solution: solution);
  }

  /// 计算解的数量（最多计算到 limit）
  static int countSolutions(List<List<int>> board, {int limit = 2}) {
    int count = 0;

    void solve(List<List<int>> b) {
      if (count >= limit) return;

      // 找到第一个空格
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          if (b[i][j] == 0) {
            for (int num = 1; num <= 9; num++) {
              if (SudokuValidator.isValidPlacement(b, i, j, num)) {
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
}

/// 数独题目（包含题目和答案）
class SudokuPuzzle {
  final List<List<SudokuCell>> cells;
  final List<List<int>> solution;

  const SudokuPuzzle({required this.cells, required this.solution});
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test test/tools/sudoku/sudoku_generator_test.dart`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add app/lib/tools/sudoku/sudoku_generator.dart app/test/tools/sudoku/sudoku_generator_test.dart
git commit -m "feat(sudoku): add puzzle generator with backtracking algorithm"
```

---

### Task 4: 游戏逻辑

**Files:**
- Create: `app/lib/tools/sudoku/sudoku_logic.dart`
- Test: `app/test/tools/sudoku/sudoku_logic_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// app/test/tools/sudoku/sudoku_logic_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/tools/sudoku/sudoku_logic.dart';
import 'package:littlegrid/tools/sudoku/sudoku_models.dart';

void main() {
  group('SudokuLogic', () {
    test('initial state has empty board', () {
      final logic = SudokuLogic();
      expect(logic.state, isNull);
      expect(logic.isInProgress, false);
    });

    test('startGame creates new puzzle', () {
      final logic = SudokuLogic();
      logic.startGame(Difficulty.easy);

      expect(logic.state, isNotNull);
      expect(logic.isInProgress, true);
      expect(logic.state!.difficulty, Difficulty.easy);

      // 检查提示数
      int fixedCount = 0;
      for (final row in logic.state!.cells) {
        for (final cell in row) {
          if (cell.isFixed) fixedCount++;
        }
      }
      expect(fixedCount, greaterThanOrEqualTo(36));
    });

    test('setValue fills cell and records history', () {
      final logic = SudokuLogic();
      logic.startGame(Difficulty.easy);

      // 找一个空格
      int? emptyRow, emptyCol;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (!logic.state!.cells[r][c].isFixed) {
            emptyRow = r;
            emptyCol = c;
            break;
          }
        }
        if (emptyRow != null) break;
      }

      logic.setValue(emptyRow!, emptyCol!, 5);
      expect(logic.state!.cells[emptyRow][emptyCol].userValue, 5);
      expect(logic.history.length, 1);
    });

    test('setValue does not modify fixed cells', () {
      final logic = SudokuLogic();
      logic.startGame(Difficulty.easy);

      // 找一个固定格
      int? fixedRow, fixedCol;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (logic.state!.cells[r][c].isFixed) {
            fixedRow = r;
            fixedCol = c;
            break;
          }
        }
        if (fixedRow != null) break;
      }

      final originalValue = logic.state!.cells[fixedRow!][fixedCol!].userValue;
      logic.setValue(fixedRow, fixedCol, 9);
      expect(logic.state!.cells[fixedRow][fixedCol].userValue, originalValue);
    });

    test('clearValue removes user value', () {
      final logic = SudokuLogic();
      logic.startGame(Difficulty.easy);

      // 找一个空格并填入
      int? emptyRow, emptyCol;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (!logic.state!.cells[r][c].isFixed) {
            emptyRow = r;
            emptyCol = c;
            break;
          }
        }
        if (emptyRow != null) break;
      }

      logic.setValue(emptyRow!, emptyCol!, 5);
      expect(logic.state!.cells[emptyRow][emptyCol].userValue, 5);

      logic.clearValue(emptyRow, emptyCol);
      expect(logic.state!.cells[emptyRow][emptyCol].userValue, isNull);
    });

    test('undo reverts last move', () {
      final logic = SudokuLogic();
      logic.startGame(Difficulty.easy);

      // 找一个空格
      int? emptyRow, emptyCol;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (!logic.state!.cells[r][c].isFixed) {
            emptyRow = r;
            emptyCol = c;
            break;
          }
        }
        if (emptyRow != null) break;
      }

      logic.setValue(emptyRow!, emptyCol!, 5);
      expect(logic.state!.cells[emptyRow][emptyCol].userValue, 5);

      logic.undo();
      expect(logic.state!.cells[emptyRow][emptyCol].userValue, isNull);
      expect(logic.history.length, 0);
    });

    test('toggleNote adds and removes notes', () {
      final logic = SudokuLogic();
      logic.startGame(Difficulty.easy);

      // 找一个空格
      int? emptyRow, emptyCol;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (!logic.state!.cells[r][c].isFixed) {
            emptyRow = r;
            emptyCol = c;
            break;
          }
        }
        if (emptyRow != null) break;
      }

      logic.toggleNote(emptyRow!, emptyCol!, 3);
      expect(logic.state!.cells[emptyRow][emptyCol].notes.contains(3), true);

      logic.toggleNote(emptyRow, emptyCol, 3);
      expect(logic.state!.cells[emptyRow][emptyCol].notes.contains(3), false);
    });

    test('isComplete returns true when all cells filled correctly', () {
      final logic = SudokuLogic();
      logic.startGame(Difficulty.easy);

      // 填入所有正确答案
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (!logic.state!.cells[r][c].isFixed) {
            logic.setValue(r, c, logic.state!.cells[r][c].answer!);
          }
        }
      }

      expect(logic.isComplete(), true);
    });

    test('getHint fills a random empty cell with correct value', () {
      final logic = SudokuLogic();
      logic.startGame(Difficulty.medium);

      final hint = logic.getHint();
      expect(hint, isNotNull);
      expect(logic.state!.cells[hint!.$1][hint.$2].userValue,
             logic.state!.cells[hint.$1][hint.$2].answer);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/tools/sudoku/sudoku_logic_test.dart`
Expected: FAIL with "Error: Could not resolve 'package:littlegrid/tools/sudoku/sudoku_logic.dart'"

- [ ] **Step 3: Write minimal implementation**

```dart
// app/lib/tools/sudoku/sudoku_logic.dart
import 'dart:math';
import 'sudoku_models.dart';
import 'sudoku_generator.dart';

/// 游戏状态
class SudokuState {
  final List<List<SudokuCell>> cells;
  final Difficulty difficulty;
  final Duration elapsedTime;

  const SudokuState({
    required this.cells,
    required this.difficulty,
    this.elapsedTime = Duration.zero,
  });

  SudokuState copyWith({
    List<List<SudokuCell>>? cells,
    Difficulty? difficulty,
    Duration? elapsedTime,
  }) {
    return SudokuState(
      cells: cells ?? this.cells,
      difficulty: difficulty ?? this.difficulty,
      elapsedTime: elapsedTime ?? this.elapsedTime,
    );
  }
}

/// 数独游戏逻辑
class SudokuLogic {
  SudokuState? _state;
  final List<Move> _history = [];

  SudokuState? get state => _state;
  List<Move> get history => List.unmodifiable(_history);
  bool get isInProgress => _state != null;

  /// 开始新游戏
  void startGame(Difficulty difficulty) {
    final puzzle = SudokuGenerator.generate(difficulty);
    _state = SudokuState(
      cells: puzzle.cells,
      difficulty: difficulty,
    );
    _history.clear();
  }

  /// 设置单元格值
  void setValue(int row, int col, int value) {
    if (_state == null) return;
    final cell = _state!.cells[row][col];
    if (cell.isFixed) return;

    // 记录历史
    _history.add(Move(
      row: row,
      col: col,
      previousValue: cell.userValue,
      newValue: value,
      previousNotes: Set.from(cell.notes),
    ));

    // 更新单元格
    final newCells = _state!.cells.map((r) => r.map((c) => c).toList()).toList();
    newCells[row][col] = cell.copyWith(
      userValue: value,
      clearNotes: true,
    );

    _state = _state!.copyWith(cells: newCells);
  }

  /// 清除单元格值
  void clearValue(int row, int col) {
    if (_state == null) return;
    final cell = _state!.cells[row][col];
    if (cell.isFixed) return;
    if (cell.userValue == null) return;

    // 记录历史
    _history.add(Move(
      row: row,
      col: col,
      previousValue: cell.userValue,
      newValue: null,
      previousNotes: Set.from(cell.notes),
    ));

    // 更新单元格
    final newCells = _state!.cells.map((r) => r.map((c) => c).toList()).toList();
    newCells[row][col] = cell.copyWith(clearUserValue: true);

    _state = _state!.copyWith(cells: newCells);
  }

  /// 切换笔记
  void toggleNote(int row, int col, int value) {
    if (_state == null) return;
    final cell = _state!.cells[row][col];
    if (cell.isFixed || cell.hasValue) return;

    final newNotes = Set<int>.from(cell.notes);
    if (newNotes.contains(value)) {
      newNotes.remove(value);
    } else {
      newNotes.add(value);
    }

    final newCells = _state!.cells.map((r) => r.map((c) => c).toList()).toList();
    newCells[row][col] = cell.copyWith(notes: newNotes);

    _state = _state!.copyWith(cells: newCells);
  }

  /// 撤销
  void undo() {
    if (_history.isEmpty) return;

    final move = _history.removeLast();
    final cell = _state!.cells[move.row][move.col];

    final newCells = _state!.cells.map((r) => r.map((c) => c).toList()).toList();
    newCells[move.row][move.col] = cell.copyWith(
      userValue: move.previousValue,
      notes: move.previousNotes,
    );

    _state = _state!.copyWith(cells: newCells);
  }

  /// 是否完成
  bool isComplete() {
    if (_state == null) return false;

    for (final row in _state!.cells) {
      for (final cell in row) {
        if (cell.userValue != cell.answer) return false;
      }
    }
    return true;
  }

  /// 获取提示（返回提示的坐标）
  (int, int)? getHint() {
    if (_state == null) return null;

    // 收集所有空格
    final emptyCells = <(int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (!_state!.cells[r][c].isFixed && _state!.cells[r][c].userValue == null) {
          emptyCells.add((r, c));
        }
      }
    }

    if (emptyCells.isEmpty) return null;

    // 随机选择一个填入
    final (row, col) = emptyCells[Random().nextInt(emptyCells.length)];
    setValue(row, col, _state!.cells[row][col].answer!);

    return (row, col);
  }

  /// 获取候选数
  Set<int> getCandidates(int row, int col) {
    if (_state == null) return {};
    final cell = _state!.cells[row][col];
    if (cell.hasValue) return {};

    final used = <int>{};

    // 同行
    for (int c = 0; c < 9; c++) {
      final v = _state!.cells[row][c].userValue;
      if (v != null) used.add(v);
    }

    // 同列
    for (int r = 0; r < 9; r++) {
      final v = _state!.cells[r][col].userValue;
      if (v != null) used.add(v);
    }

    // 同宫
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final v = _state!.cells[boxRow + i][boxCol + j].userValue;
        if (v != null) used.add(v);
      }
    }

    return {1, 2, 3, 4, 5, 6, 7, 8, 9}.difference(used);
  }

  /// 更新时间
  void updateElapsedTime(Duration duration) {
    if (_state == null) return;
    _state = _state!.copyWith(elapsedTime: duration);
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test test/tools/sudoku/sudoku_logic_test.dart`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add app/lib/tools/sudoku/sudoku_logic.dart app/test/tools/sudoku/sudoku_logic_test.dart
git commit -m "feat(sudoku): add game logic with history and hint support"
```

---

### Task 5: 本地存储

**Files:**
- Create: `app/lib/tools/sudoku/sudoku_storage.dart`
- Test: `app/test/tools/sudoku/sudoku_storage_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
// app/test/tools/sudoku/sudoku_storage_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:littlegrid/tools/sudoku/sudoku_storage.dart';
import 'package:littlegrid/tools/sudoku/sudoku_models.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SudokuStorage', () {
    group('Settings', () {
      test('loadSettings returns defaults when empty', () async {
        final settings = await SudokuStorage.loadSettings();
        expect(settings.showErrorHighlight, true);
        expect(settings.showCandidates, false);
        expect(settings.autoEliminate, false);
        expect(settings.enableHint, true);
      });

      test('saveSettings and loadSettings work correctly', () async {
        final settings = SudokuSettings(
          showErrorHighlight: false,
          showCandidates: true,
          autoEliminate: true,
          enableHint: false,
        );

        await SudokuStorage.saveSettings(settings);
        final loaded = await SudokuStorage.loadSettings();

        expect(loaded.showErrorHighlight, false);
        expect(loaded.showCandidates, true);
        expect(loaded.autoEliminate, true);
        expect(loaded.enableHint, false);
      });
    });

    group('Best Times', () {
      test('getBestTime returns null when no record', () async {
        final time = await SudokuStorage.getBestTime(Difficulty.easy);
        expect(time, isNull);
      });

      test('saveBestTime and getBestTime work correctly', () async {
        await SudokuStorage.saveBestTime(Difficulty.medium, 300);

        final time = await SudokuStorage.getBestTime(Difficulty.medium);
        expect(time, 300);
      });

      test('saveBestTime only saves if faster', () async {
        await SudokuStorage.saveBestTime(Difficulty.hard, 600);
        await SudokuStorage.saveBestTime(Difficulty.hard, 800); // Slower, should not save

        var time = await SudokuStorage.getBestTime(Difficulty.hard);
        expect(time, 600);

        await SudokuStorage.saveBestTime(Difficulty.hard, 400); // Faster, should save
        time = await SudokuStorage.getBestTime(Difficulty.hard);
        expect(time, 400);
      });

      test('clearAllBestTimes removes all records', () async {
        await SudokuStorage.saveBestTime(Difficulty.easy, 200);
        await SudokuStorage.saveBestTime(Difficulty.medium, 300);
        await SudokuStorage.saveBestTime(Difficulty.hard, 400);
        await SudokuStorage.saveBestTime(Difficulty.expert, 500);

        await SudokuStorage.clearAllBestTimes();

        expect(await SudokuStorage.getBestTime(Difficulty.easy), isNull);
        expect(await SudokuStorage.getBestTime(Difficulty.medium), isNull);
        expect(await SudokuStorage.getBestTime(Difficulty.hard), isNull);
        expect(await SudokuStorage.getBestTime(Difficulty.expert), isNull);
      });
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd app && flutter test test/tools/sudoku/sudoku_storage_test.dart`
Expected: FAIL with "Error: Could not resolve 'package:littlegrid/tools/sudoku/sudoku_storage.dart'"

- [ ] **Step 3: Write minimal implementation**

```dart
// app/lib/tools/sudoku/sudoku_storage.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'sudoku_models.dart';

/// 数独设置
class SudokuSettings {
  final bool showErrorHighlight;
  final bool showCandidates;
  final bool autoEliminate;
  final bool enableHint;

  const SudokuSettings({
    this.showErrorHighlight = true,
    this.showCandidates = false,
    this.autoEliminate = false,
    this.enableHint = true,
  });

  SudokuSettings copyWith({
    bool? showErrorHighlight,
    bool? showCandidates,
    bool? autoEliminate,
    bool? enableHint,
  }) {
    return SudokuSettings(
      showErrorHighlight: showErrorHighlight ?? this.showErrorHighlight,
      showCandidates: showCandidates ?? this.showCandidates,
      autoEliminate: autoEliminate ?? this.autoEliminate,
      enableHint: enableHint ?? this.enableHint,
    );
  }
}

/// 数独本地存储
class SudokuStorage {
  // 设置键名
  static const String _keyShowErrorHighlight = 'sudoku_show_error_highlight';
  static const String _keyShowCandidates = 'sudoku_show_candidates';
  static const String _keyAutoEliminate = 'sudoku_auto_eliminate';
  static const String _keyEnableHint = 'sudoku_enable_hint';

  // 最佳成绩键名
  static const String _keyBestEasy = 'sudoku_best_easy';
  static const String _keyBestMedium = 'sudoku_best_medium';
  static const String _keyBestHard = 'sudoku_best_hard';
  static const String _keyBestExpert = 'sudoku_best_expert';

  /// 加载设置
  static Future<SudokuSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return SudokuSettings(
      showErrorHighlight: prefs.getBool(_keyShowErrorHighlight) ?? true,
      showCandidates: prefs.getBool(_keyShowCandidates) ?? false,
      autoEliminate: prefs.getBool(_keyAutoEliminate) ?? false,
      enableHint: prefs.getBool(_keyEnableHint) ?? true,
    );
  }

  /// 保存设置
  static Future<void> saveSettings(SudokuSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_keyShowErrorHighlight, settings.showErrorHighlight),
      prefs.setBool(_keyShowCandidates, settings.showCandidates),
      prefs.setBool(_keyAutoEliminate, settings.autoEliminate),
      prefs.setBool(_keyEnableHint, settings.enableHint),
    ]);
  }

  /// 获取最佳成绩（秒数）
  static Future<int?> getBestTime(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getBestTimeKey(difficulty);
    return prefs.getInt(key);
  }

  /// 保存最佳成绩
  static Future<void> saveBestTime(Difficulty difficulty, int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getBestTimeKey(difficulty);
    final current = prefs.getInt(key);

    // 只在更快时保存
    if (current == null || seconds < current) {
      await prefs.setInt(key, seconds);
    }
  }

  /// 清除所有最佳成绩
  static Future<void> clearAllBestTimes() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_keyBestEasy),
      prefs.remove(_keyBestMedium),
      prefs.remove(_keyBestHard),
      prefs.remove(_keyBestExpert),
    ]);
  }

  static String _getBestTimeKey(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return _keyBestEasy;
      case Difficulty.medium:
        return _keyBestMedium;
      case Difficulty.hard:
        return _keyBestHard;
      case Difficulty.expert:
        return _keyBestExpert;
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd app && flutter test test/tools/sudoku/sudoku_storage_test.dart`
Expected: All tests PASS

- [ ] **Step 5: Commit**

```bash
git add app/lib/tools/sudoku/sudoku_storage.dart app/test/tools/sudoku/sudoku_storage_test.dart
git commit -m "feat(sudoku): add local storage for settings and best times"
```

---

### Task 6: 棋盘绘制组件

**Files:**
- Create: `app/lib/tools/sudoku/sudoku_board.dart`
- Modify: `app/lib/tools/sudoku/sudoku_models.dart` (添加 SudokuSettings 依赖)

- [ ] **Step 1: Write the widget**

```dart
// app/lib/tools/sudoku/sudoku_board.dart
import 'package:flutter/material.dart';
import 'sudoku_logic.dart';
import 'sudoku_storage.dart';

/// 数独棋盘组件
class SudokuBoard extends StatelessWidget {
  final SudokuState state;
  final int? selectedRow;
  final int? selectedCol;
  final SudokuSettings settings;
  final void Function(int row, int col) onCellTap;

  const SudokuBoard({
    super.key,
    required this.state,
    this.selectedRow,
    this.selectedCol,
    required this.settings,
    required this.onCellTap,
  });

  static const double cellSize = 44.0;
  static const double boardSize = cellSize * 9;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: boardSize,
      height: boardSize,
      child: CustomPaint(
        painter: _BoardPainter(
          state: state,
          selectedRow: selectedRow,
          selectedCol: selectedCol,
          settings: settings,
        ),
        child: GestureDetector(
          onTapUp: (details) {
            final col = (details.localPosition.dx / cellSize).floor();
            final row = (details.localPosition.dy / cellSize).floor();
            if (row >= 0 && row < 9 && col >= 0 && col < 9) {
              onCellTap(row, col);
            }
          },
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  final SudokuState state;
  final int? selectedRow;
  final int? selectedCol;
  final SudokuSettings settings;

  _BoardPainter({
    required this.state,
    this.selectedRow,
    this.selectedCol,
    required this.settings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawHighlight(canvas, size);
    _drawGrid(canvas, size);
    _drawCells(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );
  }

  void _drawHighlight(Canvas canvas, Size size) {
    if (selectedRow == null || selectedCol == null) return;

    final highlightPaint = Paint()..color = Colors.blue.withValues(alpha: 0.1);

    // 高亮同行
    for (int c = 0; c < 9; c++) {
      canvas.drawRect(
        Rect.fromLTWH(c * SudokuBoard.cellSize, 0, SudokuBoard.cellSize, size.height),
        highlightPaint,
      );
    }

    // 高亮同列
    for (int r = 0; r < 9; r++) {
      canvas.drawRect(
        Rect.fromLTWH(0, r * SudokuBoard.cellSize, size.width, SudokuBoard.cellSize),
        highlightPaint,
      );
    }

    // 高亮同宫
    final boxRow = (selectedRow! ~/ 3) * 3;
    final boxCol = (selectedCol! ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        canvas.drawRect(
          Rect.fromLTWH(
            (boxCol + j) * SudokuBoard.cellSize,
            (boxRow + i) * SudokuBoard.cellSize,
            SudokuBoard.cellSize,
            SudokuBoard.cellSize,
          ),
          highlightPaint,
        );
      }
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final thinPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    final thickPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    // 细线
    for (int i = 0; i <= 9; i++) {
      final offset = i * SudokuBoard.cellSize;
      if (i % 3 != 0) {
        canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), thinPaint);
        canvas.drawLine(Offset(0, offset), Offset(size.width, offset), thinPaint);
      }
    }

    // 粗线（宫边界）
    for (int i = 0; i <= 9; i += 3) {
      final offset = i * SudokuBoard.cellSize;
      canvas.drawLine(Offset(offset, 0), Offset(offset, size.height), thickPaint);
      canvas.drawLine(Offset(0, offset), Offset(size.width, offset), thickPaint);
    }
  }

  void _drawCells(Canvas canvas, Size size) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        _drawCell(canvas, row, col);
      }
    }
  }

  void _drawCell(Canvas canvas, int row, int col) {
    final cell = state.cells[row][col];
    final x = col * SudokuBoard.cellSize;
    final y = row * SudokuBoard.cellSize;
    final center = Offset(x + SudokuBoard.cellSize / 2, y + SudokuBoard.cellSize / 2);

    // 选中边框
    if (row == selectedRow && col == selectedCol) {
      canvas.drawRect(
        Rect.fromLTWH(x + 1, y + 1, SudokuBoard.cellSize - 2, SudokuBoard.cellSize - 2),
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    // 错误标记
    if (settings.showErrorHighlight && cell.isCorrect == false) {
      canvas.drawRect(
        Rect.fromLTWH(x + 2, y + 2, SudokuBoard.cellSize - 4, SudokuBoard.cellSize - 4),
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // 数字或候选数
    if (cell.hasValue) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: cell.userValue.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: cell.isFixed ? Colors.black : Colors.blue,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
      );
    } else if (settings.showCandidates && cell.notes.isNotEmpty) {
      _drawNotes(canvas, x, y, cell.notes);
    }
  }

  void _drawNotes(Canvas canvas, double x, double y, Set<int> notes) {
    final noteSize = SudokuBoard.cellSize / 3;

    for (final note in notes) {
      final noteRow = (note - 1) ~/ 3;
      final noteCol = (note - 1) % 3;

      final textPainter = TextPainter(
        text: TextSpan(
          text: note.toString(),
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final noteX = x + noteCol * noteSize + (noteSize - textPainter.width) / 2;
      final noteY = y + noteRow * noteSize + (noteSize - textPainter.height) / 2;

      textPainter.paint(canvas, Offset(noteX, noteY));
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) {
    return state != oldDelegate.state ||
        selectedRow != oldDelegate.selectedRow ||
        selectedCol != oldDelegate.selectedCol ||
        settings != oldDelegate.settings;
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `cd app && flutter analyze lib/tools/sudoku/sudoku_board.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add app/lib/tools/sudoku/sudoku_board.dart
git commit -m "feat(sudoku): add board widget with CustomPaint"
```

---

### Task 7: 设置页面

**Files:**
- Create: `app/lib/tools/sudoku/sudoku_settings_page.dart`

- [ ] **Step 1: Write the widget**

```dart
// app/lib/tools/sudoku/sudoku_settings_page.dart
import 'package:flutter/material.dart';
import 'sudoku_storage.dart';
import 'sudoku_models.dart';

/// 数独设置页面
class SudokuSettingsPage extends StatefulWidget {
  const SudokuSettingsPage({super.key});

  @override
  State<SudokuSettingsPage> createState() => _SudokuSettingsPageState();
}

class _SudokuSettingsPageState extends State<SudokuSettingsPage> {
  late SudokuSettings _settings;
  Map<Difficulty, int?> _bestTimes = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _settings = await SudokuStorage.loadSettings();
    for (final difficulty in Difficulty.values) {
      _bestTimes[difficulty] = await SudokuStorage.getBestTime(difficulty);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateSetting(bool Function(SudokuSettings) getter, bool value) async {
    final newSettings = _settings.copyWith(
      showErrorHighlight: getter(_settings) == _settings.showErrorHighlight
          ? (_settings.showErrorHighlight == value ? null : value)
          : null,
      showCandidates: getter(_settings) == _settings.showCandidates
          ? (_settings.showCandidates == value ? null : value)
          : null,
      autoEliminate: getter(_settings) == _settings.autoEliminate
          ? (_settings.autoEliminate == value ? null : value)
          : null,
      enableHint: getter(_settings) == _settings.enableHint
          ? (_settings.enableHint == value ? null : value)
          : null,
    );

    // 根据调用位置更新对应字段
    SudokuSettings updatedSettings;
    if (getter(_settings) == _settings.showErrorHighlight) {
      updatedSettings = _settings.copyWith(showErrorHighlight: value);
    } else if (getter(_settings) == _settings.showCandidates) {
      updatedSettings = _settings.copyWith(showCandidates: value);
    } else if (getter(_settings) == _settings.autoEliminate) {
      updatedSettings = _settings.copyWith(autoEliminate: value);
    } else {
      updatedSettings = _settings.copyWith(enableHint: value);
    }

    await SudokuStorage.saveSettings(updatedSettings);
    setState(() => _settings = updatedSettings);
  }

  Future<void> _clearAllRecords() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('确定要清除所有最佳成绩吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SudokuStorage.clearAllBestTimes();
      setState(() {
        for (final difficulty in Difficulty.values) {
          _bestTimes[difficulty] = null;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('辅助功能'),
          _buildSwitchTile(
            title: '错误标记',
            subtitle: '填入错误数字时，格子显示红色边框',
            value: _settings.showErrorHighlight,
            onChanged: (v) => _updateSetting((s) => s.showErrorHighlight, v),
          ),
          _buildSwitchTile(
            title: '候选数提示',
            subtitle: '在空白格内显示可能的数字（小字）',
            value: _settings.showCandidates,
            onChanged: (v) => _updateSetting((s) => s.showCandidates, v),
          ),
          _buildSwitchTile(
            title: '自动排除',
            subtitle: '自动移除已被同行/列/宫占用的候选数',
            value: _settings.autoEliminate,
            onChanged: (v) => _updateSetting((s) => s.autoEliminate, v),
          ),
          _buildSwitchTile(
            title: '提示功能',
            subtitle: '点击提示按钮，自动填入一个正确数字',
            value: _settings.enableHint,
            onChanged: (v) => _updateSetting((s) => s.enableHint, v),
          ),
          const Divider(height: 32),
          _buildSectionHeader('游戏记录'),
          ...Difficulty.values.map((d) => _buildBestTimeTile(d)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              onPressed: _clearAllRecords,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('清除所有记录'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildBestTimeTile(Difficulty difficulty) {
    final time = _bestTimes[difficulty];
    final timeStr = time != null ? _formatTime(time) : '--:--';

    return ListTile(
      title: Text(_difficultyName(difficulty)),
      trailing: Text(
        '最佳: $timeStr',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  String _difficultyName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '简单';
      case Difficulty.medium:
        return '中等';
      case Difficulty.hard:
        return '困难';
      case Difficulty.expert:
        return '专家';
    }
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `cd app && flutter analyze lib/tools/sudoku/sudoku_settings_page.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add app/lib/tools/sudoku/sudoku_settings_page.dart
git commit -m "feat(sudoku): add settings page with toggle switches and best times"
```

---

### Task 8: 主页面

**Files:**
- Create: `app/lib/tools/sudoku/sudoku_page.dart`

- [ ] **Step 1: Write the widget**

```dart
// app/lib/tools/sudoku/sudoku_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'sudoku_logic.dart';
import 'sudoku_models.dart';
import 'sudoku_board.dart';
import 'sudoku_storage.dart';
import 'sudoku_settings_page.dart';

class SudokuPage extends StatefulWidget {
  const SudokuPage({super.key});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  late SudokuLogic _logic;
  int? _selectedRow;
  int? _selectedCol;
  bool _noteMode = false;
  SudokuSettings _settings = const SudokuSettings();

  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _logic = SudokuLogic();
    _loadSettings();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    _settings = await SudokuStorage.loadSettings();
    setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    _elapsed = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _elapsed += const Duration(seconds: 1);
        _logic.updateElapsedTime(_elapsed);
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _startNewGame(Difficulty difficulty) {
    setState(() {
      _logic.startGame(difficulty);
      _selectedRow = null;
      _selectedCol = null;
      _noteMode = false;
    });
    _startTimer();
  }

  void _selectCell(int row, int col) {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
    });
  }

  void _inputNumber(int num) {
    if (_selectedRow == null || _selectedCol == null) return;
    if (_logic.state == null) return;

    final cell = _logic.state!.cells[_selectedRow!][_selectedCol!];
    if (cell.isFixed) return;

    setState(() {
      if (_noteMode) {
        _logic.toggleNote(_selectedRow!, _selectedCol!, num);
      } else {
        _logic.setValue(_selectedRow!, _selectedCol!, num);

        // 自动排除候选数
        if (_settings.autoEliminate) {
          _autoEliminate(_selectedRow!, _selectedCol!, num);
        }

        // 检查是否完成
        if (_logic.isComplete()) {
          _stopTimer();
          _showCompleteDialog();
        }
      }
    });
  }

  void _autoEliminate(int row, int col, int num) {
    // 移除同行、同列、同宫中的候选数
    for (int c = 0; c < 9; c++) {
      if (c != col) {
        _removeNote(row, c, num);
      }
    }
    for (int r = 0; r < 9; r++) {
      if (r != row) {
        _removeNote(r, col, num);
      }
    }
    final boxRow = (row ~/ 3) * 3;
    final boxCol = (col ~/ 3) * 3;
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        final r = boxRow + i;
        final c = boxCol + j;
        if (r != row || c != col) {
          _removeNote(r, c, num);
        }
      }
    }
  }

  void _removeNote(int row, int col, int num) {
    final cell = _logic.state!.cells[row][col];
    if (cell.notes.contains(num)) {
      _logic.toggleNote(row, col, num);
    }
  }

  void _clearCell() {
    if (_selectedRow == null || _selectedCol == null) return;
    setState(() {
      _logic.clearValue(_selectedRow!, _selectedCol!);
    });
  }

  void _undo() {
    setState(() {
      _logic.undo();
    });
  }

  void _getHint() {
    if (!_settings.enableHint) return;
    setState(() {
      final hint = _logic.getHint();
      if (hint != null) {
        _selectedRow = hint.$1;
        _selectedCol = hint.$2;
      }
    });
  }

  void _showCompleteDialog() async {
    final seconds = _elapsed.inSeconds;
    await SudokuStorage.saveBestTime(_logic.state!.difficulty, seconds);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('恭喜完成!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('用时: ${_formatTime(seconds)}'),
            const SizedBox(height: 8),
            Text('难度: ${_difficultyName(_logic.state!.difficulty)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDifficultyDialog();
            },
            child: const Text('新游戏'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择难度'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: Difficulty.values.map((d) => ListTile(
            title: Text(_difficultyName(d)),
            onTap: () {
              Navigator.pop(context);
              _startNewGame(d);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SudokuSettingsPage()),
    );
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数独'),
        actions: [
          if (_logic.isInProgress)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _formatTime(_elapsed.inSeconds),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: _logic.state == null
          ? _buildWelcomeScreen()
          : _buildGameScreen(),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.grid_3x3, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text('数独', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 48),
          const Text('选择难度开始游戏', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 24),
          ...Difficulty.values.map((d) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _startNewGame(d),
                child: Text(_difficultyName(d)),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        // 棋盘
        Expanded(
          child: Center(
            child: SudokuBoard(
              state: _logic.state!,
              selectedRow: _selectedRow,
              selectedCol: _selectedCol,
              settings: _settings,
              onCellTap: _selectCell,
            ),
          ),
        ),
        // 数字键盘
        _buildNumberKeyboard(),
        // 操作按钮
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildNumberKeyboard() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(9, (i) => _buildNumberButton(i + 1)),
      ),
    );
  }

  Widget _buildNumberButton(int num) {
    return InkWell(
      onTap: () => _inputNumber(num),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 44,
        alignment: Alignment.center,
        child: Text(
          num.toString(),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton('清除', Icons.clear, _clearCell),
          _buildActionButton(
            _noteMode ? '笔记中' : '笔记',
            Icons.edit,
            () => setState(() => _noteMode = !_noteMode),
            isActive: _noteMode,
          ),
          if (_settings.enableHint)
            _buildActionButton('提示', Icons.lightbulb_outline, _getHint),
          _buildActionButton('撤销', Icons.undo, _undo, isEnabled: _logic.history.isNotEmpty),
          _buildActionButton('新游戏', Icons.refresh, _showDifficultyDialog),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    bool isActive = false,
    bool isEnabled = true,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon),
          onPressed: isEnabled ? onPressed : null,
          color: isActive ? Colors.blue : null,
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: isActive ? Colors.blue : null),
        ),
      ],
    );
  }

  String _difficultyName(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return '简单';
      case Difficulty.medium:
        return '中等';
      case Difficulty.hard:
        return '困难';
      case Difficulty.expert:
        return '专家';
    }
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **Step 2: Verify it compiles**

Run: `cd app && flutter analyze lib/tools/sudoku/sudoku_page.dart`
Expected: No issues found

- [ ] **Step 3: Commit**

```bash
git add app/lib/tools/sudoku/sudoku_page.dart
git commit -m "feat(sudoku): add main game page with timer and controls"
```

---

### Task 9: 工具注册

**Files:**
- Create: `app/lib/tools/sudoku/sudoku_tool.dart`
- Modify: `app/lib/main.dart`

- [ ] **Step 1: Write SudokuTool**

```dart
// app/lib/tools/sudoku/sudoku_tool.dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'sudoku_page.dart';

class SudokuTool implements ToolModule {
  @override
  String get id => 'sudoku';

  @override
  String get name => '数独';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.grid_3x3;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const SudokuPage();
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

- [ ] **Step 2: Modify main.dart to register SudokuTool**

```dart
// 在 main.dart 顶部添加导入
import 'tools/sudoku/sudoku_tool.dart';

// 在 main() 函数中添加注册
ToolRegistry.register(SudokuTool());
```

- [ ] **Step 3: Verify it compiles**

Run: `cd app && flutter analyze lib/main.dart lib/tools/sudoku/sudoku_tool.dart`
Expected: No issues found

- [ ] **Step 4: Commit**

```bash
git add app/lib/tools/sudoku/sudoku_tool.dart app/lib/main.dart
git commit -m "feat(sudoku): register sudoku tool in app"
```

---

### Task 10: 最终测试与验证

- [ ] **Step 1: Run all tests**

Run: `cd app && flutter test test/tools/sudoku/`
Expected: All tests PASS

- [ ] **Step 2: Run full test suite**

Run: `cd app && flutter test`
Expected: All tests PASS

- [ ] **Step 3: Build and run app**

Run: `cd app && flutter run`
Expected: App launches, sudoku tool appears in game category

- [ ] **Step 4: Final commit if needed**

```bash
git status
# If any uncommitted changes:
git add -A
git commit -m "feat(sudoku): complete sudoku feature implementation"
```

---

## 验收清单

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