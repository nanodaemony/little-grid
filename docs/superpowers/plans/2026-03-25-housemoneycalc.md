# 房贷计算器实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现一个功能完整的房贷计算器，支持等额本息/等额本金、商业贷/公积金/组合贷、固定利率/LPR浮动利率，包含还款计划表和图表可视化。

**Architecture:** 采用分步向导式UI，数据层使用不可变数据类，计算层使用纯函数服务，UI层使用StatefulWidget管理状态。遵循现有工具模式（如rmbconvertor）。

**Tech Stack:** Flutter, Dart, fl_chart (图表库)

---

## 文件结构

```
app/lib/tools/housemoneycalc/
├── housemoneycalc_tool.dart          # ToolModule 实现
├── housemoneycalc_page.dart          # 主页面（分步向导容器）
├── models/
│   ├── loan_enums.dart               # 枚举定义（还款方式、贷款类型、利率类型）
│   ├── loan_params.dart              # 贷款参数数据类
│   ├── repayment_result.dart         # 计算结果数据类
│   └── repayment_schedule.dart       # 还款计划数据类（月度/年度）
├── services/
│   └── mortgage_calculator.dart      # 核心计算服务
└── test/
    └── housemoneycalc_test.dart      # 单元测试
```

**需要修改的文件：**
- `app/pubspec.yaml` - 添加 fl_chart 依赖
- `app/lib/main.dart` - 注册工具

---

## Task 1: 添加依赖项

**Files:**
- Modify: `app/pubspec.yaml`

- [ ] **Step 1: 添加 fl_chart 依赖**

在 `dependencies:` 部分添加：

```yaml
  fl_chart: ^0.66.0
```

- [ ] **Step 2: Commit**

```bash
cd app
git add pubspec.yaml
git commit -m "deps: add fl_chart for mortgage calculator charts"
```

---

## Task 2: 创建枚举定义

**Files:**
- Create: `app/lib/tools/housemoneycalc/models/loan_enums.dart`

- [ ] **Step 1: 创建枚举文件**

```dart
/// 还款方式
enum RepaymentMethod {
  /// 等额本息 - 每月还款额固定
  equalInterest,
  /// 等额本金 - 每月本金固定，月供递减
  equalPrincipal,
}

extension RepaymentMethodExtension on RepaymentMethod {
  String get label {
    switch (this) {
      case RepaymentMethod.equalInterest:
        return '等额本息';
      case RepaymentMethod.equalPrincipal:
        return '等额本金';
    }
  }

  String get description {
    switch (this) {
      case RepaymentMethod.equalInterest:
        return '月供固定，前期利息多';
      case RepaymentMethod.equalPrincipal:
        return '逐月递减，总利息少';
    }
  }
}

/// 贷款类型
enum LoanType {
  /// 商业贷款
  commercial,
  /// 公积金贷款
  provident,
  /// 组合贷
  combined,
}

extension LoanTypeExtension on LoanType {
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

/// 利率类型
enum InterestRateType {
  /// 固定利率
  fixed,
  /// LPR浮动利率
  lprFloating,
}

extension InterestRateTypeExtension on InterestRateType {
  String get label {
    switch (this) {
      case InterestRateType.fixed:
        return '固定利率';
      case InterestRateType.lprFloating:
        return 'LPR浮动';
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/housemoneycalc/models/loan_enums.dart
git commit -m "feat(housemoneycalc): add loan enums for repayment method, loan type and rate type"
```

---

## Task 3: 创建数据模型 - LoanParams

**Files:**
- Create: `app/lib/tools/housemoneycalc/models/loan_params.dart`

- [ ] **Step 1: 创建 LoanParams 类**

```dart
import 'loan_enums.dart';

/// 贷款参数
class LoanParams {
  /// 还款方式
  final RepaymentMethod repaymentMethod;

  /// 贷款类型
  final LoanType loanType;

  /// 商业贷款金额（万元）
  final double commercialAmount;

  /// 公积金贷款金额（万元），非组合贷时为0
  final double providentAmount;

  /// 贷款期限（年）
  final int loanTermYears;

  /// 利率类型
  final InterestRateType rateType;

  /// 固定利率值（%），仅固定利率时有效
  final double? fixedRate;

  /// LPR基准利率（%），仅LPR浮动时有效
  final double? lprRate;

  /// 加减基点（%），仅LPR浮动时有效
  final double? basisPoints;

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

  /// 获取总贷款金额（万元）
  double get totalAmount => commercialAmount + providentAmount;

  /// 获取实际年利率（%）
  double get annualRate {
    if (rateType == InterestRateType.fixed) {
      return fixedRate ?? 0;
    } else {
      return (lprRate ?? 0) + (basisPoints ?? 0);
    }
  }

  /// 获取月利率（小数形式，如0.00325表示3.25‰）
  double get monthlyRate => annualRate / 100 / 12;

  /// 获取还款月数
  int get totalMonths => loanTermYears * 12;

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
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/housemoneycalc/models/loan_params.dart
git commit -m "feat(housemoneycalc): add LoanParams data model"
```

