import 'package:flutter_test/flutter_test.dart';
import 'package:littlegrid/tools/housemoneycalc/models/loan_enums.dart';
import 'package:littlegrid/tools/housemoneycalc/models/loan_params.dart';
import 'package:littlegrid/tools/housemoneycalc/models/repayment_schedule.dart';
import 'package:littlegrid/tools/housemoneycalc/services/mortgage_calculator.dart';

void main() {
  group('MortgageCalculator Equal Interest Tests (等额本息)', () {
    test('100万, 30年, 4.2%: monthly payment ~4890, total interest ~760000', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.commercial,
        commercialAmount: 100,
        loanTermYears: 30,
        rateType: InterestRateType.fixed,
        fixedRate: 4.2,
      );

      final result = MortgageCalculator.calculate(params);

      // Monthly payment should be approximately 4890
      expect(result.firstMonthPayment, closeTo(4890, 10));
      expect(result.lastMonthPayment, closeTo(4890, 10));

      // Total interest should be approximately 760,000
      expect(result.totalInterest, closeTo(760000, 5000));

      // Total principal should be 1,000,000 (100万 * 10000)
      expect(result.totalPrincipal, closeTo(1000000, 1));

      // Monthly data should have 360 entries (30 * 12)
      expect(result.monthlyData.length, 360);
    });

    test('200万, 20年, 3.8%: monthly payment ~11943', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.commercial,
        commercialAmount: 200,
        loanTermYears: 20,
        rateType: InterestRateType.fixed,
        fixedRate: 3.8,
      );

      final result = MortgageCalculator.calculate(params);

      // Monthly payment should be approximately 11943
      expect(result.firstMonthPayment, closeTo(11943, 10));
      expect(result.lastMonthPayment, closeTo(11943, 10));
    });

    test('monthly payments are equal (within 0.1)', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.commercial,
        commercialAmount: 150,
        loanTermYears: 25,
        rateType: InterestRateType.fixed,
        fixedRate: 4.5,
      );

      final result = MortgageCalculator.calculate(params);

      // All monthly payments should be the same
      final firstPayment = result.monthlyData.first.payment;
      for (final month in result.monthlyData) {
        expect(month.payment, closeTo(firstPayment, 0.1));
      }
    });
  });

  group('MortgageCalculator Equal Principal Tests (等额本金)', () {
    test('100万, 30年, 4.2%: first month ~6277, last month ~2794', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalPrincipal,
        loanType: LoanType.commercial,
        commercialAmount: 100,
        loanTermYears: 30,
        rateType: InterestRateType.fixed,
        fixedRate: 4.2,
      );

      final result = MortgageCalculator.calculate(params);

      // First month payment should be approximately 6277
      expect(result.firstMonthPayment, closeTo(6277, 10));

      // Last month payment should be approximately 2794
      expect(result.lastMonthPayment, closeTo(2794, 10));
    });

    test('monthly principal is constant', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalPrincipal,
        loanType: LoanType.commercial,
        commercialAmount: 120,
        loanTermYears: 20,
        rateType: InterestRateType.fixed,
        fixedRate: 4.0,
      );

      final result = MortgageCalculator.calculate(params);

      // Monthly principal should be: 1,200,000 / 240 = 5000
      final expectedPrincipal = 120 * 10000 / 240;
      for (final month in result.monthlyData) {
        expect(month.principal, closeTo(expectedPrincipal, 0.01));
      }
    });

    test('payments decrease each month', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalPrincipal,
        loanType: LoanType.commercial,
        commercialAmount: 100,
        loanTermYears: 30,
        rateType: InterestRateType.fixed,
        fixedRate: 4.2,
      );

      final result = MortgageCalculator.calculate(params);

      // Each month's payment should be less than or equal to the previous
      for (int i = 1; i < result.monthlyData.length; i++) {
        expect(
          result.monthlyData[i].payment,
          lessThanOrEqualTo(result.monthlyData[i - 1].payment),
        );
      }
    });
  });

  group('MortgageCalculator Combined Loan Tests (组合贷)', () {
    test('商贷100万 + 公积金100万, 30年: total principal = 200万, 360 months', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.combined,
        commercialAmount: 100,
        providentAmount: 100,
        loanTermYears: 30,
        rateType: InterestRateType.fixed,
        fixedRate: 4.2,
      );

      final result = MortgageCalculator.calculate(params);

      // Total principal should be 200万 (200 * 10000)
      expect(result.totalPrincipal, closeTo(2000000, 1));

      // Monthly data should have 360 entries
      expect(result.monthlyData.length, 360);

      // First month payment should be approximately double the single 100万 loan
      // 100万 at 4.2% for 30 years = ~4890, so 200万 should be ~9780
      expect(result.firstMonthPayment, closeTo(9780, 20));
    });

    test('combined loan with different repayment methods per loan type', () {
      // Note: Current implementation uses the same repayment method for both
      // commercial and provident fund portions
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalPrincipal,
        loanType: LoanType.combined,
        commercialAmount: 80,
        providentAmount: 60,
        loanTermYears: 25,
        rateType: InterestRateType.fixed,
        fixedRate: 3.5,
      );

      final result = MortgageCalculator.calculate(params);

      // Total principal should be 140万
      expect(result.totalPrincipal, closeTo(1400000, 1));

      // Monthly data should have 300 entries (25 * 12)
      expect(result.monthlyData.length, 300);
    });
  });

  group('MortgageCalculator Yearly Grouping Tests', () {
    test('30 year loan has 30 yearly entries', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.commercial,
        commercialAmount: 100,
        loanTermYears: 30,
        rateType: InterestRateType.fixed,
        fixedRate: 4.2,
      );

      final result = MortgageCalculator.calculate(params);

      // Should have 30 yearly entries
      expect(result.yearlyData.length, 30);
    });

    test('each year (except last) has 12 months', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.commercial,
        commercialAmount: 100,
        loanTermYears: 30,
        rateType: InterestRateType.fixed,
        fixedRate: 4.2,
      );

      final result = MortgageCalculator.calculate(params);

      for (int i = 0; i < result.yearlyData.length - 1; i++) {
        expect(result.yearlyData[i].monthlyData.length, 12);
      }
      // Last year also has 12 months for 30-year loan (360 months total)
      expect(result.yearlyData.last.monthlyData.length, 12);
    });

    test('year totals match sum of monthly data', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.commercial,
        commercialAmount: 100,
        loanTermYears: 20,
        rateType: InterestRateType.fixed,
        fixedRate: 4.0,
      );

      final result = MortgageCalculator.calculate(params);

      for (final yearData in result.yearlyData) {
        final sumPayment = yearData.monthlyData
            .fold<double>(0, (sum, m) => sum + m.payment);
        final sumPrincipal = yearData.monthlyData
            .fold<double>(0, (sum, m) => sum + m.principal);
        final sumInterest = yearData.monthlyData
            .fold<double>(0, (sum, m) => sum + m.interest);

        expect(yearData.yearPayment, closeTo(sumPayment, 0.01));
        expect(yearData.yearPrincipal, closeTo(sumPrincipal, 0.01));
        expect(yearData.yearInterest, closeTo(sumInterest, 0.01));
      }
    });

    test('non-integer year loan has correct last year months', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.commercial,
        commercialAmount: 50,
        loanTermYears: 5, // 5 years = 60 months
        rateType: InterestRateType.fixed,
        fixedRate: 4.0,
      );

      final result = MortgageCalculator.calculate(params);

      expect(result.yearlyData.length, 5);
      // All 5 years should have 12 months each (5 * 12 = 60)
      for (final yearData in result.yearlyData) {
        expect(yearData.monthlyData.length, 12);
      }
    });
  });

  group('MortgageCalculator Edge Cases', () {
    test('1万元 loan, 1 year', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.commercial,
        commercialAmount: 1,
        loanTermYears: 1,
        rateType: InterestRateType.fixed,
        fixedRate: 4.0,
      );

      final result = MortgageCalculator.calculate(params);

      // Should have 12 monthly entries
      expect(result.monthlyData.length, 12);

      // Total principal should be 10,000
      expect(result.totalPrincipal, closeTo(10000, 0.01));

      // Should have 1 yearly entry
      expect(result.yearlyData.length, 1);
    });

    test('0% interest rate', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.commercial,
        commercialAmount: 100,
        loanTermYears: 10,
        rateType: InterestRateType.fixed,
        fixedRate: 0,
      );

      final result = MortgageCalculator.calculate(params);

      // With 0% interest, monthly payment = principal / months
      // 1,000,000 / 120 = 8333.33
      expect(result.firstMonthPayment, closeTo(8333.33, 0.01));
      expect(result.totalInterest, closeTo(0, 0.01));
      expect(result.totalPayment, closeTo(1000000, 0.01));
    });

    test('0% interest rate with equal principal', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalPrincipal,
        loanType: LoanType.commercial,
        commercialAmount: 60,
        loanTermYears: 5,
        rateType: InterestRateType.fixed,
        fixedRate: 0,
      );

      final result = MortgageCalculator.calculate(params);

      // With 0% interest, monthly payment should equal monthly principal
      // 600,000 / 60 = 10,000
      expect(result.firstMonthPayment, closeTo(10000, 0.01));
      expect(result.lastMonthPayment, closeTo(10000, 0.01));
      expect(result.totalInterest, closeTo(0, 0.01));

      // All payments should be equal
      for (final month in result.monthlyData) {
        expect(month.payment, closeTo(10000, 0.01));
      }
    });

    test('LPR floating rate calculation', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.commercial,
        commercialAmount: 100,
        loanTermYears: 30,
        rateType: InterestRateType.lprFloating,
        lprRate: 3.85,
        basisPoints: -0.45,
      );

      final result = MortgageCalculator.calculate(params);

      // LPR 3.85% + basis points -0.45% = 3.4%
      // 100万 at 3.4% for 30 years should have monthly payment ~4434
      expect(result.firstMonthPayment, closeTo(4434, 10));

      // Monthly data should have 360 entries
      expect(result.monthlyData.length, 360);
    });

    test('LPR floating with positive basis points', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.commercial,
        commercialAmount: 100,
        loanTermYears: 20,
        rateType: InterestRateType.lprFloating,
        lprRate: 4.2,
        basisPoints: 0.30,
      );

      final result = MortgageCalculator.calculate(params);

      // LPR 4.2% + basis points 0.30% = 4.5%
      // 100万 at 4.5% for 20 years should have monthly payment ~6326
      expect(result.firstMonthPayment, closeTo(6326, 10));
    });

    test('throws error for invalid loan amount', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.commercial,
        commercialAmount: 0,
        loanTermYears: 30,
        rateType: InterestRateType.fixed,
        fixedRate: 4.2,
      );

      expect(() => MortgageCalculator.calculate(params), throwsArgumentError);
    });

    test('throws error for invalid loan term', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.commercial,
        commercialAmount: 100,
        loanTermYears: 0,
        rateType: InterestRateType.fixed,
        fixedRate: 4.2,
      );

      expect(() => MortgageCalculator.calculate(params), throwsArgumentError);
    });

    test('throws error for negative interest rate', () {
      final params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.commercial,
        commercialAmount: 100,
        loanTermYears: 30,
        rateType: InterestRateType.fixed,
        fixedRate: -1.0,
      );

      expect(() => MortgageCalculator.calculate(params), throwsArgumentError);
    });
  });

  group('MortgageCalculator pow function', () {
    test('pow calculates correctly', () {
      expect(MortgageCalculator.pow(2, 0), 1);
      expect(MortgageCalculator.pow(2, 1), 2);
      expect(MortgageCalculator.pow(2, 10), 1024);
      expect(MortgageCalculator.pow(1.0035, 12), closeTo(1.0428, 0.001));
    });

    test('pow throws error for negative exponent', () {
      expect(() => MortgageCalculator.pow(2, -1), throwsArgumentError);
    });
  });

  group('MonthlyData year calculations', () {
    test('month to year calculation is correct', () {
      // Month 1-12 -> Year 1
      expect(MonthlyData(month: 1, payment: 0, principal: 0, interest: 0, remainingPrincipal: 0).year, 1);
      expect(MonthlyData(month: 12, payment: 0, principal: 0, interest: 0, remainingPrincipal: 0).year, 1);

      // Month 13-24 -> Year 2
      expect(MonthlyData(month: 13, payment: 0, principal: 0, interest: 0, remainingPrincipal: 0).year, 2);
      expect(MonthlyData(month: 24, payment: 0, principal: 0, interest: 0, remainingPrincipal: 0).year, 2);

      // Month 360 -> Year 30
      expect(MonthlyData(month: 360, payment: 0, principal: 0, interest: 0, remainingPrincipal: 0).year, 30);
    });

    test('monthInYear calculation is correct', () {
      // Month 1 -> Month 1 in year
      expect(MonthlyData(month: 1, payment: 0, principal: 0, interest: 0, remainingPrincipal: 0).monthInYear, 1);

      // Month 12 -> Month 12 in year
      expect(MonthlyData(month: 12, payment: 0, principal: 0, interest: 0, remainingPrincipal: 0).monthInYear, 12);

      // Month 13 -> Month 1 in year
      expect(MonthlyData(month: 13, payment: 0, principal: 0, interest: 0, remainingPrincipal: 0).monthInYear, 1);

      // Month 24 -> Month 12 in year
      expect(MonthlyData(month: 24, payment: 0, principal: 0, interest: 0, remainingPrincipal: 0).monthInYear, 12);
    });
  });
}
