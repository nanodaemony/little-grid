import '../models/loan_enums.dart';
import '../models/loan_params.dart';
import '../models/repayment_result.dart';
import '../models/repayment_schedule.dart';

/// Mortgage calculator service for computing loan repayments
///
/// Supports both equal interest (等额本息) and equal principal (等额本金)
/// repayment methods, as well as combined loans (组合贷).
class MortgageCalculator {
  /// Main calculate method that computes the full repayment schedule
  ///
  /// [params] - The loan parameters including amount, term, rate, and method
  /// Returns a [RepaymentResult] containing monthly and yearly breakdowns
  static RepaymentResult calculate(LoanParams params) {
    // Validate inputs
    if (params.totalAmount <= 0) {
      throw ArgumentError('Loan amount must be greater than 0');
    }
    if (params.loanTermYears <= 0) {
      throw ArgumentError('Loan term must be greater than 0');
    }
    if (params.monthlyRate == null || params.monthlyRate! < 0) {
      throw ArgumentError('Interest rate cannot be negative');
    }

    if (params.loanType == LoanType.combined) {
      return _calculateCombined(params);
    }

    final monthlyRate = params.monthlyRate;
    if (monthlyRate == null) {
      throw ArgumentError('Invalid interest rate');
    }

    final principal = params.totalAmount * 10000; // Convert from 万元 to yuan
    final months = params.totalMonths;

    final monthlyData = params.repaymentMethod == RepaymentMethod.equalInterest
        ? _calculateEqualInterest(principal, monthlyRate, months)
        : _calculateEqualPrincipal(principal, monthlyRate, months);

    final yearlyData = _groupByYear(monthlyData);

    final totalPayment = monthlyData.fold<double>(0, (sum, m) => sum + m.payment);
    final totalPrincipal = monthlyData.fold<double>(0, (sum, m) => sum + m.principal);
    final totalInterest = monthlyData.fold<double>(0, (sum, m) => sum + m.interest);

    return RepaymentResult(
      firstMonthPayment: monthlyData.first.payment,
      lastMonthPayment: monthlyData.last.payment,
      totalPayment: totalPayment,
      totalInterest: totalInterest,
      totalPrincipal: totalPrincipal,
      monthlyData: monthlyData,
      yearlyData: yearlyData,
    );
  }

  /// Calculate equal interest repayment (等额本息)
  ///
  /// Monthly payment remains constant throughout the loan term.
  /// Formula: monthlyPayment = (principal * monthlyRate * pow(1+monthlyRate, months)) / (pow(1+monthlyRate, months) - 1)
  ///
  /// [principal] - Total loan principal in yuan
  /// [monthlyRate] - Monthly interest rate as decimal
  /// [months] - Total number of months
  static List<MonthlyData> _calculateEqualInterest(
    double principal,
    double monthlyRate,
    int months,
  ) {
    if (months <= 0) {
      throw ArgumentError('Months must be greater than 0');
    }
    if (principal < 0) {
      throw ArgumentError('Principal cannot be negative');
    }
    if (monthlyRate < 0) {
      throw ArgumentError('Monthly rate cannot be negative');
    }

    double monthlyPayment;
    if (monthlyRate == 0) {
      monthlyPayment = principal / months;
    } else {
      final powFactor = pow(1 + monthlyRate, months);
      monthlyPayment = (principal * monthlyRate * powFactor) / (powFactor - 1);
    }

    final result = <MonthlyData>[];
    double remainingPrincipal = principal;

    for (int month = 1; month <= months; month++) {
      final interest = remainingPrincipal * monthlyRate;
      final principalPaid = monthlyPayment - interest;
      remainingPrincipal -= principalPaid;

      // Fix any floating point errors on the last month
      if (month == months) {
        remainingPrincipal = 0;
      }

      result.add(MonthlyData(
        month: month,
        payment: monthlyPayment,
        principal: principalPaid,
        interest: interest,
        remainingPrincipal: remainingPrincipal < 0 ? 0 : remainingPrincipal,
      ));
    }

    return result;
  }

