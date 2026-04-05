import 'package:shared_preferences/shared_preferences.dart';
import 'sudoku_models.dart';

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

class SudokuStorage {
  static const String _keyShowErrorHighlight = 'sudoku_show_error_highlight';
  static const String _keyShowCandidates = 'sudoku_show_candidates';
  static const String _keyAutoEliminate = 'sudoku_auto_eliminate';
  static const String _keyEnableHint = 'sudoku_enable_hint';
  static const String _keyBestEasy = 'sudoku_best_easy';
  static const String _keyBestMedium = 'sudoku_best_medium';
  static const String _keyBestHard = 'sudoku_best_hard';
  static const String _keyBestExpert = 'sudoku_best_expert';

  static Future<SudokuSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return SudokuSettings(
      showErrorHighlight: prefs.getBool(_keyShowErrorHighlight) ?? true,
      showCandidates: prefs.getBool(_keyShowCandidates) ?? false,
      autoEliminate: prefs.getBool(_keyAutoEliminate) ?? false,
      enableHint: prefs.getBool(_keyEnableHint) ?? true,
    );
  }

  static Future<void> saveSettings(SudokuSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_keyShowErrorHighlight, settings.showErrorHighlight),
      prefs.setBool(_keyShowCandidates, settings.showCandidates),
      prefs.setBool(_keyAutoEliminate, settings.autoEliminate),
      prefs.setBool(_keyEnableHint, settings.enableHint),
    ]);
  }

  static Future<int?> getBestTime(Difficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_getBestTimeKey(difficulty));
  }

  static Future<void> saveBestTime(Difficulty difficulty, int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getBestTimeKey(difficulty);
    final current = prefs.getInt(key);
    if (current == null || seconds < current) {
      await prefs.setInt(key, seconds);
    }
  }

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
      case Difficulty.easy: return _keyBestEasy;
      case Difficulty.medium: return _keyBestMedium;
      case Difficulty.hard: return _keyBestHard;
      case Difficulty.expert: return _keyBestExpert;
    }
  }
}