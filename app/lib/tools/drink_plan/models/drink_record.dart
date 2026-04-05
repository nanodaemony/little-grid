class DrinkRecord {
  final int? id;
  final String date;
  final String mark;
  final DateTime createdAt;
  final DateTime updatedAt;

  DrinkRecord({
    this.id,
    required this.date,
    required this.mark,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'mark': mark,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory DrinkRecord.fromMap(Map<String, dynamic> map) {
    return DrinkRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      mark: map['mark'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  DrinkRecord copyWith({
    int? id,
    String? date,
    String? mark,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DrinkRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      mark: mark ?? this.mark,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
