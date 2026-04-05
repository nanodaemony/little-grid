enum PomodoroType { work, shortBreak, longBreak }

class PomodoroRecord {
  final int? id;
  final DateTime startedAt;
  final int durationSeconds;
  final PomodoroType type;
  final bool completed;

  const PomodoroRecord({
    this.id,
    required this.startedAt,
    required this.durationSeconds,
    required this.type,
    this.completed = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'started_at': startedAt.millisecondsSinceEpoch,
      'duration_seconds': durationSeconds,
      'type': type.name,
      'completed': completed ? 1 : 0,
    };
  }

  factory PomodoroRecord.fromMap(Map<String, dynamic> map) {
    return PomodoroRecord(
      id: map['id'] as int?,
      startedAt: DateTime.fromMillisecondsSinceEpoch(map['started_at'] as int),
      durationSeconds: map['duration_seconds'] as int,
      type: PomodoroType.values.firstWhere((e) => e.name == map['type']),
      completed: (map['completed'] as int) == 1,
    );
  }

  PomodoroRecord copyWith({
    int? id,
    DateTime? startedAt,
    int? durationSeconds,
    PomodoroType? type,
    bool? completed,
  }) {
    return PomodoroRecord(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      type: type ?? this.type,
      completed: completed ?? this.completed,
    );
  }
}