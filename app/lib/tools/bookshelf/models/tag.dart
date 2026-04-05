// app/lib/tools/bookshelf/models/tag.dart

class Tag {
  final int id;
  final String name;
  final DateTime? createTime;
  final DateTime? updateTime;

  Tag({
    required this.id,
    required this.name,
    this.createTime,
    this.updateTime,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as int,
      name: json['name'] as String,
      createTime: json['createTime'] != null
          ? DateTime.parse(json['createTime'])
          : null,
      updateTime: json['updateTime'] != null
          ? DateTime.parse(json['updateTime'])
          : null,
    );
  }
}
