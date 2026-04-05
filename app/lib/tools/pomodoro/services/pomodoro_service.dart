import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/pomodoro_state.dart';
import '../models/pomodoro_settings.dart';
import '../models/pomodoro_record.dart';
import 'pomodoro_stats_service.dart';

class PomodoroService extends ChangeNotifier {
  PomodoroState _state = const PomodoroState();
  PomodoroSettings _settings = const PomodoroSettings();
  Timer? _timer;
  DateTime? _startedAt;
  final PomodoroStatsService _statsService = PomodoroStatsService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  PomodoroState get state => _state;
  PomodoroSettings get settings => _settings;

  // 加载设置
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('pomodoro_settings');
    if (settingsJson != null) {
      _settings = PomodoroSettings.fromJson(settingsJson);
    }
    await _loadTodayCount();
    notifyListeners();
  }

  // 保存设置
  Future<void> saveSettings(PomodoroSettings settings) async {
    _settings = settings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pomodoro_settings', settings.toJson());
    notifyListeners();
  }

  // 加载今日已完成数
  Future<void> _loadTodayCount() async {
    final count = await _statsService.getTodayCount();
    _state = _state.copyWith(completedCount: count);
  }

  // 开始番茄计时
  void startWork() {
    _startedAt = DateTime.now();
    final duration = _settings.workDuration * 60;

    _state = _state.copyWith(
      status: PomodoroStatus.running,
      remainingSeconds: duration,
      totalSeconds: duration,
      isBreak: false,
      isLongBreak: false,
    );
    notifyListeners();

    _startTimer();
  }

  // 开始休息
  void startBreak({bool isLong = false}) {
    _startedAt = DateTime.now();
    final duration = isLong
        ? _settings.longBreakDuration * 60
        : _settings.shortBreakDuration * 60;

    _state = _state.copyWith(
      status: PomodoroStatus.breakRunning,
      remainingSeconds: duration,
      totalSeconds: duration,
      isBreak: true,
      isLongBreak: isLong,
    );
    notifyListeners();

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state.remainingSeconds <= 1) {
        _finishTimer();
      } else {
        _state = _state.copyWith(
          remainingSeconds: _state.remainingSeconds - 1,
        );
        notifyListeners();
      }
    });
  }

  void _finishTimer() {
    _timer?.cancel();

    if (_state.isBreak) {
      // 休息结束
      _state = _state.copyWith(
        status: PomodoroStatus.breakCompleted,
        remainingSeconds: 0,
      );
      notifyListeners();
      _notifyUser();
      _handleBreakComplete();
    } else {
      // 番茄结束
      _state = _state.copyWith(
        status: PomodoroStatus.completed,
        remainingSeconds: 0,
      );
      notifyListeners();
      _notifyUser();
      _handleWorkComplete();
    }
  }

  Future<void> _handleWorkComplete() async {
    // 保存记录
    if (_startedAt != null) {
      await _statsService.insertRecord(PomodoroRecord(
        startedAt: _startedAt!,
        durationSeconds: _state.totalSeconds,
        type: PomodoroType.work,
        completed: true,
      ));
    }

    // 更新计数
    final newStreak = _state.currentStreak + 1;
    _state = _state.copyWith(
      completedCount: _state.completedCount + 1,
      currentStreak: newStreak,
    );
    notifyListeners();

    // 根据设置决定下一步
    if (_settings.completeAction == CompleteAction.autoProceed) {
      _proceedToBreak();
    } else {
      _state = _state.copyWith(status: PomodoroStatus.waiting);
      notifyListeners();
    }
  }

  void _handleBreakComplete() {
    if (_settings.completeAction == CompleteAction.autoProceed) {
      startWork();
    } else {
      _state = _state.copyWith(status: PomodoroStatus.waiting);
      notifyListeners();
    }
  }

  void _proceedToBreak() {
    // 判断是否需要长休息
    final needLongBreak = _settings.longBreakEnabled &&
        _state.currentStreak > 0 &&
        _state.currentStreak % _settings.longBreakInterval == 0;

    if (needLongBreak) {
      startBreak(isLong: true);
    } else if (_settings.shortBreakEnabled) {
      startBreak(isLong: false);
    } else {
      startWork();
    }
  }

  // 用户确认进入下一步
  void proceed() {
    if (_state.status == PomodoroStatus.completed) {
      _proceedToBreak();
    } else if (_state.status == PomodoroStatus.breakCompleted) {
      startWork();
    }
  }

  // 暂停
  void pause() {
    if (_state.status != PomodoroStatus.running &&
        _state.status != PomodoroStatus.breakRunning) return;

    _timer?.cancel();
    _state = _state.copyWith(status: PomodoroStatus.paused);
    notifyListeners();
  }

  // 继续
  void resume() {
    if (_state.status != PomodoroStatus.paused) return;

    _state = _state.copyWith(
      status: _state.isBreak
          ? PomodoroStatus.breakRunning
          : PomodoroStatus.running,
    );
    notifyListeners();
    _startTimer();
  }

  // 重置
  void reset() {
    _timer?.cancel();
    _state = const PomodoroState();
    _startedAt = null;
    _loadTodayCount();
    notifyListeners();
  }

  // 提醒用户
  Future<void> _notifyUser() async {
    if (_settings.vibrationEnabled) {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 500);
      }
    }

    if (_settings.soundEnabled) {
      await _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}