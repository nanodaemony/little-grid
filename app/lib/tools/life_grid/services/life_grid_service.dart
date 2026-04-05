import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/life_grid_settings.dart';
import '../models/custom_progress.dart';

class LifeGridService {
  static const String _settingsKey = 'life_grid_settings';
  static const String _customProgressesKey = 'life_grid_custom_progresses';

  Future<void> init() async {
    // Service initialization if needed
  }

  // Settings
  Future<LifeGridSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_settingsKey);

    if (jsonString == null) {
      return LifeGridSettings();
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return LifeGridSettings.fromJson(json);
    } catch (e) {
      return LifeGridSettings();
    }
  }

  Future<void> saveSettings(LifeGridSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(settings.toJson());
    await prefs.setString(_settingsKey, jsonString);
  }

  // Custom Progresses
  Future<List<CustomProgress>> loadCustomProgresses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_customProgressesKey);

    if (jsonString == null) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => CustomProgress.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveCustomProgresses(List<CustomProgress> progresses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = progresses.map((p) => p.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_customProgressesKey, jsonString);
  }

  Future<void> addCustomProgress(CustomProgress progress) async {
    final progresses = await loadCustomProgresses();
    progresses.add(progress);
    await saveCustomProgresses(progresses);
  }

  Future<void> updateCustomProgress(CustomProgress updated) async {
    final progresses = await loadCustomProgresses();
    final index = progresses.indexWhere((p) => p.id == updated.id);
    if (index != -1) {
      progresses[index] = updated;
      await saveCustomProgresses(progresses);
    }
  }

  Future<void> deleteCustomProgress(String id) async {
    final progresses = await loadCustomProgresses();
    progresses.removeWhere((p) => p.id == id);
    await saveCustomProgresses(progresses);
  }

  // Progress Calculations
  Map<String, dynamic> getWeekProgress(DateTime now) {
    // Get the start of week (Monday)
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday
    final startOfWeek = now.subtract(Duration(days: weekday - 1));
    final currentDay = now.difference(startOfWeek).inDays + 1;

    return {
      'currentDay': currentDay,
      'totalDays': 7,
      'percentage': currentDay / 7,
    };
  }

  Map<String, dynamic> getMonthProgress(DateTime now) {
    final totalDays = DateTime(now.year, now.month + 1, 0).day;

    return {
      'currentDay': now.day,
      'totalDays': totalDays,
      'percentage': now.day / totalDays,
    };
  }

  Map<String, dynamic> getYearProgress(DateTime now) {
    final isLeapYear = (now.year % 4 == 0 && now.year % 100 != 0) ||
                       (now.year % 400 == 0);
    final totalDays = isLeapYear ? 366 : 365;

    // Calculate day of year
    final startOfYear = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(startOfYear).inDays + 1;

    return {
      'currentDay': dayOfYear,
      'totalDays': totalDays,
      'percentage': dayOfYear / totalDays,
      'isLeapYear': isLeapYear,
    };
  }

  Map<String, dynamic> getLifeProgress(
    DateTime birthDate,
    int targetAge,
    DateTime now
  ) {
    final totalMonths = targetAge * 12;

    // Calculate passed months
    int passedMonths = (now.year - birthDate.year) * 12 +
                       (now.month - birthDate.month);

    // Adjust if current day is before birth day
    if (now.day < birthDate.day) {
      passedMonths--;
    }

    if (passedMonths < 0) passedMonths = 0;
    if (passedMonths > totalMonths) passedMonths = totalMonths;

    return {
      'totalMonths': totalMonths,
      'passedMonths': passedMonths,
      'percentage': passedMonths / totalMonths,
      'remainingMonths': totalMonths - passedMonths,
    };
  }
}
