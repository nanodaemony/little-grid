import 'package:flutter/material.dart';

class LogEntry {
  final DateTime timestamp;
  final String level;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });
}

class DebugLogService extends ChangeNotifier {
  static final DebugLogService _instance = DebugLogService._internal();
  factory DebugLogService() => _instance;
  DebugLogService._internal();

  final List<LogEntry> _logs = [];

  List<LogEntry> get logs => List.unmodifiable(_logs);

  void addLog(String level, String message) {
    _logs.add(LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
    ));
    notifyListeners();
  }

  void clearLogs() {
    _logs.clear();
    notifyListeners();
  }
}
