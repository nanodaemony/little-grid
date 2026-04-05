// Loan Enums for House Money Calculator
// Defines enums for repayment methods, loan types, and interest rate types

/// Repayment method for mortgage loans
enum RepaymentMethod {
  equalInterest,
  equalPrincipal,
}

/// Extension for RepaymentMethod to provide UI labels and descriptions
extension RepaymentMethodExtension on RepaymentMethod {
  /// Chinese label for the repayment method
  String get label {
    switch (this) {
      case RepaymentMethod.equalInterest:
        return '等额本息';
      case RepaymentMethod.equalPrincipal:
        return '等额本金';
    }
  }

  /// Description explaining the repayment method characteristics
  String get description {
    switch (this) {
      case RepaymentMethod.equalInterest:
        return '月供固定，前期利息多';
      case RepaymentMethod.equalPrincipal:
        return '逐月递减，总利息少';
    }
  }
}

/// Type of loan available for mortgage
enum LoanType {
  commercial,
  provident,
  combined,
}

/// Extension for LoanType to provide UI labels
extension LoanTypeExtension on LoanType {
  /// Chinese label for the loan type
  String get label {
    switch (this) {
      case LoanType.commercial:
        return '商业贷款';
      case LoanType.provident:
        return '公积金贷款';
      case LoanType.combined:
        return '组合贷';
    }
  }
}

/// Type of interest rate calculation
enum InterestRateType {
  fixed,
  lprFloating,
}

/// Extension for InterestRateType to provide UI labels
extension InterestRateTypeExtension on InterestRateType {
  /// Chinese label for the interest rate type
  String get label {
    switch (this) {
      case InterestRateType.fixed:
        return '固定利率';
      case InterestRateType.lprFloating:
        return 'LPR浮动';
    }
  }
}
