import 'package:meta/meta.dart';
import 'loan_enums.dart';

/// Loan parameters data model for mortgage calculations
///
/// Contains all input parameters needed to calculate mortgage payments,
/// including repayment method, loan amounts, term, and interest rate details.
@immutable
class LoanParams {
  final RepaymentMethod repaymentMethod;
  final LoanType loanType;
  final double commercialAmount; // 万元
  final double providentAmount; // 万元, default 0
  final int loanTermYears; // 1-30年
  final InterestRateType rateType;
  final double? fixedRate; // %, nullable
  final double? lprRate; // %, nullable
  final double? basisPoints; // %, nullable

  const LoanParams({
    required this.repaymentMethod,
    required this.loanType,
    required this.commercialAmount,
    this.providentAmount = 0,
    required this.loanTermYears,
    required this.rateType,
    this.fixedRate,
    this.lprRate,
    this.basisPoints,
  });

  /// Total loan amount in 万元
  double get totalAmount => commercialAmount + providentAmount;

  /// Actual annual interest rate as percentage
  /// Returns fixedRate if rateType is fixed,
  /// otherwise returns lprRate + basisPoints
  double? get annualRate {
    switch (rateType) {
      case InterestRateType.fixed:
        return fixedRate;
      case InterestRateType.lprFloating:
        if (lprRate != null && basisPoints != null) {
          return lprRate! + basisPoints!;
        }
        return null;
    }
  }

  /// Monthly interest rate as decimal (e.g., 0.003 for 0.3%)
  double? get monthlyRate {
    final rate = annualRate;
    if (rate == null) return null;
    return rate / 100 / 12;
  }

  /// Total number of months for the loan term
  int get totalMonths => loanTermYears * 12;

  /// Creates a copy of this LoanParams with the given fields replaced
  LoanParams copyWith({
    RepaymentMethod? repaymentMethod,
    LoanType? loanType,
    double? commercialAmount,
    double? providentAmount,
    int? loanTermYears,
    InterestRateType? rateType,
    double? fixedRate,
    double? lprRate,
    double? basisPoints,
  }) {
    return LoanParams(
      repaymentMethod: repaymentMethod ?? this.repaymentMethod,
      loanType: loanType ?? this.loanType,
      commercialAmount: commercialAmount ?? this.commercialAmount,
      providentAmount: providentAmount ?? this.providentAmount,
      loanTermYears: loanTermYears ?? this.loanTermYears,
      rateType: rateType ?? this.rateType,
      fixedRate: fixedRate ?? this.fixedRate,
      lprRate: lprRate ?? this.lprRate,
      basisPoints: basisPoints ?? this.basisPoints,
    );
  }
}
