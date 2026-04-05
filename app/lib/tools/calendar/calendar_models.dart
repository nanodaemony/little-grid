/// 日历记事模型
class CalendarNote {
  final int? id;
  final String date; // 格式: yyyy-MM-dd
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  CalendarNote({
    this.id,
    required this.date,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'content': content,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory CalendarNote.fromMap(Map<String, dynamic> map) {
    return CalendarNote(
      id: map['id'],
      date: map['date'],
      content: map['content'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  CalendarNote copyWith({
    int? id,
    String? date,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarNote(
      id: id ?? this.id,
      date: date ?? this.date,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}