class MonthlyTaxDetail {
  final int month;
  final double cumulativeTaxable;
  final double cumulativeTax;
  final double monthlyTax;
  final double monthlyAfterTax;

  MonthlyTaxDetail({
    required this.month,
    required this.cumulativeTaxable,
    required this.cumulativeTax,
    required this.monthlyTax,
    required this.monthlyAfterTax,
  });
}

class SalaryResult {
  final double preTaxSalary;
  final double totalInsurance;
  final double pension;
  final double medical;
  final double unemployment;
  final double housingFund;
  final double totalDeduction;
  final Map<String, double> deductions;
  final double taxableIncome;
  final double totalTax;
  final double afterTaxSalary;
  final List<MonthlyTaxDetail> monthlyDetails;

  SalaryResult({
    required this.preTaxSalary,
    required this.totalInsurance,
    required this.pension,
    required this.medical,
    required this.unemployment,
    required this.housingFund,
    required this.totalDeduction,
    required this.deductions,
    required this.taxableIncome,
    required this.totalTax,
    required this.afterTaxSalary,
    required this.monthlyDetails,
  });
}