---

## Task 4: 创建数据模型 - RepaymentSchedule

**Files:**
- Create: `app/lib/tools/housemoneycalc/models/repayment_schedule.dart`

- [ ] **Step 1: 创建月度/年度数据类**

```dart
/// 月度还款数据
class MonthlyData {
  /// 第几月（从1开始）
  final int month;

  /// 月供金额
  final double payment;

  /// 本金部分
  final double principal;

  /// 利息部分
  final double interest;

  /// 剩余本金
  final double remainingPrincipal;

  const MonthlyData({
    required this.month,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.remainingPrincipal,
  });

  /// 获取年份（从1开始）
  int get year => ((month - 1) / 12).floor() + 1;

  /// 获取该年的第几个月（1-12）
  int get monthInYear => ((month - 1) % 12) + 1;
}

/// 年度还款汇总
class YearlyData {
  /// 第几年（从1开始）
  final int year;

  /// 年度还款总额
  final double yearPayment;

  /// 年度本金
  final double yearPrincipal;

  /// 年度利息
  final double yearInterest;

  /// 该年逐月明细
  final List<MonthlyData> monthlyData;

  const YearlyData({
    required this.year,
    required this.yearPayment,
    required this.yearPrincipal,
    required this.yearInterest,
    required this.monthlyData,
  });
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/housemoneycalc/models/repayment_schedule.dart
git commit -m "feat(housemoneycalc): add MonthlyData and YearlyData models"
```

---

## Task 5: 创建数据模型 - RepaymentResult

**Files:**
- Create: `app/lib/tools/housemoneycalc/models/repayment_result.dart`

- [ ] **Step 1: 创建 RepaymentResult 类**

```dart
import 'repayment_schedule.dart';

/// 还款计算结果
class RepaymentResult {
  /// 首月月供
  final double firstMonthPayment;

  /// 末月月供（等额本金时与首月不同）
  final double lastMonthPayment;

  /// 总还款额
  final double totalPayment;

  /// 总利息
  final double totalInterest;

  /// 总本金
  final double totalPrincipal;

  /// 逐月数据
  final List<MonthlyData> monthlyData;

  /// 年度汇总
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

  /// 获取月供平均值
  double get averageMonthlyPayment => totalPayment / monthlyData.length;
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/housemoneycalc/models/repayment_result.dart
git commit -m "feat(housemoneycalc): add RepaymentResult data model"
```

---

## Task 6: 创建核心计算服务

**Files:**
- Create: `app/lib/tools/housemoneycalc/services/mortgage_calculator.dart`

- [ ] **Step 1: 创建 MortgageCalculator 服务**

