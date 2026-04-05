enum IconType { emoji, material }

class WheelCollection {
  final int? id;
  final String name;
  final IconType iconType;
  final String icon;
  final bool isPreset;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  WheelCollection({
    this.id,
    required this.name,
    this.iconType = IconType.emoji,
    required this.icon,
    this.isPreset = false,
    this.sortOrder = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_type': iconType == IconType.emoji ? 1 : 2,
      'icon': icon,
      'is_preset': isPreset ? 1 : 0,
      'sort_order': sortOrder,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory WheelCollection.fromMap(Map<String, dynamic> map) {
    return WheelCollection(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconType: map['icon_type'] == 1 ? IconType.emoji : IconType.material,
      icon: map['icon'] as String,
      isPreset: map['is_preset'] == 1,
      sortOrder: map['sort_order'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  WheelCollection copyWith({
    int? id,
    String? name,
    IconType? iconType,
    String? icon,
    bool? isPreset,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WheelCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      iconType: iconType ?? this.iconType,
      icon: icon ?? this.icon,
      isPreset: isPreset ?? this.isPreset,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
