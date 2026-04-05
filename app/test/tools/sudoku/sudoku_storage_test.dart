import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:littlegrid/tools/sudoku/sudoku_models.dart';
import 'package:littlegrid/tools/sudoku/sudoku_storage.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SudokuSettings', () {
    test('has correct default values', () {
      const settings = SudokuSettings();
      expect(settings.showErrorHighlight, true);
      expect(settings.showCandidates, false);
      expect(settings.autoEliminate, false);
      expect(settings.enableHint, true);
    });

    test('copyWith modifies specified values', () {
      const settings = SudokuSettings();
      final modified = settings.copyWith(
        showErrorHighlight: false,
        showCandidates: true,
      );
      expect(modified.showErrorHighlight, false);
      expect(modified.showCandidates, true);
      expect(modified.autoEliminate, false);
      expect(modified.enableHint, true);
    });
  });

  group('SudokuStorage - Settings', () {
    test('loadSettings returns defaults when empty', () async {
      final settings = await SudokuStorage.loadSettings();
      expect(settings.showErrorHighlight, true);
      expect(settings.showCandidates, false);
      expect(settings.autoEliminate, false);
      expect(settings.enableHint, true);
    });

    test('saveSettings and loadSettings work correctly', () async {
      final settings = const SudokuSettings(
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

  group('SudokuStorage - Best Times', () {
    test('getBestTime returns null when no record', () async {
      for (final difficulty in Difficulty.values) {
        final time = await SudokuStorage.getBestTime(difficulty);
        expect(time, isNull);
      }
    });

    test('saveBestTime and getBestTime work correctly', () async {
      await SudokuStorage.saveBestTime(Difficulty.easy, 300);
      final time = await SudokuStorage.getBestTime(Difficulty.easy);
      expect(time, 300);
    });

    test('saveBestTime only saves if faster', () async {
      // Save initial time
      await SudokuStorage.saveBestTime(Difficulty.medium, 600);
      expect(await SudokuStorage.getBestTime(Difficulty.medium), 600);

      // Try to save slower time - should not update
      await SudokuStorage.saveBestTime(Difficulty.medium, 900);
      expect(await SudokuStorage.getBestTime(Difficulty.medium), 600);

      // Save faster time - should update
      await SudokuStorage.saveBestTime(Difficulty.medium, 400);
      expect(await SudokuStorage.getBestTime(Difficulty.medium), 400);
    });

    test('clearAllBestTimes removes all records', () async {
      // Save times for all difficulties
      await SudokuStorage.saveBestTime(Difficulty.easy, 300);
      await SudokuStorage.saveBestTime(Difficulty.medium, 600);
      await SudokuStorage.saveBestTime(Difficulty.hard, 900);
      await SudokuStorage.saveBestTime(Difficulty.expert, 1200);

      // Clear all
      await SudokuStorage.clearAllBestTimes();

      // Verify all are null
      for (final difficulty in Difficulty.values) {
        final time = await SudokuStorage.getBestTime(difficulty);
        expect(time, isNull);
      }
    });
  });
}