```dart
import '../models/loan_enums.dart';
import '../models/loan_params.dart';
import '../models/repayment_result.dart';
import '../models/repayment_schedule.dart';

/// 房贷计算器服务
class MortgageCalculator {
  /// 计算还款计划
  static RepaymentResult calculate(LoanParams params) {
    if (params.loanType == LoanType.combined) {
      return _calculateCombined(params);
    }

    final monthlyData = _calculateMonthlyData(params);
    final yearlyData = _groupByYear(monthlyData);

    final totalPayment = monthlyData.fold<double>(
      0,
      (sum, data) => sum + data.payment,
    );
    final totalInterest = monthlyData.fold<double>(
      0,
      (sum, data) => sum + data.interest,
    );

    return RepaymentResult(
      firstMonthPayment: monthlyData.first.payment,
      lastMonthPayment: monthlyData.last.payment,
      totalPayment: totalPayment,
      totalInterest: totalInterest,
      totalPrincipal: params.totalAmount * 10000, // 转换为元
      monthlyData: monthlyData,
      yearlyData: yearlyData,
    );
  }

  /// 计算逐月数据
  static List<MonthlyData> _calculateMonthlyData(LoanParams params) {
    final principal = params.totalAmount * 10000; // 万元转元
    final monthlyRate = params.monthlyRate;
    final months = params.totalMonths;

    if (params.repaymentMethod == RepaymentMethod.equalInterest) {
      return _calculateEqualInterest(principal, monthlyRate, months);
    } else {
      return _calculateEqualPrincipal(principal, monthlyRate, months);
    }
  }

  /// 等额本息计算
  /// 月供 = [本金 × 月利率 × (1+月利率)^月数] / [(1+月利率)^月数 - 1]
  static List<MonthlyData> _calculateEqualInterest(
    double principal,
    double monthlyRate,
    int months,
  ) {
    final List<MonthlyData> result = [];

    // 月利率为0时的特殊处理
    double monthlyPayment;
    if (monthlyRate == 0) {
      monthlyPayment = principal / months;
    } else {
      final factor = pow(1 + monthlyRate, months);
      monthlyPayment = (principal * monthlyRate * factor) / (factor - 1);
    }

    double remainingPrincipal = principal;

    for (int month = 1; month <= months; month++) {
      final interest = remainingPrincipal * monthlyRate;
      final principalPart = monthlyPayment - interest;
      remainingPrincipal -= principalPart;

      // 最后一个月修正剩余本金为0
      if (month == months) {
        remainingPrincipal = 0;
      }

      result.add(MonthlyData(
        month: month,
        payment: monthlyPayment,
        principal: principalPart,
        interest: interest,
        remainingPrincipal: remainingPrincipal > 0 ? remainingPrincipal : 0,
      ));
    }

    return result;
  }

  /// 等额本金计算
  /// 每月本金 = 本金 / 月数
  /// 第n月利息 = (本金 - 每月本金 × (n-1)) × 月利率
  static List<MonthlyData> _calculateEqualPrincipal(
    double principal,
    double monthlyRate,
    int months,
  ) {
    final List<MonthlyData> result = [];
    final monthlyPrincipal = principal / months;
    double remainingPrincipal = principal;

    for (int month = 1; month <= months; month++) {
      final interest = remainingPrincipal * monthlyRate;
      final payment = monthlyPrincipal + interest;
      remainingPrincipal -= monthlyPrincipal;

      // 最后一个月修正剩余本金为0
      if (month == months) {
        remainingPrincipal = 0;
      }

      result.add(MonthlyData(
        month: month,
        payment: payment,
        principal: monthlyPrincipal,
        interest: interest,
        remainingPrincipal: remainingPrincipal > 0 ? remainingPrincipal : 0,
      ));
    }

    return result;
  }

  /// 组合贷计算（分别计算后合并）
  static RepaymentResult _calculateCombined(LoanParams params) {
    // 商业贷款部分
    final commercialParams = LoanParams(
      repaymentMethod: params.repaymentMethod,
      loanType: LoanType.commercial,
      commercialAmount: params.commercialAmount,
      loanTermYears: params.loanTermYears,
      rateType: params.rateType,
      fixedRate: params.fixedRate,
      lprRate: params.lprRate,
      basisPoints: params.basisPoints,
    );

    // 公积金贷款部分
    // 假设公积金利率比商业利率低1%
    final providentRate = params.annualRate - 1.0;
    final providentParams = LoanParams(
      repaymentMethod: params.repaymentMethod,
      loanType: LoanType.provident,
      commercialAmount: params.providentAmount,
      loanTermYears: params.loanTermYears,
      rateType: InterestRateType.fixed,
      fixedRate: providentRate > 0 ? providentRate : 2.85, // 默认公积金利率
    );

    final commercialData = _calculateMonthlyData(commercialParams);
    final providentData = _calculateMonthlyData(providentParams);

    // 合并每月数据
    final List<MonthlyData> combinedData = [];
    for (int i = 0; i < commercialData.length; i++) {
      combinedData.add(MonthlyData(
        month: commercialData[i].month,
        payment: commercialData[i].payment + providentData[i].payment,
        principal: commercialData[i].principal + providentData[i].principal,
        interest: commercialData[i].interest + providentData[i].interest,
        remainingPrincipal: commercialData[i].remainingPrincipal +
            providentData[i].remainingPrincipal,
      ));
    }

    final yearlyData = _groupByYear(combinedData);
    final totalPayment = combinedData.fold<double>(0, (sum, d) => sum + d.payment);
    final totalInterest = combinedData.fold<double>(0, (sum, d) => sum + d.interest);

    return RepaymentResult(
      firstMonthPayment: combinedData.first.payment,
      lastMonthPayment: combinedData.last.payment,
      totalPayment: totalPayment,
      totalInterest: totalInterest,
      totalPrincipal: params.totalAmount * 10000,
      monthlyData: combinedData,
      yearlyData: yearlyData,
    );
  }

  /// 按年度分组
  static List<YearlyData> _groupByYear(List<MonthlyData> monthlyData) {
    final Map<int, List<MonthlyData>> grouped = {};

    for (final data in monthlyData) {
      final year = data.year;
      grouped.putIfAbsent(year, () => []);
      grouped[year]!.add(data);
    }

    return grouped.entries.map((entry) {
      final yearData = entry.value;
      final yearPayment = yearData.fold<double>(0, (sum, d) => sum + d.payment);
      final yearPrincipal = yearData.fold<double>(0, (sum, d) => sum + d.principal);
      final yearInterest = yearData.fold<double>(0, (sum, d) => sum + d.interest);

      return YearlyData(
        year: entry.key,
        yearPayment: yearPayment,
        yearPrincipal: yearPrincipal,
        yearInterest: yearInterest,
        monthlyData: yearData,
      );
    }).toList();
  }
}

/// 计算 x 的 n 次方
double pow(double x, int n) {
  double result = 1;
  for (int i = 0; i < n; i++) {
    result *= x;
  }
  return result;
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/housemoneycalc/services/mortgage_calculator.dart
git commit -m "feat(housemoneycalc): add MortgageCalculator service with equal interest and principal calculations"
```

---

## Task 7: 创建单元测试

