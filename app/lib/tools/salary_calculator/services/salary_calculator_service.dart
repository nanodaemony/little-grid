import '../models/city_config.dart';
import '../models/salary_result.dart';

class TaxBracket {
  final double minIncome;
  final double? maxIncome;
  final double rate;
  final double quickDeduction;

  TaxBracket({
    required this.minIncome,
    this.maxIncome,
    required this.rate,
    required this.quickDeduction,
  });
}

class SalaryCalculatorService {
  static const double threshold = 5000;

  static final List<TaxBracket> taxBrackets = [
    TaxBracket(minIncome: 0, maxIncome: 36000, rate: 0.03, quickDeduction: 0),
    TaxBracket(minIncome: 36000, maxIncome: 144000, rate: 0.10, quickDeduction: 2520),
    TaxBracket(minIncome: 144000, maxIncome: 300000, rate: 0.20, quickDeduction: 16920),
    TaxBracket(minIncome: 300000, maxIncome: 420000, rate: 0.25, quickDeduction: 31920),
    TaxBracket(minIncome: 420000, maxIncome: 660000, rate: 0.30, quickDeduction: 52920),
    TaxBracket(minIncome: 660000, maxIncome: 960000, rate: 0.35, quickDeduction: 85920),
    TaxBracket(minIncome: 960000, maxIncome: null, rate: 0.45, quickDeduction: 181920),
  ];

  static double calculateTax(double cumulativeTaxable) {
    if (cumulativeTaxable <= 0) return 0;

    for (final bracket in taxBrackets) {
      if (bracket.maxIncome == null || cumulativeTaxable < bracket.maxIncome!) {
        return cumulativeTaxable * bracket.rate - bracket.quickDeduction;
      }
    }
    return cumulativeTaxable * 0.45 - 181920;
  }

  static double clampInRange(double value, double min, double max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  static SalaryResult calculate({
    required double preTaxSalary,
    required CityConfig cityConfig,
    required Map<String, double> deductions,
  }) {
    // 计算五险一金
    final pensionBase = clampInRange(preTaxSalary, cityConfig.pensionBase, cityConfig.pensionBaseMax);
    final pension = pensionBase * cityConfig.pensionRate;

    final medicalBase = clampInRange(preTaxSalary, cityConfig.pensionBase, cityConfig.pensionBaseMax);
    final medical = medicalBase * cityConfig.medicalRate;

    final unemploymentBase = clampInRange(preTaxSalary, cityConfig.pensionBase, cityConfig.pensionBaseMax);
    final unemployment = unemploymentBase * cityConfig.unemploymentRate;

    final housingFundBase = clampInRange(preTaxSalary, cityConfig.housingFundBase, cityConfig.housingFundBaseMax);
    final housingFund = housingFundBase * cityConfig.housingFundRate;

    final totalInsurance = pension + medical + unemployment + housingFund;

    // 计算专项附加扣除总额
    final totalDeduction = deductions.values.fold<double>(0, (sum, value) => sum + value);

    // 单月应纳税所得额
    final monthlyTaxable = preTaxSalary - threshold - totalInsurance - totalDeduction;

    // 计算12个月明细（累计预扣法）
    final monthlyDetails = <MonthlyTaxDetail>[];
    double cumulativeTaxable = 0;
    double cumulativeTax = 0;

    for (int month = 1; month <= 12; month++) {
      cumulativeTaxable += monthlyTaxable;
      final newCumulativeTax = calculateTax(cumulativeTaxable);
      final monthlyTax = newCumulativeTax - cumulativeTax;
      cumulativeTax = newCumulativeTax;

      final monthlyAfterTax = preTaxSalary - totalInsurance - monthlyTax;

      monthlyDetails.add(MonthlyTaxDetail(
        month: month,
        cumulativeTaxable: cumulativeTaxable,
        cumulativeTax: cumulativeTax,
        monthlyTax: monthlyTax,
        monthlyAfterTax: monthlyAfterTax,
      ));
    }

    final totalTax = cumulativeTax;
    final afterTaxSalary = preTaxSalary - totalInsurance - (totalTax / 12);
    final taxableIncome = monthlyTaxable;

    return SalaryResult(
      preTaxSalary: preTaxSalary,
      totalInsurance: totalInsurance,
      pension: pension,
      medical: medical,
      unemployment: unemployment,
      housingFund: housingFund,
      totalDeduction: totalDeduction,
      deductions: deductions,
      taxableIncome: taxableIncome,
      totalTax: totalTax,
      afterTaxSalary: afterTaxSalary,
      monthlyDetails: monthlyDetails,
    );
  }
}
