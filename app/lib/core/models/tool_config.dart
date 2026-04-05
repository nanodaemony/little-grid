class ToolConfig {
  final String id;
  final String name;
  final String category;
  final int sortOrder;
  final bool isPinned;
  final int useCount;
  final DateTime? lastUsedAt;
  final int gridSize;

  ToolConfig({
    required this.id,
    required this.name,
    required this.category,
    this.sortOrder = 0,
    this.isPinned = false,
    this.useCount = 0,
    this.lastUsedAt,
    this.gridSize = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'sort_order': sortOrder,
      'is_pinned': isPinned ? 1 : 0,
      'use_count': useCount,
      'last_used_at': lastUsedAt?.millisecondsSinceEpoch,
      'grid_size': gridSize,
    };
  }

  factory ToolConfig.fromMap(Map<String, dynamic> map) {
    return ToolConfig(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      sortOrder: map['sort_order'] as int? ?? 0,
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
      useCount: map['use_count'] as int? ?? 0,
      lastUsedAt: map['last_used_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_used_at'] as int)
          : null,
      gridSize: map['grid_size'] as int? ?? 1,
    );
  }

  ToolConfig copyWith({
    String? id,
    String? name,
    String? category,
    int? sortOrder,
    bool? isPinned,
    int? useCount,
    DateTime? lastUsedAt,
    int? gridSize,
  }) {
    return ToolConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      sortOrder: sortOrder ?? this.sortOrder,
      isPinned: isPinned ?? this.isPinned,
      useCount: useCount ?? this.useCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      gridSize: gridSize ?? this.gridSize,
    );
  }
}