**Files:**
- Create: `app/test/tools/housemoneycalc/housemoneycalc_test.dart`

- [ ] **Step 1: 创建测试文件**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/tools/housemoneycalc/models/loan_enums.dart';
import 'package:app/tools/housemoneycalc/models/loan_params.dart';
import 'package:app/tools/housemoneycalc/services/mortgage_calculator.dart';

void main() {
  group('MortgageCalculator', () {
    group('等额本息计算', () {
      test('100万贷款，30年，年利率4.2%', () {
        final params = LoanParams(
          repaymentMethod: RepaymentMethod.equalInterest,
          loanType: LoanType.commercial,
          commercialAmount: 100,
          loanTermYears: 30,
          rateType: InterestRateType.fixed,
          fixedRate: 4.2,
        );

        final result = MortgageCalculator.calculate(params);

        // 验证基本结果（允许±1元误差）
        expect(result.firstMonthPayment, closeTo(4890, 1));
        expect(result.totalPayment, closeTo(1760460, 100));
        expect(result.totalInterest, closeTo(760460, 100));
        expect(result.totalPrincipal, closeTo(1000000, 1));

        // 验证月数
        expect(result.monthlyData.length, 360);

        // 验证每月还款额基本相等（允许微小浮点误差）
        final firstMonth = result.monthlyData.first.payment;
        for (final data in result.monthlyData) {
          expect(data.payment, closeTo(firstMonth, 0.1));
        }

        // 验证首月本金和利息
        expect(result.monthlyData.first.principal, closeTo(1390, 1));
        expect(result.monthlyData.first.interest, closeTo(3500, 1));
      });

      test('200万贷款，20年，年利率3.8%', () {
        final params = LoanParams(
          repaymentMethod: RepaymentMethod.equalInterest,
          loanType: LoanType.commercial,
          commercialAmount: 200,
          loanTermYears: 20,
          rateType: InterestRateType.fixed,
          fixedRate: 3.8,
        );

        final result = MortgageCalculator.calculate(params);

        expect(result.firstMonthPayment, closeTo(11943, 1));
        expect(result.totalPayment, closeTo(2866360, 100));
        expect(result.totalPrincipal, 2000000);
      });
    });

    group('等额本金计算', () {
      test('100万贷款，30年，年利率4.2%', () {
        final params = LoanParams(
          repaymentMethod: RepaymentMethod.equalPrincipal,
          loanType: LoanType.commercial,
          commercialAmount: 100,
          loanTermYears: 30,
          rateType: InterestRateType.fixed,
          fixedRate: 4.2,
        );

        final result = MortgageCalculator.calculate(params);

        // 验证首月和末月
        expect(result.firstMonthPayment, closeTo(6277, 1));
        expect(result.lastMonthPayment, closeTo(2794, 1));

        // 验证总利息比等额本息少
        expect(result.totalInterest, lessThan(760000));

        // 验证每月本金固定
        final monthlyPrincipal = 1000000 / 360;
        for (final data in result.monthlyData) {
          expect(data.principal, closeTo(monthlyPrincipal, 0.1));
        }

        // 验证月供递减
        for (int i = 1; i < result.monthlyData.length; i++) {
          expect(
            result.monthlyData[i].payment,
            lessThan(result.monthlyData[i - 1].payment),
          );
        }
      });
    });

    group('组合贷计算', () {
      test('商业贷100万+公积金100万，30年', () {
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

        expect(result.totalPrincipal, 2000000);
        expect(result.monthlyData.length, 360);

        // 组合贷月供应该比纯商贷200万少
        expect(result.firstMonthPayment, lessThan(9780)); // 纯商贷200万约9780元
      });
    });

    group('年度分组', () {
      test('30年贷款分为30个年度', () {
        final params = LoanParams(
          repaymentMethod: RepaymentMethod.equalInterest,
          loanType: LoanType.commercial,
          commercialAmount: 100,
          loanTermYears: 30,
          rateType: InterestRateType.fixed,
          fixedRate: 4.2,
        );

        final result = MortgageCalculator.calculate(params);

        expect(result.yearlyData.length, 30);

        // 每年应该有12个月（最后一年可能不足12个月）
        for (int i = 0; i < result.yearlyData.length - 1; i++) {
          expect(result.yearlyData[i].monthlyData.length, 12);
        }

        // 验证年度数据累加正确
        for (final yearData in result.yearlyData) {
          final sumPayment = yearData.monthlyData.fold<double>(
            0,
            (sum, d) => sum + d.payment,
          );
          expect(yearData.yearPayment, closeTo(sumPayment, 0.1));
        }
      });
    });

    group('边界测试', () {
      test('最小金额1万元', () {
        final params = LoanParams(
          repaymentMethod: RepaymentMethod.equalInterest,
          loanType: LoanType.commercial,
          commercialAmount: 1,
          loanTermYears: 1,
          rateType: InterestRateType.fixed,
          fixedRate: 4.2,
        );

        final result = MortgageCalculator.calculate(params);

        expect(result.totalPrincipal, 10000);
        expect(result.monthlyData.length, 12);
      });

      test('利率为0%', () {
        final params = LoanParams(
          repaymentMethod: RepaymentMethod.equalInterest,
          loanType: LoanType.commercial,
          commercialAmount: 100,
          loanTermYears: 10,
          rateType: InterestRateType.fixed,
          fixedRate: 0,
        );

        final result = MortgageCalculator.calculate(params);

        expect(result.totalInterest, 0);
        expect(result.firstMonthPayment, closeTo(1000000 / 120, 0.1));
      });

      test('LPR浮动利率计算', () {
        final params = LoanParams(
          repaymentMethod: RepaymentMethod.equalInterest,
          loanType: LoanType.commercial,
          commercialAmount: 100,
          loanTermYears: 30,
          rateType: InterestRateType.lprFloating,
          lprRate: 3.95,
          basisPoints: -0.3,
        );

        expect(params.annualRate, 3.65); // 3.95 - 0.3

        final result = MortgageCalculator.calculate(params);
        expect(result.totalPrincipal, 1000000);
      });
    });
  });
}
```

- [ ] **Step 2: 运行测试确保通过**

```bash
cd app
flutter test test/tools/housemoneycalc/housemoneycalc_test.dart
```

Expected: All tests pass

- [ ] **Step 3: Commit**

```bash
git add app/test/tools/housemoneycalc/housemoneycalc_test.dart
git commit -m "test(housemoneycalc): add unit tests for mortgage calculator"
```

---

## Task 8: 创建 ToolModule 实现

**Files:**
- Create: `app/lib/tools/housemoneycalc/housemoneycalc_tool.dart`

- [ ] **Step 1: 创建 ToolModule**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'housemoneycalc_page.dart';

class HouseMoneyCalcTool implements ToolModule {
  @override
  String get id => 'housemoneycalc';

  @override
  String get name => '房贷计算器';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.home_work;

  @override
  ToolCategory get category => ToolCategory.calc;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const HouseMoneyCalcPage();
  }

  @override
  ToolSettings? get settings => null;

  @override
  Future<void> onInit() async {}

  @override
  Future<void> onDispose() async {}

  @override
  void onEnter() {}

  @override
  void onExit() {}
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/housemoneycalc/housemoneycalc_tool.dart
git commit -m "feat(housemoneycalc): add HouseMoneyCalcTool module implementation"
```

