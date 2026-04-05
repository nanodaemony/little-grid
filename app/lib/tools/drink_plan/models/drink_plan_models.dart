// lib/tools/drink_plan/models/drink_plan_models.dart

import 'package:flutter/material.dart';

/// 标记类型枚举
enum MarkType {
  none,
  noDrink,
  light,
  medium,
  heavy,
}

extension MarkTypeExtension on MarkType {
  String get emoji {
    switch (this) {
      case MarkType.none:
        return '⭕';
      case MarkType.noDrink:
        return '✅';
      case MarkType.light:
        return '😐';
      case MarkType.medium:
        return '😰';
      case MarkType.heavy:
        return '🤢';
    }
  }

  String get label {
    switch (this) {
      case MarkType.none:
        return '未记录';
      case MarkType.noDrink:
        return '未饮酒';
      case MarkType.light:
        return '少量';
      case MarkType.medium:
        return '中等';
      case MarkType.heavy:
        return '过量';
    }
  }

  Color get color {
    switch (this) {
      case MarkType.none:
        return Colors.grey;
      case MarkType.noDrink:
        return Colors.green;
      case MarkType.light:
        return Colors.yellow.shade700;
      case MarkType.medium:
        return Colors.orange;
      case MarkType.heavy:
        return Colors.red;
    }
  }
}

/// 每日记录数据模型
class DailyRecord {
  final String date;
  final MarkType mark;
  final List<DrinkItem> drinks;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyRecord({
    required this.date,
    this.mark = MarkType.none,
    this.drinks = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  int get totalSugar {
    return drinks.fold(0, (sum, drink) => sum + drink.sugar);
  }

  DailyRecord copyWith({
    String? date,
    MarkType? mark,
    List<DrinkItem>? drinks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyRecord(
      date: date ?? this.date,
      mark: mark ?? this.mark,
      drinks: drinks ?? this.drinks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 饮品记录项
class DrinkItem {
  final String name;
  final int sugar; // 含糖量
  final int volume; // 容量(ml)
  final DateTime time;

  DrinkItem({
    required this.name,
    required this.sugar,
    required this.volume,
    required this.time,
  });
}
