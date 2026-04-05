enum PomodoroStatus {
  idle,
  running,
  paused,
  completed,
  waiting,
  breakRunning,
  breakCompleted,
}

class PomodoroState {
  final PomodoroStatus status;
  final int remainingSeconds;
  final int totalSeconds;
  final int completedCount;
  final int currentStreak;
  final bool isBreak;
  final bool isLongBreak;

  const PomodoroState({
    this.status = PomodoroStatus.idle,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
    this.completedCount = 0,
    this.currentStreak = 0,
    this.isBreak = false,
    this.isLongBreak = false,
  });

  double get progress {
    if (totalSeconds == 0) return 0;
    return 1 - (remainingSeconds / totalSeconds);
  }

  PomodoroState copyWith({
    PomodoroStatus? status,
    int? remainingSeconds,
    int? totalSeconds,
    int? completedCount,
    int? currentStreak,
    bool? isBreak,
    bool? isLongBreak,
  }) {
    return PomodoroState(
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      completedCount: completedCount ?? this.completedCount,
      currentStreak: currentStreak ?? this.currentStreak,
      isBreak: isBreak ?? this.isBreak,
      isLongBreak: isLongBreak ?? this.isLongBreak,
    );
  }
}