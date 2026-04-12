import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class HistoryService {
  static const String _historyKey = 'salary_calculator_history';
  static const int _maxHistoryItems = 100;

  static Future<List<HistoryItem>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => HistoryItem.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveHistory(List<HistoryItem> history) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = List<HistoryItem>.from(history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final limited = sorted.take(_maxHistoryItems).toList();
    final jsonList = limited.map((item) => item.toJson()).toList();
    await prefs.setString(_historyKey, json.encode(jsonList));
  }

  static Future<void> addHistoryItem(HistoryItem item) async {
    final history = await loadHistory();
    history.insert(0, item);
    await saveHistory(history);
  }

  static Future<void> deleteHistoryItem(String id) async {
    final history = await loadHistory();
    history.removeWhere((item) => item.id == id);
    await saveHistory(history);
  }

  static Future<void> updateHistoryLabel(String id, String? label) async {
    final history = await loadHistory();
    final index = history.indexWhere((item) => item.id == id);
    if (index != -1) {
      history[index] = history[index].copyWith(label: label);
      await saveHistory(history);
    }
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
