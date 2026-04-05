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