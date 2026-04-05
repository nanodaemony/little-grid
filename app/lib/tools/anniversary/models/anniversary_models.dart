enum AnniversaryType {
  anniversary,
  countdown,
}

enum RepeatType {
  none,
  daily,
  weekly,
  monthly,
  yearly,
}

class AnniversaryDisplayData {
  final int primaryNumber;
  final String primaryLabel;
  final String? secondaryText;

  AnniversaryDisplayData({
    required this.primaryNumber,
    required this.primaryLabel,
    this.secondaryText,
  });
}

abstract class AnniversaryBase {
  final int? id;
  final String title;
  final DateTime targetDate;
  final AnniversaryType type;
  final RepeatType repeatType;
  final String? notes;
  final int iconColor;
  final DateTime createdAt;
  final DateTime updatedAt;

  AnniversaryBase({
    this.id,
    required this.title,
    required this.targetDate,
    required this.type,
    required this.repeatType,
    this.notes,
    required this.iconColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  AnniversaryDisplayData calculateDisplay();

  Map<String, dynamic> toMap();
}

class AnniversaryItem extends AnniversaryBase {
  AnniversaryItem({
    super.id,
    required super.title,
    required super.targetDate,
    required super.repeatType,
    super.notes,
    required super.iconColor,
    super.createdAt,
    super.updatedAt,
  }) : super(type: AnniversaryType.anniversary);

  @override
  AnniversaryDisplayData calculateDisplay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (repeatType == RepeatType.none) {
      final daysPassed = today.difference(targetDate).inDays;
      return AnniversaryDisplayData(
        primaryNumber: daysPassed.abs(),
        primaryLabel: daysPassed >= 0 ? '天已过' : '天后',
        secondaryText: null,
      );
    } else {
      final nextDate = _calculateNextDate(today, targetDate, repeatType);
      final daysUntil = nextDate.difference(today).inDays;
      return AnniversaryDisplayData(
        primaryNumber: daysUntil,
        primaryLabel: '天后',
        secondaryText: '${nextDate.year}年${nextDate.month}月${nextDate.day}日',
      );
    }
  }

  DateTime _calculateNextDate(DateTime today, DateTime targetDate, RepeatType repeatType) {
    switch (repeatType) {
      case RepeatType.daily:
        return today.add(const Duration(days: 1));

      case RepeatType.weekly:
        final targetWeekday = targetDate.weekday;
        final todayWeekday = today.weekday;
        int daysToAdd = targetWeekday - todayWeekday;
        if (daysToAdd <= 0) {
          daysToAdd += 7;
        }
        return today.add(Duration(days: daysToAdd));

      case RepeatType.monthly:
        int targetYear = today.year;
        int targetMonth = today.month;
        int targetDay = targetDate.day;

        DateTime candidate = DateTime(targetYear, targetMonth, targetDay);

        if (candidate.isBefore(today) || candidate.day != targetDay) {
          targetMonth++;
          if (targetMonth > 12) {
            targetMonth = 1;
            targetYear++;
          }
          candidate = DateTime(targetYear, targetMonth, 1);
          final lastDayOfMonth = DateTime(targetYear, targetMonth + 1, 0).day;
          candidate = DateTime(targetYear, targetMonth,
              targetDay > lastDayOfMonth ? lastDayOfMonth : targetDay);
        }
        return candidate;

      case RepeatType.yearly:
        int targetYear = today.year;
        int targetMonth = targetDate.month;
        int targetDay = targetDate.day;

        DateTime candidate = DateTime(targetYear, targetMonth, targetDay);

        if (targetMonth == 2 && targetDay == 29) {
          if (!_isLeapYear(targetYear)) {
            candidate = DateTime(targetYear, 2, 28);
          }
        }

        if (candidate.isBefore(today)) {
          targetYear++;
          candidate = DateTime(targetYear, targetMonth, targetDay);
          if (targetMonth == 2 && targetDay == 29 && !_isLeapYear(targetYear)) {
            candidate = DateTime(targetYear, 2, 28);
          }
        }
        return candidate;

      default:
        return targetDate;
    }
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  factory AnniversaryItem.fromMap(Map<String, dynamic> map) {
    return AnniversaryItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['target_date'] as int),
      repeatType: RepeatType.values[map['repeat_type'] as int],
      notes: map['notes'] as String?,
      iconColor: map['icon_color'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'target_date': targetDate.millisecondsSinceEpoch,
      'type': type.index,
      'repeat_type': repeatType.index,
      'notes': notes,
      'icon_color': iconColor,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}

class CountdownItem extends AnniversaryBase {
  CountdownItem({
    super.id,
    required super.title,
    required super.targetDate,
    super.notes,
    required super.iconColor,
    super.createdAt,
    super.updatedAt,
  }) : super(type: AnniversaryType.countdown, repeatType: RepeatType.none);

  @override
  AnniversaryDisplayData calculateDisplay() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysUntil = targetDate.difference(today).inDays;

    return AnniversaryDisplayData(
      primaryNumber: daysUntil,
      primaryLabel: '天后',
      secondaryText: null,
    );
  }

  factory CountdownItem.fromMap(Map<String, dynamic> map) {
    return CountdownItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['target_date'] as int),
      notes: map['notes'] as String?,
      iconColor: map['icon_color'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'target_date': targetDate.millisecondsSinceEpoch,
      'type': type.index,
      'repeat_type': repeatType.index,
      'notes': notes,
      'icon_color': iconColor,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }
}

AnniversaryBase anniversaryFromMap(Map<String, dynamic> map) {
  final type = AnniversaryType.values[map['type'] as int];
  switch (type) {
    case AnniversaryType.anniversary:
      return AnniversaryItem.fromMap(map);
    case AnniversaryType.countdown:
      return CountdownItem.fromMap(map);
  }
}
