import 'wheel_collection.dart';

class WheelOption {
  final int? id;
  final int collectionId;
  final String name;
  final IconType iconType;
  final String? icon;
  final double weight;
  final String? color;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  WheelOption({
    this.id,
    required this.collectionId,
    required this.name,
    this.iconType = IconType.emoji,
    this.icon,
    this.weight = 1.0,
    this.color,
    this.sortOrder = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'collection_id': collectionId,
      'name': name,
      'icon_type': iconType == IconType.emoji ? 1 : 2,
      'icon': icon,
      'weight': weight,
      'color': color,
      'sort_order': sortOrder,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory WheelOption.fromMap(Map<String, dynamic> map) {
    return WheelOption(
      id: map['id'] as int?,
      collectionId: map['collection_id'] as int,
      name: map['name'] as String,
      iconType: map['icon_type'] == 1 ? IconType.emoji : IconType.material,
      icon: map['icon'] as String?,
      weight: (map['weight'] as num).toDouble(),
      color: map['color'] as String?,
      sortOrder: map['sort_order'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  WheelOption copyWith({
    int? id,
    int? collectionId,
    String? name,
    IconType? iconType,
    String? icon,
    double? weight,
    String? color,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WheelOption(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      name: name ?? this.name,
      iconType: iconType ?? this.iconType,
      icon: icon ?? this.icon,
      weight: weight ?? this.weight,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