---

## Task 9: 创建主页面

**Files:**
- Create: `app/lib/tools/housemoneycalc/housemoneycalc_page.dart`

- [ ] **Step 1: 创建主页面框架**

```dart
import 'package:flutter/material.dart';
import '../../core/services/usage_service.dart';
import 'models/loan_enums.dart';
import 'models/loan_params.dart';
import 'models/repayment_result.dart';
import 'services/mortgage_calculator.dart';

class HouseMoneyCalcPage extends StatefulWidget {
  const HouseMoneyCalcPage({super.key});

  @override
  State<HouseMoneyCalcPage> createState() => _HouseMoneyCalcPageState();
}

class _HouseMoneyCalcPageState extends State<HouseMoneyCalcPage> {
  int _currentStep = 1;
  LoanParams _params = LoanParams(
    repaymentMethod: RepaymentMethod.equalInterest,
    loanType: LoanType.commercial,
    commercialAmount: 100,
    loanTermYears: 30,
    rateType: InterestRateType.fixed,
    fixedRate: 4.2,
  );
  RepaymentResult? _result;

  @override
  void initState() {
    super.initState();
    UsageService.recordEnter('housemoneycalc');
  }

  @override
  void dispose() {
    UsageService.recordExit('housemoneycalc');
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  void _updateParams(LoanParams params) {
    setState(() {
      _params = params;
    });
  }

  void _calculate() {
    final result = MortgageCalculator.calculate(_params);
    setState(() {
      _result = result;
      _currentStep = 3;
    });
  }

  void _reset() {
    setState(() {
      _currentStep = 1;
      _result = null;
      _params = LoanParams(
        repaymentMethod: RepaymentMethod.equalInterest,
        loanType: LoanType.commercial,
        commercialAmount: 100,
        loanTermYears: 30,
        rateType: InterestRateType.fixed,
        fixedRate: 4.2,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('房贷计算器'),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  // 步骤1：选择贷款类型和还款方式
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(1),
          const SizedBox(height: 24),
          const Text(
            '还款方式',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          _buildRepaymentMethodSelector(),
          const SizedBox(height: 32),
          const Text(
            '贷款类型',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          _buildLoanTypeSelector(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _goToStep(2),
              child: const Text('下一步'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step) {
    return Row(
      children: [
        _buildStepDot(1, step >= 1),
        _buildStepLine(step >= 2),
        _buildStepDot(2, step >= 2),
        _buildStepLine(step >= 3),
        _buildStepDot(3, step >= 3),
      ],
    );
  }

  Widget _buildStepDot(int number, bool active) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active ? Theme.of(context).primaryColor : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: active ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? Theme.of(context).primaryColor : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildRepaymentMethodSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildOptionCard(
            title: '等额本息',
            subtitle: '月供固定，前期利息多',
            selected: _params.repaymentMethod == RepaymentMethod.equalInterest,
            onTap: () => _updateParams(
              _params.copyWith(repaymentMethod: RepaymentMethod.equalInterest),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOptionCard(
            title: '等额本金',
            subtitle: '逐月递减，总利息少',
            selected: _params.repaymentMethod == RepaymentMethod.equalPrincipal,
            onTap: () => _updateParams(
              _params.copyWith(repaymentMethod: RepaymentMethod.equalPrincipal),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoanTypeSelector() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                title: '商业贷款',
                selected: _params.loanType == LoanType.commercial,
                onTap: () => _updateParams(
                  _params.copyWith(loanType: LoanType.commercial),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                title: '公积金贷款',
                selected: _params.loanType == LoanType.provident,
                onTap: () => _updateParams(
                  _params.copyWith(loanType: LoanType.provident),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildOptionCard(
          title: '组合贷（商业+公积金）',
          selected: _params.loanType == LoanType.combined,
          onTap: () => _updateParams(
            _params.copyWith(loanType: LoanType.combined),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required String title,
    String? subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey.shade50,
          border: Border.all(
            color: selected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: selected ? Theme.of(context).primaryColor : Colors.black87,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 步骤2：输入贷款参数
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(2),
          const SizedBox(height: 24),
          _buildAmountInput(),
          const SizedBox(height: 24),
          _buildTermSelector(),
          const SizedBox(height: 24),
          _buildRateSelector(),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _goToStep(1),
                  child: const Text('上一步'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _calculate,
                  child: const Text('开始计算'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '贷款金额',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        if (_params.loanType == LoanType.combined) ...[
          _buildAmountField(
            label: '商业贷款',
            value: _params.commercialAmount,
            onChanged: (v) => _updateParams(
              _params.copyWith(commercialAmount: v),
            ),
          ),
          const SizedBox(height: 12),
          _buildAmountField(
            label: '公积金贷款',
            value: _params.providentAmount,
            onChanged: (v) => _updateParams(
              _params.copyWith(providentAmount: v),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '合计：${_params.totalAmount.toStringAsFixed(0)} 万元',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ] else
          _buildAmountField(
            label: '贷款金额',
            value: _params.commercialAmount,
            onChanged: (v) => _updateParams(
              _params.copyWith(commercialAmount: v),
            ),
          ),
      ],
    );
  }

  Widget _buildAmountField({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        suffixText: '万元',
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: value.toStringAsFixed(0)),
      onChanged: (v) {
        final amount = double.tryParse(v) ?? 0;
        onChanged(amount);
      },
    );
  }

  Widget _buildTermSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '贷款期限',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _params.loanTermYears,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            suffixText: '年',
          ),
          items: List.generate(30, (i) => i + 1)
              .map((year) => DropdownMenuItem(
                    value: year,
                    child: Text('$year 年'),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) {
              _updateParams(_params.copyWith(loanTermYears: v));
            }
          },
        ),
      ],
    );
  }

  Widget _buildRateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '利率类型',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildOptionCard(
                title: '固定利率',
                selected: _params.rateType == InterestRateType.fixed,
                onTap: () => _updateParams(
                  _params.copyWith(rateType: InterestRateType.fixed),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildOptionCard(
                title: 'LPR浮动',
                selected: _params.rateType == InterestRateType.lprFloating,
                onTap: () => _updateParams(
                  _params.copyWith(rateType: InterestRateType.lprFloating),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_params.rateType == InterestRateType.fixed)
          _buildFixedRateInput()
        else
          _buildLprRateInput(),
      ],
    );
  }

  Widget _buildFixedRateInput() {
    return TextField(
      decoration: const InputDecoration(
        labelText: '年利率',
        suffixText: '%',
        border: OutlineInputBorder(),
        hintText: '如：4.2',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      controller: TextEditingController(
        text: _params.fixedRate?.toStringAsFixed(2) ?? '4.20',
      ),
      onChanged: (v) {
        final rate = double.tryParse(v);
        _updateParams(_params.copyWith(fixedRate: rate));
      },
    );
  }

  Widget _buildLprRateInput() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'LPR基准',
                  suffixText: '%',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: TextEditingController(
                  text: _params.lprRate?.toStringAsFixed(2) ?? '3.95',
                ),
                onChanged: (v) {
                  final rate = double.tryParse(v);
                  _updateParams(_params.copyWith(lprRate: rate));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: TextField(
                decoration: const InputDecoration(
                  labelText: '加减基点',
                  suffixText: '%',
                  border: OutlineInputBorder(),
                  hintText: '如：-0.3 或 +0.5',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                controller: TextEditingController(
                  text: _params.basisPoints?.toStringAsFixed(1) ?? '-0.3',
                ),
                onChanged: (v) {
                  final points = double.tryParse(v);
                  _updateParams(_params.copyWith(basisPoints: points));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '实际利率：${_params.annualRate.toStringAsFixed(2)}%',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 步骤3：显示计算结果
  Widget _buildStep3() {
    if (_result == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.grey.shade100,
            child: const TabBar(
              tabs: [
                Tab(text: '概览'),
                Tab(text: '还款计划'),
                Tab(text: '图表'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSummaryTab(),
                _buildScheduleTab(),
                _buildChartsTab(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _reset,
                child: const Text('重新计算'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 概览标签
  Widget _buildSummaryTab() {
    final result = _result!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryCard(
            title: '首月月供',
            amount: result.firstMonthPayment,
            isHighlight: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: '总还款',
                  amount: result.totalPayment,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  title: '总利息',
                  amount: result.totalInterest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            title: '贷款本金',
            amount: result.totalPrincipal,
          ),
          if (_params.repaymentMethod == RepaymentMethod.equalPrincipal) ...[
            const SizedBox(height: 16),
            _buildInfoCard(
              title: '等额本金说明',
              content: '末月月供：${_formatAmount(result.lastMonthPayment)}\n'
                  '首月较高，每月递减约${_formatAmount(result.monthlyData.first.payment - result.monthlyData[1].payment)}',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlight ? Theme.of(context).primaryColor : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatAmount(amount),
            style: TextStyle(
              fontSize: isHighlight ? 28 : 20,
              fontWeight: FontWeight.bold,
              color: isHighlight ? Theme.of(context).primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(2)}万';
    }
    return '¥${amount.toStringAsFixed(2)}';
  }

  // 还款计划标签（简化版，完整实现在下一步）
  Widget _buildScheduleTab() {
    return const Center(
      child: Text('还款计划表将在下一步实现'),
    );
  }

  // 图表标签（简化版，完整实现在下一步）
  Widget _buildChartsTab() {
    return const Center(
      child: Text('图表将在下一步实现'),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/housemoneycalc/housemoneycalc_page.dart
git commit -m "feat(housemoneycalc): add main page with step wizard UI"
```

