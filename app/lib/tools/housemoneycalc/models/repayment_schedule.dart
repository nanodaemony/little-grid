import 'package:meta/meta.dart';

/// Monthly repayment data
@immutable
class MonthlyData {
  final int month; // 1-based month number
  final double payment; // Monthly payment amount
  final double principal; // Principal portion
  final double interest; // Interest portion
  final double remainingPrincipal;

  const MonthlyData({
    required this.month,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.remainingPrincipal,
  });

  /// Get the year number (1-based)
  int get year => ((month - 1) / 12).floor() + 1;

  /// Get the month number within the year (1-12)
  int get monthInYear => ((month - 1) % 12) + 1;
}

/// Yearly repayment summary
@immutable
class YearlyData {
  final int year;
  final double yearPayment;
  final double yearPrincipal;
  final double yearInterest;
  final List<MonthlyData> monthlyData;

  YearlyData({
    required this.year,
    required this.yearPayment,
    required this.yearPrincipal,
    required this.yearInterest,
    required List<MonthlyData> monthlyData,
  }) : monthlyData = List.unmodifiable(monthlyData);
}
