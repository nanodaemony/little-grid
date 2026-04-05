import 'package:flutter/material.dart';
import '../models/bmi_result.dart';

class BMIService {
  static BMIResult calculate(double heightCm, double weightKg) {
    if (heightCm <= 0 || weightKg <= 0) {
      throw ArgumentError('Height and weight must be greater than 0');
    }

    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);

    BMIStatus status;
    String advice;

    if (bmi < 18.5) {
      status = BMIStatus.Underweight;
      advice = "您的体重偏轻，建议适当增加营养摄入，多做增肌运动。";
    } else if (bmi < 24) {
      status = BMIStatus.Normal;
      advice = "您的体重在健康范围内，请继续保持良好的生活习惯。";
    } else if (bmi < 28) {
      status = BMIStatus.Overweight;
      advice = "您的体重偏重，建议控制饮食，增加运动量。";
    } else {
      status = BMIStatus.Obese;
      advice = "您的体重属于肥胖范围，建议咨询专业医生制定减肥计划。";
    }

    // 计算理想体重范围（BMI 18.5-24）
    final minWeight = 18.5 * heightM * heightM;
    final maxWeight = 24 * heightM * heightM;

    return BMIResult(
      bmi: bmi,
      height: heightCm,
      weight: weightKg,
      status: status,
      advice: advice,
      minWeight: minWeight,
      maxWeight: maxWeight,
    );
  }

  static Color getStatusColor(BMIStatus status) {
    switch (status) {
      case BMIStatus.Underweight:
        return const Color(0xFF2196F3); // Blue
      case BMIStatus.Normal:
        return const Color(0xFF4CAF50); // Green
      case BMIStatus.Overweight:
        return const Color(0xFFFF9800); // Orange
      case BMIStatus.Obese:
        return const Color(0xFFF44336); // Red
    }
  }

  static String getStatusText(BMIStatus status) {
    switch (status) {
      case BMIStatus.Underweight:
        return '偏瘦';
      case BMIStatus.Normal:
        return '正常';
      case BMIStatus.Overweight:
        return '超重';
      case BMIStatus.Obese:
        return '肥胖';
    }
  }
}