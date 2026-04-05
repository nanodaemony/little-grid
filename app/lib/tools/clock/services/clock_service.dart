import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/clock_config.dart';

class ClockService extends ChangeNotifier {
  ClockConfig _config = ClockConfig.defaultConfig();
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  ClockConfig get config => _config;
  DateTime get currentTime => _currentTime;

  ClockService() {
    _loadConfig();
    startClock();
  }

  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('clock_config');
      if (configJson != null) {
        _config = ClockConfig.fromJson(
          Map<String, dynamic>.from(jsonDecode(configJson)),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load clock config: $e');
    }
  }

  Future<void> saveConfig(ClockConfig newConfig) async {
    _config = newConfig;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('clock_config', jsonEncode(_config.toJson()));
    } catch (e) {
      debugPrint('Failed to save clock config: $e');
    }
    notifyListeners();
  }

  void startClock() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _currentTime = DateTime.now();
      notifyListeners();
    });
  }

  void stopClock() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopClock();
    super.dispose();
  }
}
