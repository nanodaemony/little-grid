import 'record.dart';

enum IconType { emoji, asset }

class Category {
  final int? id;
  final String name;
  final String icon;
  final IconType iconType;
  final int parentId;
  final RecordType type;
  final int sortOrder;
  final bool isPreset;
  final bool isHidden;

  Category({
    this.id,
    required this.name,
    required this.icon,
    this.iconType = IconType.emoji,
    this.parentId = 0,
    required this.type,
    this.sortOrder = 0,
    this.isPreset = false,
    this.isHidden = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'icon_type': iconType == IconType.emoji ? 1 : 2,
      'parent_id': parentId,
      'type': type == RecordType.expense ? 1 : 2,
      'sort_order': sortOrder,
      'is_preset': isPreset ? 1 : 0,
      'is_hidden': isHidden ? 1 : 0,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String,
      iconType: map['icon_type'] == 1 ? IconType.emoji : IconType.asset,
      parentId: map['parent_id'] as int,
      type: map['type'] == 1 ? RecordType.expense : RecordType.income,
      sortOrder: map['sort_order'] as int,
      isPreset: map['is_preset'] == 1,
      isHidden: map['is_hidden'] == 1,
    );
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    IconType? iconType,
    int? parentId,
    RecordType? type,
    int? sortOrder,
    bool? isPreset,
    bool? isHidden,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      iconType: iconType ?? this.iconType,
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
      sortOrder: sortOrder ?? this.sortOrder,
      isPreset: isPreset ?? this.isPreset,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}
