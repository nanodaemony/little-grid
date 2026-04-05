enum TimerStatus { idle, running, paused, finished }

class TimerState {
  final Duration totalDuration;
  final Duration remainingTime;
  final TimerStatus status;

  TimerState({
    this.totalDuration = Duration.zero,
    this.remainingTime = Duration.zero,
    this.status = TimerStatus.idle,
  });

  TimerState copyWith({
    Duration? totalDuration,
    Duration? remainingTime,
    TimerStatus? status,
  }) {
    return TimerState(
      totalDuration: totalDuration ?? this.totalDuration,
      remainingTime: remainingTime ?? this.remainingTime,
      status: status ?? this.status,
    );
  }

  double get progress {
    if (totalDuration.inSeconds == 0) return 0;
    return 1 - (remainingTime.inMilliseconds / totalDuration.inMilliseconds);
  }

  String get displayTime {
    final minutes = remainingTime.inMinutes;
    final seconds = remainingTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}