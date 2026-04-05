// app/lib/tools/sudoku/sudoku_generator.dart
import 'dart:math';
import 'sudoku_models.dart';
import 'sudoku_validator.dart';

class SudokuGenerator {
  static final Random _random = Random();

  static List<List<int>> generateFullBoard() {
    final board = List.generate(9, (_) => List.generate(9, (_) => 0));
    _fillBoard(board, 0, 0);
    return board;
  }

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

  static SudokuPuzzle generate(Difficulty difficulty) {
    final solution = generateFullBoard();
    final puzzle = solution.map((row) => row.toList()).toList();

    final clueCount = difficulty.clueCount;
    final cellsToRemove = 81 - clueCount;

    final positions = List.generate(81, (i) => i)..shuffle(_random);

    int removed = 0;
    for (final pos in positions) {
      if (removed >= cellsToRemove) break;

      final row = pos ~/ 9;
      final col = pos % 9;

      final backup = puzzle[row][col];
      puzzle[row][col] = 0;

      if (countSolutions(puzzle.map((r) => r.toList()).toList(), limit: 2) == 1) {
        removed++;
      } else {
        puzzle[row][col] = backup;
      }
    }

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

  static int countSolutions(List<List<int>> board, {int limit = 2}) {
    int count = 0;

    void solve(List<List<int>> b) {
      if (count >= limit) return;

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

class SudokuPuzzle {
  final List<List<SudokuCell>> cells;
  final List<List<int>> solution;

  const SudokuPuzzle({required this.cells, required this.solution});
}