---

## Task 10: 注册工具到主应用

**Files:**
- Modify: `app/lib/main.dart`

- [ ] **Step 1: 导入并注册工具**

在 `main.dart` 中添加：

```dart
// 在文件顶部添加导入
import 'tools/housemoneycalc/housemoneycalc_tool.dart';

// 在 main() 函数中添加注册
void main() {
  // ...
  ToolRegistry.register(HouseMoneyCalcTool());
  // ...
}
```

具体修改位置：
- 在 `import 'tools/drink_plan/drink_plan_tool.dart';` 之后添加导入
- 在 `ToolRegistry.register(DrinkPlanTool());` 之后添加注册

- [ ] **Step 2: Commit**

```bash
git add app/lib/main.dart
git commit -m "feat(housemoneycalc): register HouseMoneyCalcTool in main.dart"
```

---

## Task 11: 实现还款计划表

**Files:**
- Modify: `app/lib/tools/housemoneycalc/housemoneycalc_page.dart` (_buildScheduleTab方法)

- [ ] **Step 1: 实现可展开的年度列表**

替换 `_buildScheduleTab` 方法：

```dart
// 在 _HouseMoneyCalcPageState 类中添加状态
final Set<int> _expandedYears = {};

// 实现还款计划标签
Widget _buildScheduleTab() {
  if (_result == null) return const SizedBox.shrink();

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: _result!.yearlyData.length,
    itemBuilder: (context, index) {
      final yearData = _result!.yearlyData[index];
      final isExpanded = _expandedYears.contains(yearData.year);

      return Column(
        children: [
          _buildYearCard(yearData, isExpanded),
          if (isExpanded) ...[
            const SizedBox(height: 8),
            _buildMonthList(yearData),
          ],
          const SizedBox(height: 8),
        ],
      );
    },
  );
}

Widget _buildYearCard(YearlyData yearData, bool isExpanded) {
  return Card(
    child: InkWell(
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedYears.remove(yearData.year);
          } else {
            _expandedYears.add(yearData.year);
          }
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '第${yearData.year}年',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '还款：${_formatAmount(yearData.yearPayment)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '本金 ${_formatShortAmount(yearData.yearPrincipal)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  '利息 ${_formatShortAmount(yearData.yearInterest)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildMonthList(YearlyData yearData) {
  return Card(
    color: Colors.grey.shade50,
    margin: const EdgeInsets.symmetric(horizontal: 8),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: yearData.monthlyData.map((month) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    '${month.monthInYear}月',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _formatAmount(month.payment),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '本:${_formatShortAmount(month.principal)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '息:${_formatShortAmount(month.interest)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    ),
  );
}

String _formatShortAmount(double amount) {
  if (amount >= 10000) {
    return '${(amount / 10000).toStringAsFixed(1)}万';
  }
  return amount.toStringAsFixed(0);
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/housemoneycalc/housemoneycalc_page.dart
git commit -m "feat(housemoneycalc): add expandable yearly repayment schedule"
```

