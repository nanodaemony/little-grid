enum BMIStatus {
  Underweight,   // < 18.5
  Normal,        // 18.5 - 24
  Overweight,    // 24 - 28
  Obese          // >= 28
}

class BMIResult {
  final double bmi;
  final double height;
  final double weight;
  final BMIStatus status;
  final String advice;
  final double minWeight;
  final double maxWeight;

  BMIResult({
    required this.bmi,
    required this.height,
    required this.weight,
    required this.status,
    required this.advice,
    required this.minWeight,
    required this.maxWeight,
  });
}
