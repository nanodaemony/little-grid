# Model 层模板

```dart
class XxxItem {
  final int? id;
  final String field1;
  final DateTime createdAt;
  final DateTime updatedAt;

  XxxItem({
    this.id,
    required this.field1,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'field1': field1,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory XxxItem.fromMap(Map<String, dynamic> map) {
    return XxxItem(
      id: map['id'],
      field1: map['field1'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  XxxItem copyWith({
    int? id,
    String? field1,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return XxxItem(
      id: id ?? this.id,
      field1: field1 ?? this.field1,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```
