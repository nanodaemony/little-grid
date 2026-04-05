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

      test('generated puzzle has unique solution', () {
        final puzzle = SudokuGenerator.generate(Difficulty.medium);
        final board = puzzle.cells.map(
          (row) => row.map((cell) => cell.answer ?? 0).toList()
        ).toList();
        final solutionCount = SudokuGenerator.countSolutions(board, limit: 2);
        expect(solutionCount, 1);
      });
    });
  });
}