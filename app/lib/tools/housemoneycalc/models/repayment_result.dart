import 'package:meta/meta.dart';
import 'repayment_schedule.dart';

@immutable
class RepaymentResult {
  final double firstMonthPayment;
  final double lastMonthPayment;
  final double totalPayment;
  final double totalInterest;
  final double totalPrincipal;
  final List<MonthlyData> monthlyData;
  final List<YearlyData> yearlyData;

  const RepaymentResult({
    required this.firstMonthPayment,
    required this.lastMonthPayment,
    required this.totalPayment,
    required this.totalInterest,
    required this.totalPrincipal,
    required this.monthlyData,
    required this.yearlyData,
  });

  double get averageMonthlyPayment =>
      monthlyData.isEmpty ? 0 : totalPayment / monthlyData.length;
}
