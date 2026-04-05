// app/lib/tools/sudoku/sudoku_logic.dart
import 'dart:math';
import 'sudoku_models.dart';
import 'sudoku_generator.dart';

/// 数独游戏状态
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

  /// 当前游戏状态
  SudokuState? get state => _state;

  /// 操作历史（只读）
  List<Move> get history => List.unmodifiable(_history);

  /// 游戏是否进行中
  bool get isInProgress => _state != null;

  /// 开始新游戏
  void startGame(Difficulty difficulty) {
    final puzzle = SudokuGenerator.generate(difficulty);
    _state = SudokuState(cells: puzzle.cells, difficulty: difficulty);
    _history.clear();
  }

  /// 设置单元格的值
  void setValue(int row, int col, int value) {
    if (_state == null) return;
    final cell = _state!.cells[row][col];
    if (cell.isFixed) return;

    _history.add(Move(
      row: row,
      col: col,
      previousValue: cell.userValue,
      newValue: value,
      previousNotes: Set.from(cell.notes),
    ));

    final newCells = _state!.cells.map((r) => r.map((c) => c).toList()).toList();
    newCells[row][col] = cell.copyWith(userValue: value, clearNotes: true);
    _state = _state!.copyWith(cells: newCells);
  }

  /// 清除单元格的值
  void clearValue(int row, int col) {
    if (_state == null) return;
    final cell = _state!.cells[row][col];
    if (cell.isFixed || cell.userValue == null) return;

    _history.add(Move(
      row: row,
      col: col,
      previousValue: cell.userValue,
      newValue: null,
      previousNotes: Set.from(cell.notes),
    ));

    final newCells = _state!.cells.map((r) => r.map((c) => c).toList()).toList();
    newCells[row][col] = cell.copyWith(clearUserValue: true);
    _state = _state!.copyWith(cells: newCells);
  }

  /// 切换笔记（候选数）
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

  /// 撤销上一步操作
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

  /// 检查游戏是否完成（所有单元格填写正确）
  bool isComplete() {
    if (_state == null) return false;
    for (final row in _state!.cells) {
      for (final cell in row) {
        if (cell.userValue != cell.answer) return false;
      }
    }
    return true;
  }

  /// 获取提示：填充一个随机空单元格
  (int, int)? getHint() {
    if (_state == null) return null;

    final emptyCells = <(int, int)>[];
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (!_state!.cells[r][c].isFixed && _state!.cells[r][c].userValue == null) {
          emptyCells.add((r, c));
        }
      }
    }

    if (emptyCells.isEmpty) return null;

    final (row, col) = emptyCells[Random().nextInt(emptyCells.length)];
    setValue(row, col, _state!.cells[row][col].answer!);
    return (row, col);
  }

  /// 获取单元格的候选数
  Set<int> getCandidates(int row, int col) {
    if (_state == null) return {};
    final cell = _state!.cells[row][col];
    if (cell.hasValue) return {};

    final used = <int>{};
    // 检查同行
    for (int c = 0; c < 9; c++) {
      final v = _state!.cells[row][c].userValue;
      if (v != null) used.add(v);
    }
    // 检查同列
    for (int r = 0; r < 9; r++) {
      final v = _state!.cells[r][col].userValue;
      if (v != null) used.add(v);
    }
    // 检查同宫
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

  /// 更新游戏时间
  void updateElapsedTime(Duration duration) {
    if (_state == null) return;
    _state = _state!.copyWith(elapsedTime: duration);
  }

  /// 重置游戏
  void reset() {
    _state = null;
    _history.clear();
  }
}