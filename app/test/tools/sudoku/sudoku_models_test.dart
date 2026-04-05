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