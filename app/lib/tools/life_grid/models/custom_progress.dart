import 'package:uuid/uuid.dart';

class CustomProgress {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  CustomProgress({
    String? id,
    required this.name,
    required this.startDate,
    required this.endDate,
    DateTime? createdAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }

  int passedDays(DateTime now) {
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return totalDays;
    return now.difference(startDate).inDays + 1;
  }

  double getProgressPercentage(DateTime now) {
    return passedDays(now) / totalDays;
  }

  bool isCurrent(DateTime now) {
    return !now.isBefore(startDate) && !now.isAfter(endDate);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': _dateToString(startDate),
      'endDate': _dateToString(endDate),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomProgress.fromJson(Map<String, dynamic> json) {
    return CustomProgress(
      id: json['id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static String _dateToString(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
           '${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }
}
