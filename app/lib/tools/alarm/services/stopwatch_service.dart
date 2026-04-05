import 'dart:async';
import 'package:flutter/material.dart';
import '../models/stopwatch_lap.dart';

class StopwatchService extends ChangeNotifier {
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();
  final List<StopwatchLap> _laps = [];
  Duration _elapsed = Duration.zero;

  bool get isRunning => _stopwatch.isRunning;
  Duration get elapsed => _elapsed;
  List<StopwatchLap> get laps => List.unmodifiable(_laps);

  void start() {
    if (_stopwatch.isRunning) return;

    _stopwatch.start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      _elapsed = _stopwatch.elapsed;
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    if (!_stopwatch.isRunning) return;

    _stopwatch.stop();
    _timer?.cancel();
    notifyListeners();
  }

  void reset() {
    _stopwatch.stop();
    _stopwatch.reset();
    _timer?.cancel();
    _laps.clear();
    _elapsed = Duration.zero;
    notifyListeners();
  }

  void addLap() {
    if (!_stopwatch.isRunning) return;

    final totalTime = _stopwatch.elapsed;
    final previousTotal = _laps.isEmpty
        ? Duration.zero
        : _laps.last.totalTime;
    final lapTime = totalTime - previousTotal;

    _laps.add(StopwatchLap(
      lapNumber: _laps.length + 1,
      lapTime: lapTime,
      totalTime: totalTime,
    ));
    notifyListeners();
  }

  String get displayTime {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes % 60;
    final seconds = _elapsed.inSeconds % 60;
    final centiseconds = (_elapsed.inMilliseconds % 1000) ~/ 10;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${centiseconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}