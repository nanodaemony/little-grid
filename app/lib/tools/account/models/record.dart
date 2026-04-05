enum RecordType { expense, income }

class Record {
  final int? id;
  final double amount;
  final RecordType type;
  final int categoryId;
  final int? subCategoryId;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  Record({
    this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.subCategoryId,
    required this.date,
    this.note,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type == RecordType.expense ? 1 : 2,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'date': date.millisecondsSinceEpoch,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Record.fromMap(Map<String, dynamic> map) {
    return Record(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] == 1 ? RecordType.expense : RecordType.income,
      categoryId: map['category_id'] as int,
      subCategoryId: map['sub_category_id'] as int?,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      note: map['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Record copyWith({
    int? id,
    double? amount,
    RecordType? type,
    int? categoryId,
    int? subCategoryId,
    DateTime? date,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Record(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