---

## Task 12: 实现图表可视化

**Files:**
- Modify: `app/lib/tools/housemoneycalc/housemoneycalc_page.dart` (_buildChartsTab方法)

- [ ] **Step 1: 添加导入并实现图表**

在文件顶部添加导入：

```dart
import 'package:fl_chart/fl_chart.dart';
```

替换 `_buildChartsTab` 方法：

```dart
Widget _buildChartsTab() {
  if (_result == null) return const SizedBox.shrink();

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        _buildPieChart(),
        const SizedBox(height: 24),
        _buildLineChart(),
      ],
    ),
  );
}

// 本金利息占比饼图
Widget _buildPieChart() {
  final result = _result!;
  final principalRatio = result.totalPrincipal / result.totalPayment;
  final interestRatio = result.totalInterest / result.totalPayment;

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '本金 vs 利息',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: principalRatio * 100,
                    title: '${(principalRatio * 100).toStringAsFixed(1)}%\n本金',
                    color: Colors.green.shade400,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: interestRatio * 100,
                    title: '${(interestRatio * 100).toStringAsFixed(1)}%\n利息',
                    color: Colors.orange.shade400,
                    radius: 80,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('本金', Colors.green.shade400, result.totalPrincipal),
              const SizedBox(width: 24),
              _buildLegendItem('利息', Colors.orange.shade400, result.totalInterest),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildLegendItem(String label, Color color, double amount) {
  return Row(
    children: [
      Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            _formatAmount(amount),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ],
  );
}

// 月供趋势折线图
Widget _buildLineChart() {
  final result = _result!;
  final data = result.monthlyData;

  // 每12个月取一个点，避免数据过多
  final spots = <FlSpot>[];
  for (int i = 0; i < data.length; i += 12) {
    spots.add(FlSpot(i.toDouble(), data[i].payment));
  }
  // 确保最后一个点包含
  if (spots.last.x != data.length - 1) {
    spots.add(FlSpot((data.length - 1).toDouble(), data.last.payment));
  }

  final minPayment = data.map((d) => d.payment).reduce((a, b) => a < b ? a : b);
  final maxPayment = data.map((d) => d.payment).reduce((a, b) => a > b ? a : b);

  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '月供趋势',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _params.repaymentMethod == RepaymentMethod.equalInterest
                ? '等额本息：每月还款固定'
                : '等额本金：每月递减',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxPayment - minPayment) / 4,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (data.length / 5).floor().toDouble(),
                      getTitlesWidget: (value, meta) {
                        final year = (value / 12).floor() + 1;
                        return Text(
                          '${year}年',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (maxPayment - minPayment) / 4,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}k',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: minPayment * 0.95,
                maxY: maxPayment * 1.05,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Theme.of(context).primaryColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final month = spot.x.toInt() + 1;
                        final year = (month / 12).floor() + 1;
                        final monthInYear = ((month - 1) % 12) + 1;
                        return LineTooltipItem(
                          '第$year年$monthInYear月\n${_formatAmount(spot.y)}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/housemoneycalc/housemoneycalc_page.dart
git commit -m "feat(housemoneycalc): add pie chart and line chart visualizations"
```

