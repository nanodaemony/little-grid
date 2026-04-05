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