  /// Calculate equal principal repayment (等额本金)
  ///
  /// Monthly principal remains constant, interest decreases over time.
  /// Monthly payment = monthlyPrincipal + (remainingPrincipal * monthlyRate)
  ///
  /// [principal] - Total loan principal in yuan
  /// [monthlyRate] - Monthly interest rate as decimal
  /// [months] - Total number of months
  static List<MonthlyData> _calculateEqualPrincipal(
    double principal,
    double monthlyRate,
    int months,
  ) {
    if (months <= 0) {
      throw ArgumentError('Months must be greater than 0');
    }
    if (principal < 0) {
      throw ArgumentError('Principal cannot be negative');
    }
    if (monthlyRate < 0) {
      throw ArgumentError('Monthly rate cannot be negative');
    }

    final monthlyPrincipal = principal / months;
    final result = <MonthlyData>[];
    double remainingPrincipal = principal;

    for (int month = 1; month <= months; month++) {
      final interest = remainingPrincipal * monthlyRate;
      final payment = monthlyPrincipal + interest;
      remainingPrincipal -= monthlyPrincipal;

      // Fix any floating point errors on the last month
      if (month == months) {
        remainingPrincipal = 0;
      }

      result.add(MonthlyData(
        month: month,
        payment: payment,
        principal: monthlyPrincipal,
        interest: interest,
        remainingPrincipal: remainingPrincipal < 0 ? 0 : remainingPrincipal,
      ));
    }

    return result;
  }

  /// Calculate combined loan (组合贷)
  ///
  /// Commercial and provident fund loans are calculated separately
  /// and then merged by adding monthly payments together.
  static RepaymentResult _calculateCombined(LoanParams params) {
    final monthlyRate = params.monthlyRate;
    if (monthlyRate == null) {
      throw ArgumentError('Invalid interest rate');
    }

    final months = params.totalMonths;

    // Calculate commercial loan portion
    final commercialPrincipal = params.commercialAmount * 10000;
    final commercialData = params.repaymentMethod == RepaymentMethod.equalInterest
        ? _calculateEqualInterest(commercialPrincipal, monthlyRate, months)
        : _calculateEqualPrincipal(commercialPrincipal, monthlyRate, months);

    // Calculate provident fund loan portion
    final providentPrincipal = params.providentAmount * 10000;
    final providentData = params.repaymentMethod == RepaymentMethod.equalInterest
        ? _calculateEqualInterest(providentPrincipal, monthlyRate, months)
        : _calculateEqualPrincipal(providentPrincipal, monthlyRate, months);

    // Merge the two loan portions
    final mergedData = <MonthlyData>[];
    for (int i = 0; i < months; i++) {
      final commercial = commercialData[i];
      final provident = providentData[i];

      mergedData.add(MonthlyData(
        month: commercial.month,
        payment: commercial.payment + provident.payment,
        principal: commercial.principal + provident.principal,
        interest: commercial.interest + provident.interest,
        remainingPrincipal: commercial.remainingPrincipal + provident.remainingPrincipal,
      ));
    }

    final yearlyData = _groupByYear(mergedData);

    final totalPayment = mergedData.fold<double>(0, (sum, m) => sum + m.payment);
    final totalPrincipal = mergedData.fold<double>(0, (sum, m) => sum + m.principal);
    final totalInterest = mergedData.fold<double>(0, (sum, m) => sum + m.interest);

    return RepaymentResult(
      firstMonthPayment: mergedData.first.payment,
      lastMonthPayment: mergedData.last.payment,
      totalPayment: totalPayment,
      totalInterest: totalInterest,
      totalPrincipal: totalPrincipal,
      monthlyData: mergedData,
      yearlyData: yearlyData,
    );
  }

  /// Group monthly data into yearly summaries
  ///
  /// [monthlyData] - List of monthly repayment data
  /// Returns a list of [YearlyData] grouped by year
  static List<YearlyData> _groupByYear(List<MonthlyData> monthlyData) {
    if (monthlyData.isEmpty) return [];

    final yearlyMap = <int, List<MonthlyData>>{};

    for (final month in monthlyData) {
      final year = month.year;
      yearlyMap.putIfAbsent(year, () => []);
      yearlyMap[year]!.add(month);
    }

    final result = <YearlyData>[];
    for (final year in yearlyMap.keys.toList()..sort()) {
      final months = yearlyMap[year]!;
      final yearPayment = months.fold<double>(0, (sum, m) => sum + m.payment);
      final yearPrincipal = months.fold<double>(0, (sum, m) => sum + m.principal);
      final yearInterest = months.fold<double>(0, (sum, m) => sum + m.interest);

      result.add(YearlyData(
        year: year,
        yearPayment: yearPayment,
        yearPrincipal: yearPrincipal,
        yearInterest: yearInterest,
        monthlyData: months,
      ));
    }

    return result;
  }

  /// Calculate x raised to the power of n
  ///
  /// Simple loop implementation for pow(x, n)
  /// [x] - Base number
  /// [n] - Exponent (must be non-negative)
  static double pow(double x, int n) {
    if (n < 0) {
      throw ArgumentError('Negative exponents not supported');
    }
    if (n == 0) return 1;

    double result = 1;
    for (int i = 0; i < n; i++) {
      result *= x;
    }
    return result;
  }
}