---

## Task 13: 运行完整测试并验证

**Files:**
- Run tests in `app/test/tools/housemoneycalc/`

- [ ] **Step 1: 运行单元测试**

```bash
cd app
flutter test test/tools/housemoneycalc/housemoneycalc_test.dart -v
```

Expected: All tests pass

- [ ] **Step 2: 运行应用验证UI**

```bash
cd app
flutter run
```

手动验证：
1. 首页出现"房贷计算器"格子
2. 点击进入分步向导
3. 步骤1可选择还款方式和贷款类型
4. 步骤2可输入金额、期限、利率
5. 步骤3显示计算结果、还款计划、图表

- [ ] **Step 3: Commit（如需要修复）**

如果有修复，提交：
```bash
git add -A
git commit -m "fix(housemoneycalc): fix issues from manual testing"
```

---

## 完成总结

实现完成后的文件结构：

```
app/lib/tools/housemoneycalc/
├── housemoneycalc_tool.dart
├── housemoneycalc_page.dart
├── models/
│   ├── loan_enums.dart
│   ├── loan_params.dart
│   ├── repayment_result.dart
│   └── repayment_schedule.dart
└── services/
    └── mortgage_calculator.dart

app/test/tools/housemoneycalc/
└── housemoneycalc_test.dart
```

修改的文件：
- `app/pubspec.yaml` - 添加 fl_chart 依赖
- `app/lib/main.dart` - 注册工具

功能清单：
- [x] 等额本息/等额本金计算
- [x] 商业贷/公积金/组合贷支持
- [x] 固定利率/LPR浮动利率
- [x] 分步向导UI
- [x] 计算结果概览
- [x] 还款计划表（年度+逐月）
- [x] 饼图（本金利息占比）
- [x] 折线图（月供趋势）
- [x] 单元测试
