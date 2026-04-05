import 'package:flutter/material.dart';

enum RepeatType { once, daily, custom }

class AlarmItem {
  final String id;
  final int hour;
  final int minute;
  final String label;
  final RepeatType repeatType;
  final List<int> repeatDays; // 0=周日, 1-6=周一至周六
  final bool isEnabled;
  final String sound;
  final DateTime createdAt;
  final DateTime updatedAt;

  AlarmItem({
    required this.id,
    required this.hour,
    required this.minute,
    this.label = '',
    this.repeatType = RepeatType.once,
    this.repeatDays = const [],
    this.isEnabled = true,
    this.sound = 'default',
    required this.createdAt,
    required this.updatedAt,
  });

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  /// 计算下次响铃时间
  DateTime? get nextTriggerTime {
    final now = DateTime.now();
    DateTime next = DateTime(now.year, now.month, now.day, hour, minute);

    switch (repeatType) {
      case RepeatType.once:
        if (next.isBefore(now) || next.isAtSameMomentAs(now)) {
          return null; // 已过期的单次闹钟
        }
        return next;

      case RepeatType.daily:
        while (next.isBefore(now) || next.isAtSameMomentAs(now)) {
          next = next.add(const Duration(days: 1));
        }
        return next;

      case RepeatType.custom:
        if (repeatDays.isEmpty) return null;
        for (int i = 0; i < 8; i++) {
          final checkDate = next.add(Duration(days: i));
          final weekday = checkDate.weekday % 7; // 转换为 0=周日
          if ((next.isAfter(now) || i > 0) && repeatDays.contains(weekday)) {
            return checkDate;
          }
        }
        return null;
    }
  }

  String get repeatText {
    switch (repeatType) {
      case RepeatType.once:
        return '单次';
      case RepeatType.daily:
        return '每天';
      case RepeatType.custom:
        if (repeatDays.length == 5 &&
            [1, 2, 3, 4, 5].every((d) => repeatDays.contains(d))) {
          return '工作日';
        }
        const dayNames = ['日', '一', '二', '三', '四', '五', '六'];
        return repeatDays.map((d) => '周${dayNames[d]}').join('、');
    }
  }

  /// 计算距离下次响铃还有多久（精确到分钟）
  String? get timeUntilTrigger {
    final next = nextTriggerTime;
    if (next == null) return null;

    final now = DateTime.now();
    final diff = next.difference(now);

    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;

    if (days > 0) {
      return '${days}天${hours}小时${minutes}分钟后响铃';
    } else if (hours > 0) {
      return '${hours}小时${minutes}分钟后响铃';
    } else if (minutes > 0) {
      return '${minutes}分钟后响铃';
    } else {
      return '即将响铃';
    }
  }

  AlarmItem copyWith({
    String? id,
    int? hour,
    int? minute,
    String? label,
    RepeatType? repeatType,
    List<int>? repeatDays,
    bool? isEnabled,
    String? sound,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlarmItem(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
      repeatType: repeatType ?? this.repeatType,
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
      sound: sound ?? this.sound,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hour': hour,
      'minute': minute,
      'label': label,
      'repeat_type': repeatType.name,
      'repeat_days': repeatDays.toString(),
      'is_enabled': isEnabled ? 1 : 0,
      'sound': sound,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory AlarmItem.fromMap(Map<String, dynamic> map) {
    return AlarmItem(
      id: map['id'] as String,
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      label: map['label'] as String? ?? '',
      repeatType: RepeatType.values.firstWhere(
        (e) => e.name == map['repeat_type'],
        orElse: () => RepeatType.once,
      ),
      repeatDays: _parseRepeatDays(map['repeat_days'] as String?),
      isEnabled: map['is_enabled'] == 1,
      sound: map['sound'] as String? ?? 'default',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  static List<int> _parseRepeatDays(String? value) {
    if (value == null || value.isEmpty) return [];
    // 解析 "[1, 2, 3]" 格式
    final match = RegExp(r'\[(.*)\]').firstMatch(value);
    if (match == null) return [];
    return match
        .group(1)!
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();
  }
}