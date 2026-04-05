// app/lib/tools/bookshelf/models/category.dart

class Category {
  final int id;
  final String name;
  final int? sort;
  final DateTime? createTime;
  final DateTime? updateTime;

  Category({
    required this.id,
    required this.name,
    this.sort,
    this.createTime,
    this.updateTime,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      sort: json['sort'] as int?,
      createTime: json['createTime'] != null
          ? DateTime.parse(json['createTime'])
          : null,
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (sort != null) 'sort': sort,
      if (createTime != null) 'createTime': createTime!.toIso8601String(),
      if (updateTime != null) 'updateTime': updateTime!.toIso8601String(),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    int? sort,
    DateTime? createTime,
    DateTime? updateTime,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      sort: sort ?? this.sort,
      createTime: createTime ?? this.createTime,
      updateTime: updateTime ?? this.updateTime,
    );
  }
}
