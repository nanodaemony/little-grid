class UsageStat {
  final int? id;
  final String toolId;
  final DateTime usedAt;
  final int? duration;

  UsageStat({
    this.id,
    required this.toolId,
    required this.usedAt,
    this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tool_id': toolId,
      'used_at': usedAt.millisecondsSinceEpoch,
      'duration': duration,
    };
  }

  factory UsageStat.fromMap(Map<String, dynamic> map) {
    return UsageStat(
      id: map['id'] as int?,
      toolId: map['tool_id'] as String,
      usedAt: DateTime.fromMillisecondsSinceEpoch(map['used_at'] as int),
      duration: map['duration'] as int?,
    );
  }
}
