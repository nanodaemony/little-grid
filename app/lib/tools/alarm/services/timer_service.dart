import 'dart:async';
import 'package:flutter/material.dart';
import '../models/timer_state.dart';
import 'notification_service.dart';

class TimerService extends ChangeNotifier {
  Timer? _timer;
  TimerState _state = TimerState();

  TimerState get state => _state;

  void start(Duration duration) {
    _state = TimerState(
      totalDuration: duration,
      remainingTime: duration,
      status: TimerStatus.running,
    );
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_state.remainingTime.inMilliseconds <= 100) {
        _finish();
      } else {
        _state = _state.copyWith(
          remainingTime: _state.remainingTime - const Duration(milliseconds: 100),
        );
        notifyListeners();
      }
    });
  }

  void pause() {
    if (_state.status != TimerStatus.running) return;
    _timer?.cancel();
    _state = _state.copyWith(status: TimerStatus.paused);
    notifyListeners();
  }

  void resume() {
    if (_state.status != TimerStatus.paused) return;
    _state = _state.copyWith(status: TimerStatus.running);
    notifyListeners();

    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_state.remainingTime.inMilliseconds <= 100) {
        _finish();
      } else {
        _state = _state.copyWith(
          remainingTime: _state.remainingTime - const Duration(milliseconds: 100),
        );
        notifyListeners();
      }
    });
  }

  void reset() {
    _timer?.cancel();
    _state = TimerState();
    notifyListeners();
  }

  void _finish() {
    _timer?.cancel();
    _state = _state.copyWith(
      remainingTime: Duration.zero,
      status: TimerStatus.finished,
    );
    notifyListeners();

    // 发送通知
    NotificationService().zonedSchedule(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '倒计时结束',
      body: '时间到！',
      scheduledDate: DateTime.now(),
      channel: 'timer_channel',
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}