// app/test/tools/sudoku/sudoku_logic_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/tools/sudoku/sudoku_logic.dart';
import 'package:littlegrid/tools/sudoku/sudoku_models.dart';

void main() {
  group('SudokuLogic', () {
    late SudokuLogic logic;

    setUp(() {
      logic = SudokuLogic();
    });

    test('initial state is null', () {
      expect(logic.state, isNull);
      expect(logic.isInProgress, false);
      expect(logic.history.isEmpty, true);
    });

    test('startGame creates puzzle', () {
      logic.startGame(Difficulty.easy);

      expect(logic.state, isNotNull);
      expect(logic.isInProgress, true);
      expect(logic.state!.cells.length, 9);
      expect(logic.state!.difficulty, Difficulty.easy);
      expect(logic.state!.elapsedTime, Duration.zero);
      expect(logic.history.isEmpty, true);
    });

    test('setValue fills cell and records history', () {
      logic.startGame(Difficulty.easy);

      // Find an empty cell (not fixed)
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

      expect(emptyRow, isNotNull);
      final cell = logic.state!.cells[emptyRow!][emptyCol!];
      final answer = cell.answer!;

      logic.setValue(emptyRow, emptyCol, answer);

      expect(logic.state!.cells[emptyRow][emptyCol].userValue, answer);
      expect(logic.history.length, 1);
      expect(logic.history[0].row, emptyRow);
      expect(logic.history[0].col, emptyCol);
      expect(logic.history[0].newValue, answer);
    });

    test('setValue does not modify fixed cells', () {
      logic.startGame(Difficulty.easy);

      // Find a fixed cell
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

      expect(fixedRow, isNotNull);
      final originalValue = logic.state!.cells[fixedRow!][fixedCol!].answer;

      logic.setValue(fixedRow, fixedCol, 9);

      // Should remain unchanged
      expect(logic.state!.cells[fixedRow][fixedCol].userValue, isNull);
      expect(logic.history.isEmpty, true);
    });

    test('clearValue removes value', () {
      logic.startGame(Difficulty.easy);

      // Find an empty cell and set a value
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
      expect(logic.history.length, 2);
    });

    test('undo reverts move', () {
      logic.startGame(Difficulty.easy);

      // Find an empty cell
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

      final answer = logic.state!.cells[emptyRow!][emptyCol!].answer!;

      logic.setValue(emptyRow, emptyCol, answer);
      expect(logic.state!.cells[emptyRow][emptyCol].userValue, answer);
      expect(logic.history.length, 1);

      logic.undo();
      expect(logic.state!.cells[emptyRow][emptyCol].userValue, isNull);
      expect(logic.history.isEmpty, true);
    });

    test('toggleNote adds and removes notes', () {
      logic.startGame(Difficulty.easy);

      // Find an empty cell
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

      // Add note
      logic.toggleNote(emptyRow!, emptyCol!, 3);
      expect(logic.state!.cells[emptyRow][emptyCol].notes.contains(3), true);

      // Add another note
      logic.toggleNote(emptyRow, emptyCol, 5);
      expect(logic.state!.cells[emptyRow][emptyCol].notes.contains(3), true);
      expect(logic.state!.cells[emptyRow][emptyCol].notes.contains(5), true);

      // Remove note
      logic.toggleNote(emptyRow, emptyCol, 3);
      expect(logic.state!.cells[emptyRow][emptyCol].notes.contains(3), false);
      expect(logic.state!.cells[emptyRow][emptyCol].notes.contains(5), true);
    });

    test('toggleNote does not work on cells with values', () {
      logic.startGame(Difficulty.easy);

      // Find an empty cell
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

      // Set a value
      logic.setValue(emptyRow!, emptyCol!, 5);

      // Try to add note - should not work
      logic.toggleNote(emptyRow, emptyCol, 3);
      expect(logic.state!.cells[emptyRow][emptyCol].notes.contains(3), false);
    });

    test('isComplete returns true when all cells filled correctly', () {
      logic.startGame(Difficulty.easy);

      // Fill all empty cells with correct answers
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          final cell = logic.state!.cells[r][c];
          if (!cell.isFixed && cell.userValue == null) {
            logic.setValue(r, c, cell.answer!);
          }
        }
      }

      expect(logic.isComplete(), true);
    });

    test('isComplete returns false when cells are wrong or empty', () {
      logic.startGame(Difficulty.easy);
      expect(logic.isComplete(), false);

      // Fill one cell with wrong value
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (!logic.state!.cells[r][c].isFixed) {
            logic.setValue(r, c, 1); // Wrong value
            break;
          }
        }
        break;
      }

      expect(logic.isComplete(), false);
    });

    test('getHint fills empty cell', () {
      logic.startGame(Difficulty.easy);

      // Find an empty cell
      int emptyCount = 0;
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (!logic.state!.cells[r][c].isFixed) {
            emptyCount++;
          }
        }
      }

      expect(emptyCount, greaterThan(0));

      final result = logic.getHint();
      expect(result, isNotNull);

      final (row, col) = result!;
      final cell = logic.state!.cells[row][col];
      expect(cell.userValue, cell.answer);

      // Hint should be recorded in history
      expect(logic.history.length, 1);
    });

    test('getHint returns null when no empty cells', () {
      logic.startGame(Difficulty.easy);

      // Fill all cells
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          final cell = logic.state!.cells[r][c];
          if (!cell.isFixed) {
            logic.setValue(r, c, cell.answer!);
          }
        }
      }

      final result = logic.getHint();
      expect(result, isNull);
    });

    test('getCandidates returns valid candidates', () {
      logic.startGame(Difficulty.easy);

      // Find an empty cell
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

      final candidates = logic.getCandidates(emptyRow!, emptyCol!);

      // Should include the answer
      expect(candidates.contains(logic.state!.cells[emptyRow][emptyCol].answer), true);
    });

    test('getCandidates returns empty for cell with value', () {
      logic.startGame(Difficulty.easy);

      // Find an empty cell and set a value
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
      final candidates = logic.getCandidates(emptyRow, emptyCol);
      expect(candidates.isEmpty, true);
    });

    test('updateElapsedTime updates state', () {
      logic.startGame(Difficulty.easy);

      const duration = Duration(minutes: 5, seconds: 30);
      logic.updateElapsedTime(duration);

      expect(logic.state!.elapsedTime, duration);
    });

    test('startGame clears history', () {
      logic.startGame(Difficulty.easy);

      // Make some moves
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (!logic.state!.cells[r][c].isFixed) {
            logic.setValue(r, c, logic.state!.cells[r][c].answer!);
            break;
          }
        }
        break;
      }

      expect(logic.history.length, greaterThan(0));

      // Start new game
      logic.startGame(Difficulty.medium);
      expect(logic.history.isEmpty, true);
      expect(logic.state!.difficulty, Difficulty.medium);
    });
  });

  group('SudokuState', () {
    test('copyWith creates new state with updated values', () {
      final cells = List.generate(9, (_) =>
        List.generate(9, (_) => SudokuCell.empty()));

      final state = SudokuState(
        cells: cells,
        difficulty: Difficulty.easy,
        elapsedTime: Duration.zero,
      );

      final newState = state.copyWith(
        elapsedTime: const Duration(minutes: 1),
      );

      expect(newState.elapsedTime, const Duration(minutes: 1));
      expect(newState.difficulty, Difficulty.easy);
      expect(newState.cells, cells);
    });
  });
}