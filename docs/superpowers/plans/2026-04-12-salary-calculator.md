# 工资计算器实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**目标:** 开发一个新的工具格子：工资计算器，支持中国内地个税和五险一金计算，包含历史记录、图表展示等功能。

**架构:** 遵循项目现有工具模式，采用 Page + Service + Model + Widgets 分层架构，参考 BMI 计算器和房贷计算器的实现。

**技术栈:** Flutter, SharedPreferences, fl_chart (图表), SQLite (历史记录)

---

## 文件结构映射

| 文件 | 操作 | 说明 |
|------|------|------|
| `app/lib/tools/salary_calculator/salary_calculator_tool.dart` | 创建 | 工具注册类 |
| `app/lib/tools/salary_calculator/salary_calculator_page.dart` | 创建 | 主页面 |
| `app/lib/tools/salary_calculator/models/city_config.dart` | 创建 | 城市社保配置模型 |
| `app/lib/tools/salary_calculator/models/salary_result.dart` | 创建 | 计算结果模型 |
| `app/lib/tools/salary_calculator/models/history_item.dart` | 创建 | 历史记录模型 |
| `app/lib/tools/salary_calculator/services/city_config_service.dart` | 创建 | 城市配置服务 |
| `app/lib/tools/salary_calculator/services/salary_calculator_service.dart` | 创建 | 核心计算服务 |
| `app/lib/tools/salary_calculator/services/history_service.dart` | 创建 | 历史记录服务 |
| `app/lib/tools/salary_calculator/widgets/salary_input_section.dart` | 创建 | 工资输入区域组件 |
| `app/lib/tools/salary_calculator/widgets/insurance_section.dart` | 创建 | 五险一金配置组件 |
| `app/lib/tools/salary_calculator/widgets/deduction_section.dart` | 创建 | 专项附加扣除组件 |
| `app/lib/tools/salary_calculator/widgets/result_overview_card.dart` | 创建 | 结果概览卡片 |
| `app/lib/tools/salary_calculator/widgets/monthly_detail_list.dart` | 创建 | 月度明细列表 |
| `app/lib/tools/salary_calculator/widgets/tax_chart_widget.dart` | 创建 | 税额图表组件 |
| `app/lib/tools/salary_calculator/widgets/history_section.dart` | 创建 | 历史记录区域 |
| `app/lib/main.dart` | 修改 | 注册新工具 |

---

## 任务分解

### 任务 1: 创建数据模型

**文件:**
- Create: `app/lib/tools/salary_calculator/models/city_config.dart`
- Create: `app/lib/tools/salary_calculator/models/salary_result.dart`
- Create: `app/lib/tools/salary_calculator/models/history_item.dart`

- [ ] **步骤 1.1: 创建目录结构**

```bash
mkdir -p /home/nano/little-grid/.worktrees/feature-salary-calculator/app/lib/tools/salary_calculator/models
mkdir -p /home/nano/little-grid/.worktrees/feature-salary-calculator/app/lib/tools/salary_calculator/services
mkdir -p /home/nano/little-grid/.worktrees/feature-salary-calculator/app/lib/tools/salary_calculator/widgets
```

- [ ] **步骤 1.2: 创建 city_config.dart**

```dart
class CityConfig {
  final String id;
  final String name;
  final double pensionBase;
  final double pensionBaseMax;
  final double pensionRate;
  final double medicalRate;
  final double unemploymentRate;
  final double housingFundRate;
  final double housingFundBase;
  final double housingFundBaseMax;

  CityConfig({
    required this.id,
    required this.name,
    required this.pensionBase,
    required this.pensionBaseMax,
    required this.pensionRate,
    required this.medicalRate,
    required this.unemploymentRate,
    required this.housingFundRate,
    required this.housingFundBase,
    required this.housingFundBaseMax,
  });

  CityConfig copyWith({
    String? id,
    String? name,
    double? pensionBase,
    double? pensionBaseMax,
    double? pensionRate,
    double? medicalRate,
    double? unemploymentRate,
    double? housingFundRate,
    double? housingFundBase,
    double? housingFundBaseMax,
  }) {
    return CityConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      pensionBase: pensionBase ?? this.pensionBase,
      pensionBaseMax: pensionBaseMax ?? this.pensionBaseMax,
      pensionRate: pensionRate ?? this.pensionRate,
      medicalRate: medicalRate ?? this.medicalRate,
      unemploymentRate: unemploymentRate ?? this.unemploymentRate,
      housingFundRate: housingFundRate ?? this.housingFundRate,
      housingFundBase: housingFundBase ?? this.housingFundBase,
      housingFundBaseMax: housingFundBaseMax ?? this.housingFundBaseMax,
    );
  }
}
```

- [ ] **步骤 1.3: 创建 salary_result.dart**

```dart
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
```

- [ ] **步骤 1.4: 创建 history_item.dart**

```dart
class HistoryItem {
  final String id;
  final DateTime timestamp;
  final double preTaxSalary;
  final String cityName;
  final double afterTaxSalary;
  final String? label;

  HistoryItem({
    required this.id,
    required this.timestamp,
    required this.preTaxSalary,
    required this.cityName,
    required this.afterTaxSalary,
    this.label,
  });

  HistoryItem copyWith({
    String? id,
    DateTime? timestamp,
    double? preTaxSalary,
    String? cityName,
    double? afterTaxSalary,
    String? label,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      preTaxSalary: preTaxSalary ?? this.preTaxSalary,
      cityName: cityName ?? this.cityName,
      afterTaxSalary: afterTaxSalary ?? this.afterTaxSalary,
      label: label ?? this.label,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'preTaxSalary': preTaxSalary,
      'cityName': cityName,
      'afterTaxSalary': afterTaxSalary,
      'label': label,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      preTaxSalary: json['preTaxSalary'] as double,
      cityName: json['cityName'] as String,
      afterTaxSalary: json['afterTaxSalary'] as double,
      label: json['label'] as String?,
    );
  }
}
```

- [ ] **步骤 1.5: 提交**

```bash
git add app/lib/tools/salary_calculator/models/city_config.dart
git add app/lib/tools/salary_calculator/models/salary_result.dart
git add app/lib/tools/salary_calculator/models/history_item.dart
git commit -m "feat: add salary calculator data models

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

### 任务 2: 创建城市配置服务

**文件:**
- Create: `app/lib/tools/salary_calculator/services/city_config_service.dart`

- [ ] **步骤 2.1: 创建 city_config_service.dart**

```dart
import '../models/city_config.dart';

class CityConfigService {
  static final List<CityConfig> defaultCities = [
    CityConfig(
      id: 'beijing',
      name: '北京',
      pensionBase: 5360,
      pensionBaseMax: 31884,
      pensionRate: 0.08,
      medicalRate: 0.02,
      unemploymentRate: 0.002,
      housingFundRate: 0.12,
      housingFundBase: 2200,
      housingFundBaseMax: 31884,
    ),
    CityConfig(
      id: 'shanghai',
      name: '上海',
      pensionBase: 7310,
      pensionBaseMax: 36549,
      pensionRate: 0.08,
      medicalRate: 0.02,
      unemploymentRate: 0.005,
      housingFundRate: 0.07,
      housingFundBase: 2590,
      housingFundBaseMax: 36549,
    ),
    CityConfig(
      id: 'guangzhou',
      name: '广州',
      pensionBase: 2300,
      pensionBaseMax: 36072,
      pensionRate: 0.08,
      medicalRate: 0.02,
      unemploymentRate: 0.002,
      housingFundRate: 0.05,
      housingFundBase: 2300,
      housingFundBaseMax: 36072,
    ),
    CityConfig(
      id: 'shenzhen',
      name: '深圳',
      pensionBase: 2360,
      pensionBaseMax: 36549,
      pensionRate: 0.08,
      medicalRate: 0.02,
      unemploymentRate: 0.003,
      housingFundRate: 0.05,
      housingFundBase: 2360,
      housingFundBaseMax: 36549,
    ),
    CityConfig(
      id: 'hangzhou',
      name: '杭州',
      pensionBase: 3957,
      pensionBaseMax: 19783,
      pensionRate: 0.08,
      medicalRate: 0.02,
      unemploymentRate: 0.005,
      housingFundRate: 0.12,
      housingFundBase: 2010,
      housingFundBaseMax: 36675,
    ),
    CityConfig(
      id: 'nanjing',
      name: '南京',
      pensionBase: 4494,
      pensionBaseMax: 24042,
      pensionRate: 0.08,
      medicalRate: 0.02,
      unemploymentRate: 0.005,
      housingFundRate: 0.12,
      housingFundBase: 2280,
      housingFundBaseMax: 34500,
    ),
    CityConfig(
      id: 'chengdu',
      name: '成都',
      pensionBase: 3726,
      pensionBaseMax: 18630,
      pensionRate: 0.08,
      medicalRate: 0.02,
      unemploymentRate: 0.004,
      housingFundRate: 0.12,
      housingFundBase: 1650,
      housingFundBaseMax: 22980,
    ),
    CityConfig(
      id: 'wuhan',
      name: '武汉',
      pensionBase: 4077,
      pensionBaseMax: 20385,
      pensionRate: 0.08,
      medicalRate: 0.02,
      unemploymentRate: 0.003,
      housingFundRate: 0.08,
      housingFundBase: 1750,
      housingFundBaseMax: 27730,
    ),
    CityConfig(
      id: 'xian',
      name: '西安',
      pensionBase: 3632,
      pensionBaseMax: 18159,
      pensionRate: 0.08,
      medicalRate: 0.02,
      unemploymentRate: 0.003,
      housingFundRate: 0.12,
      housingFundBase: 1680,
      housingFundBaseMax: 20955,
    ),
    CityConfig(
      id: 'chongqing',
      name: '重庆',
      pensionBase: 3699,
      pensionBaseMax: 18495,
      pensionRate: 0.08,
      medicalRate: 0.02,
      unemploymentRate: 0.005,
      housingFundRate: 0.12,
      housingFundBase: 1800,
      housingFundBaseMax: 24595,
    ),
  ];

  static CityConfig getCity(String id) {
    return defaultCities.firstWhere(
      (city) => city.id == id,
      orElse: () => defaultCities.first,
    );
  }

  static List<CityConfig> getAllCities() {
    return List.unmodifiable(defaultCities);
  }
}
```

- [ ] **步骤 2.2: 提交**

```bash
git add app/lib/tools/salary_calculator/services/city_config_service.dart
git commit -m "feat: add city config service with 10 preset cities

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

### 任务 3: 创建核心计算服务

**文件:**
- Create: `app/lib/tools/salary_calculator/services/salary_calculator_service.dart`

- [ ] **步骤 3.1: 创建 salary_calculator_service.dart**

```dart
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
```

- [ ] **步骤 3.2: 提交**

```bash
git add app/lib/tools/salary_calculator/services/salary_calculator_service.dart
git commit -m "feat: add salary calculation service with cumulative tax method

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

### 任务 4: 创建历史记录服务

**文件:**
- Create: `app/lib/tools/salary_calculator/services/history_service.dart`

- [ ] **步骤 4.1: 创建 history_service.dart**

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/history_item.dart';

class HistoryService {
  static const String _historyKey = 'salary_calculator_history';
  static const int _maxHistoryItems = 100;

  static Future<List<HistoryItem>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => HistoryItem.fromJson(json as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveHistory(List<HistoryItem> history) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = List<HistoryItem>.from(history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    final limited = sorted.take(_maxHistoryItems).toList();
    final jsonList = limited.map((item) => item.toJson()).toList();
    await prefs.setString(_historyKey, json.encode(jsonList));
  }

  static Future<void> addHistoryItem(HistoryItem item) async {
    final history = await loadHistory();
    history.insert(0, item);
    await saveHistory(history);
  }

  static Future<void> deleteHistoryItem(String id) async {
    final history = await loadHistory();
    history.removeWhere((item) => item.id == id);
    await saveHistory(history);
  }

  static Future<void> updateHistoryLabel(String id, String? label) async {
    final history = await loadHistory();
    final index = history.indexWhere((item) => item.id == id);
    if (index != -1) {
      history[index] = history[index].copyWith(label: label);
      await saveHistory(history);
    }
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
```

- [ ] **步骤 4.2: 提交**

```bash
git add app/lib/tools/salary_calculator/services/history_service.dart
git commit -m "feat: add history service for saving calculation records

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

### 任务 5: 创建 UI 组件 - 工资输入区域

**文件:**
- Create: `app/lib/tools/salary_calculator/widgets/salary_input_section.dart`

- [ ] **步骤 5.1: 创建 salary_input_section.dart**

```dart
import 'package:flutter/material.dart';

class SalaryInputSection extends StatelessWidget {
  final double salary;
  final String selectedCityId;
  final List<String> cityNames;
  final List<String> cityIds;
  final ValueChanged<double> onSalaryChanged;
  final ValueChanged<String> onCityChanged;
  final VoidCallback onCalculate;
  final List<double> presetSalaries;

  const SalaryInputSection({
    super.key,
    required this.salary,
    required this.selectedCityId,
    required this.cityNames,
    required this.cityIds,
    required this.onSalaryChanged,
    required this.onCityChanged,
    required this.onCalculate,
    this.presetSalaries = const [5000, 8000, 10000, 15000, 20000, 30000, 50000],
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = cityIds.indexOf(selectedCityId);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '税前工资',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '请输入税前工资',
              prefixText: '¥ ',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            controller: TextEditingController(text: salary > 0 ? salary.toStringAsFixed(0) : ''),
            onChanged: (value) {
              final parsed = double.tryParse(value) ?? 0;
              onSalaryChanged(parsed);
            },
          ),
          const SizedBox(height: 16),
          const Text(
            '快速预设',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presetSalaries.map((preset) {
              return ElevatedButton(
                onPressed: () => onSalaryChanged(preset),
                style: ElevatedButton.styleFrom(
                  backgroundColor: salary == preset
                      ? Theme.of(context).colorScheme.primary
                      : Colors.blue[100],
                  foregroundColor: salary == preset
                      ? Colors.white
                      : Colors.blue[700],
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('¥${preset ~/ 1000}k'),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            '城市',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedIndex >= 0 ? selectedCityId : null,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            items: List.generate(cityIds.length, (index) {
              return DropdownMenuItem(
                value: cityIds[index],
                child: Text(cityNames[index]),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                onCityChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
```

- [ ] **步骤 5.2: 提交**

```bash
git add app/lib/tools/salary_calculator/widgets/salary_input_section.dart
git commit -m "feat: add salary input section widget

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

### 任务 6: 创建 UI 组件 - 五险一金配置区域

**文件:**
- Create: `app/lib/tools/salary_calculator/widgets/insurance_section.dart`

- [ ] **步骤 6.1: 创建 insurance_section.dart**

```dart
import 'package:flutter/material.dart';
import '../models/city_config.dart';

class InsuranceSection extends StatefulWidget {
  final CityConfig cityConfig;
  final bool useCustom;
  final ValueChanged<bool> onUseCustomChanged;
  final ValueChanged<CityConfig> onConfigChanged;

  const InsuranceSection({
    super.key,
    required this.cityConfig,
    required this.useCustom,
    required this.onUseCustomChanged,
    required this.onConfigChanged,
  });

  @override
  State<InsuranceSection> createState() => _InsuranceSectionState();
}

class _InsuranceSectionState extends State<InsuranceSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              '五险一金配置',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: widget.useCustom,
                  onChanged: widget.onUseCustomChanged,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: widget.useCustom ? _buildCustomConfig() : _buildDefaultDisplay(),
            ),
          if (_isExpanded) const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDefaultDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('养老保险: ${(widget.cityConfig.pensionRate * 100).toStringAsFixed(1)}%'),
        Text('医疗保险: ${(widget.cityConfig.medicalRate * 100).toStringAsFixed(1)}%'),
        Text('失业保险: ${(widget.cityConfig.unemploymentRate * 100).toStringAsFixed(1)}%'),
        Text('公积金: ${(widget.cityConfig.housingFundRate * 100).toStringAsFixed(1)}%'),
      ],
    );
  }

  Widget _buildCustomConfig() {
    return Column(
      children: [
        _buildRateField(
          '养老保险',
          widget.cityConfig.pensionRate,
          (value) {
            widget.onConfigChanged(widget.cityConfig.copyWith(pensionRate: value));
          },
        ),
        const SizedBox(height: 12),
        _buildRateField(
          '医疗保险',
          widget.cityConfig.medicalRate,
          (value) {
            widget.onConfigChanged(widget.cityConfig.copyWith(medicalRate: value));
          },
        ),
        const SizedBox(height: 12),
        _buildRateField(
          '失业保险',
          widget.cityConfig.unemploymentRate,
          (value) {
            widget.onConfigChanged(widget.cityConfig.copyWith(unemploymentRate: value));
          },
        ),
        const SizedBox(height: 12),
        _buildRateField(
          '公积金',
          widget.cityConfig.housingFundRate,
          (value) {
            widget.onConfigChanged(widget.cityConfig.copyWith(housingFundRate: value));
          },
        ),
      ],
    );
  }

  Widget _buildRateField(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label),
        ),
        Expanded(
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              suffixText: '%',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            controller: TextEditingController(text: (value * 100).toStringAsFixed(1)),
            onChanged: (text) {
              final parsed = double.tryParse(text) ?? 0;
              onChanged(parsed / 100);
            },
          ),
        ),
      ],
    );
  }
}
```

- [ ] **步骤 6.2: 提交**

```bash
git add app/lib/tools/salary_calculator/widgets/insurance_section.dart
git commit -m "feat: add insurance configuration section widget

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

### 任务 7: 创建 UI 组件 - 专项附加扣除区域

**文件:**
- Create: `app/lib/tools/salary_calculator/widgets/deduction_section.dart`

- [ ] **步骤 7.1: 创建 deduction_section.dart**

```dart
import 'package:flutter/material.dart';

class DeductionSection extends StatefulWidget {
  final Map<String, double> deductions;
  final ValueChanged<Map<String, double>> onDeductionsChanged;

  const DeductionSection({
    super.key,
    required this.deductions,
    required this.onDeductionsChanged,
  });

  @override
  State<DeductionSection> createState() => _DeductionSectionState();
}

class _DeductionSectionState extends State<DeductionSection> {
  bool _isExpanded = false;

  static const Map<String, String> deductionLabels = {
    'childrenEducation': '子女教育',
    'continuingEducation': '继续教育',
    'seriousIllness': '大病医疗',
    'housingLoan': '住房贷款利息',
    'housingRent': '住房租金',
    'elderlyCare': '赡养老人',
    'infantCare': '3岁以下婴幼儿照护',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              '专项附加扣除',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: deductionLabels.entries.map((entry) {
                  final key = entry.key;
                  final label = entry.value;
                  final value = widget.deductions[key] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(label),
                        ),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              prefixText: '¥ ',
                              hintText: '0',
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            controller: TextEditingController(text: value > 0 ? value.toStringAsFixed(0) : ''),
                            onChanged: (text) {
                              final parsed = double.tryParse(text) ?? 0;
                              final newDeductions = Map<String, double>.from(widget.deductions);
                              newDeductions[key] = parsed;
                              widget.onDeductionsChanged(newDeductions);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          if (_isExpanded) const SizedBox(height: 16),
        ],
      ),
    );
  }
}
```

- [ ] **步骤 7.2: 提交**

```bash
git add app/lib/tools/salary_calculator/widgets/deduction_section.dart
git commit -m "feat: add special deduction section widget

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

### 任务 8: 创建 UI 组件 - 结果概览卡片

**文件:**
- Create: `app/lib/tools/salary_calculator/widgets/result_overview_card.dart`

- [ ] **步骤 8.1: 创建 result_overview_card.dart**

```dart
import 'package:flutter/material.dart';
import '../models/salary_result.dart';

class ResultOverviewCard extends StatelessWidget {
  final SalaryResult? result;

  const ResultOverviewCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.calculate_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '请输入工资开始计算',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final r = result!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '计算结果',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¥${r.afterTaxSalary.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            '税后工资 (月)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white30, thickness: 1),
          const SizedBox(height: 16),
          _buildDetailRow('税前工资', r.preTaxSalary),
          const SizedBox(height: 8),
          _buildDetailRow('五险一金', r.totalInsurance),
          const SizedBox(height: 8),
          _buildDetailRow('专项附加扣除', r.totalDeduction),
          const SizedBox(height: 8),
          _buildDetailRow('个税总额 (年)', r.totalTax),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),
        Text(
          '¥${value.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
```

- [ ] **步骤 8.2: 提交**

```bash
git add app/lib/tools/salary_calculator/widgets/result_overview_card.dart
git commit -m "feat: add result overview card widget

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

### 任务 9: 创建 UI 组件 - 月度明细列表

**文件:**
- Create: `app/lib/tools/salary_calculator/widgets/monthly_detail_list.dart`

- [ ] **步骤 9.1: 创建 monthly_detail_list.dart**

```dart
import 'package:flutter/material.dart';
import '../models/salary_result.dart';

class MonthlyDetailList extends StatelessWidget {
  final SalaryResult? result;

  const MonthlyDetailList({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '月度明细',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 16,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 48,
              headingRowHeight: 48,
              columns: const [
                DataColumn(label: Text('月份')),
                DataColumn(label: Text('当月税额')),
                DataColumn(label: Text('累计税额')),
                DataColumn(label: Text('当月税后')),
              ],
              rows: result!.monthlyDetails.map((detail) {
                return DataRow(
                  cells: [
                    DataCell(Text('${detail.month}月')),
                    DataCell(Text('¥${detail.monthlyTax.toStringAsFixed(2)}')),
                    DataCell(Text('¥${detail.cumulativeTax.toStringAsFixed(2)}')),
                    DataCell(Text('¥${detail.monthlyAfterTax.toStringAsFixed(2)}')),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
```

- [ ] **步骤 9.2: 提交**

```bash
git add app/lib/tools/salary_calculator/widgets/monthly_detail_list.dart
git commit -m "feat: add monthly detail list widget

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

### 任务 10: 创建 UI 组件 - 税额图表

**文件:**
- Create: `app/lib/tools/salary_calculator/widgets/tax_chart_widget.dart`

- [ ] **步骤 10.1: 创建 tax_chart_widget.dart**

```dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/salary_result.dart';

class TaxChartWidget extends StatelessWidget {
  final SalaryResult? result;

  const TaxChartWidget({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              '税额走势',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getYInterval(),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}月');
                        },
                        interval: 2,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 1,
                  maxX: 12,
                  minY: 0,
                  maxY: _getMaxY(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: result!.monthlyDetails.map((detail) {
                        return FlSpot(detail.month.toDouble(), detail.monthlyTax);
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: result!.monthlyDetails.map((detail) {
                        return FlSpot(detail.month.toDouble(), detail.cumulativeTax);
                      }).toList(),
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.black.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  color: Theme.of(context).colorScheme.primary,
                  label: '当月税额',
                ),
                const SizedBox(width: 24),
                _buildLegendItem(
                  color: Colors.orange,
                  label: '累计税额',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  double _getMaxY() {
    if (result == null) return 100;
    final maxTax = result!.monthlyDetails.fold<double>(
      0,
      (max, detail) => detail.cumulativeTax > max ? detail.cumulativeTax : max,
    );
    return (maxTax * 1.2).ceilToDouble();
  }

  double _getYInterval() {
    final maxY = _getMaxY();
    if (maxY <= 100) return 20;
    if (maxY <= 1000) return 200;
    if (maxY <= 5000) return 1000;
    return 5000;
  }
}
```

- [ ] **步骤 10.2: 检查 fl_chart 依赖并提交**

先检查 `app/pubspec.yaml` 确认依赖，然后提交：

```bash
git add app/lib/tools/salary_calculator/widgets/tax_chart_widget.dart
git commit -m "feat: add tax chart widget using fl_chart

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

### 任务 11: 创建 UI 组件 - 历史记录区域

**文件:**
- Create: `app/lib/tools/salary_calculator/widgets/history_section.dart`

- [ ] **步骤 11.1: 创建 history_section.dart**

```dart
import 'package:flutter/material.dart';
import '../models/history_item.dart';

class HistorySection extends StatefulWidget {
  final List<HistoryItem> history;
  final ValueChanged<HistoryItem> onItemTap;
  final ValueChanged<String> onDeleteItem;
  final ValueChanged<(String, String?)> onUpdateLabel;

  const HistorySection({
    super.key,
    required this.history,
    required this.onItemTap,
    required this.onDeleteItem,
    required this.onUpdateLabel,
  });

  @override
  State<HistorySection> createState() => _HistorySectionState();
}

class _HistorySectionState extends State<HistorySection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    if (widget.history.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              '计算历史 (${widget.history.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.history.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = widget.history[index];
                return _HistoryItemTile(
                  item: item,
                  onTap: () => widget.onItemTap(item),
                  onDelete: () => widget.onDeleteItem(item.id),
                  onUpdateLabel: (label) => widget.onUpdateLabel((item.id, label)),
                );
              },
            ),
          if (_isExpanded) const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _HistoryItemTile extends StatefulWidget {
  final HistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final ValueChanged<String?> onUpdateLabel;

  const _HistoryItemTile({
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.onUpdateLabel,
  });

  @override
  State<_HistoryItemTile> createState() => _HistoryItemTileState();
}

class _HistoryItemTileState extends State<_HistoryItemTile> {
  bool _isEditingLabel = false;
  final _labelController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isEditingLabel)
                    TextField(
                      controller: _labelController..text = widget.item.label ?? '',
                      decoration: const InputDecoration(
                        hintText: '添加标签...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        isDense: true,
                      ),
                      onSubmitted: (value) {
                        widget.onUpdateLabel(value.isEmpty ? null : value);
                        setState(() => _isEditingLabel = false);
                      },
                      autofocus: true,
                    )
                  else
                    Row(
                      children: [
                        if (widget.item.label != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.item.label!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                        if (widget.item.label == null)
                          InkWell(
                            onTap: () {
                              setState(() => _isEditingLabel = true);
                            },
                            child: Text(
                              '添加标签',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '税前 ¥${widget.item.preTaxSalary.toStringAsFixed(0)} → 税后 ¥${widget.item.afterTaxSalary.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.item.cityName} · ${_formatDate(widget.item.timestamp)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.grey,
              onPressed: widget.onDelete,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}月${date.day}日 ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
```

- [ ] **步骤 11.2: 提交**

```bash
git add app/lib/tools/salary_calculator/widgets/history_section.dart
git commit -m "feat: add history section widget

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

### 任务 12: 创建工具注册类

**文件:**
- Create: `app/lib/tools/salary_calculator/salary_calculator_tool.dart`

- [ ] **步骤 12.1: 创建 salary_calculator_tool.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'salary_calculator_page.dart';

class SalaryCalculatorTool implements ToolModule {
  @override
  String get id => 'salary_calculator';

  @override
  String get name => '工资计算器';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.payment;

  @override
  ToolCategory get category => ToolCategory.calc;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const SalaryCalculatorPage();
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

- [ ] **步骤 12.2: 提交**

```bash
git add app/lib/tools/salary_calculator/salary_calculator_tool.dart
git commit -m "feat: add salary calculator tool registration

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

### 任务 13: 创建主页面

**文件:**
- Create: `app/lib/tools/salary_calculator/salary_calculator_page.dart`

- [ ] **步骤 13.1: 创建 salary_calculator_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/usage_service.dart';
import 'models/city_config.dart';
import 'models/salary_result.dart';
import 'models/history_item.dart';
import 'services/city_config_service.dart';
import 'services/salary_calculator_service.dart';
import 'services/history_service.dart';
import 'widgets/salary_input_section.dart';
import 'widgets/insurance_section.dart';
import 'widgets/deduction_section.dart';
import 'widgets/result_overview_card.dart';
import 'widgets/monthly_detail_list.dart';
import 'widgets/tax_chart_widget.dart';
import 'widgets/history_section.dart';

class SalaryCalculatorPage extends StatefulWidget {
  const SalaryCalculatorPage({super.key});

  @override
  State<SalaryCalculatorPage> createState() => _SalaryCalculatorPageState();
}

class _SalaryCalculatorPageState extends State<SalaryCalculatorPage> with SingleTickerProviderStateMixin {
  double _salary = 0;
  String _selectedCityId = 'beijing';
  bool _useCustomInsurance = false;
  CityConfig _customCityConfig = CityConfigService.getCity('beijing');
  Map<String, double> _deductions = {};
  SalaryResult? _result;
  List<HistoryItem> _history = [];
  int _viewMode = 0; // 0: 单月, 1: 图表
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    UsageService.recordEnter('salary_calculator');
    _tabController = TabController(length: 2, vsync: this);
    _loadSavedData();
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    UsageService.recordExit('salary_calculator');
    super.dispose();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _salary = prefs.getDouble('salary_last_salary') ?? 0;
      _selectedCityId = prefs.getString('salary_last_city') ?? 'beijing';
      _customCityConfig = CityConfigService.getCity(_selectedCityId);
    });
    if (_salary > 0) {
      _calculate();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('salary_last_salary', _salary);
    await prefs.setString('salary_last_city', _selectedCityId);
  }

  Future<void> _loadHistory() async {
    final history = await HistoryService.loadHistory();
    setState(() {
      _history = history;
    });
  }

  void _calculate() {
    if (_salary <= 0) {
      setState(() {
        _result = null;
      });
      return;
    }

    final cityConfig = _useCustomInsurance ? _customCityConfig : CityConfigService.getCity(_selectedCityId);
    final result = SalaryCalculatorService.calculate(
      preTaxSalary: _salary,
      cityConfig: cityConfig,
      deductions: _deductions,
    );

    setState(() {
      _result = result;
    });
    _saveData();
  }

  Future<void> _saveToHistory() async {
    if (_result == null) return;

    final cityConfig = _useCustomInsurance ? _customCityConfig : CityConfigService.getCity(_selectedCityId);
    final item = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      preTaxSalary: _salary,
      cityName: cityConfig.name,
      afterTaxSalary: _result!.afterTaxSalary,
    );

    await HistoryService.addHistoryItem(item);
    await _loadHistory();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存到历史记录')),
      );
    }
  }

  void _applyHistoryItem(HistoryItem item) {
    setState(() {
      _salary = item.preTaxSalary;
    });
    _calculate();
  }

  @override
  Widget build(BuildContext context) {
    final cities = CityConfigService.getAllCities();
    final cityIds = cities.map((c) => c.id).toList();
    final cityNames = cities.map((c) => c.name).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('工资计算器'),
        actions: [
          if (_result != null)
            IconButton(
              icon: const Icon(Icons.save_outlined),
              onPressed: _saveToHistory,
              tooltip: '保存到历史',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SalaryInputSection(
              salary: _salary,
              selectedCityId: _selectedCityId,
              cityNames: cityNames,
              cityIds: cityIds,
              onSalaryChanged: (value) {
                setState(() {
                  _salary = value;
                });
                _calculate();
              },
              onCityChanged: (value) {
                setState(() {
                  _selectedCityId = value;
                  _customCityConfig = CityConfigService.getCity(value);
                });
                _calculate();
              },
              onCalculate: _calculate,
            ),
            const SizedBox(height: 16),
            InsuranceSection(
              cityConfig: _customCityConfig,
              useCustom: _useCustomInsurance,
              onUseCustomChanged: (value) {
                setState(() {
                  _useCustomInsurance = value;
                  if (!value) {
                    _customCityConfig = CityConfigService.getCity(_selectedCityId);
                  }
                });
                _calculate();
              },
              onConfigChanged: (config) {
                setState(() {
                  _customCityConfig = config;
                });
                _calculate();
              },
            ),
            const SizedBox(height: 16),
            DeductionSection(
              deductions: _deductions,
              onDeductionsChanged: (deductions) {
                setState(() {
                  _deductions = deductions;
                });
                _calculate();
              },
            ),
            const SizedBox(height: 16),
            ResultOverviewCard(result: _result),
            if (_result != null) ...[
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: '月度明细'),
                  Tab(text: '税额图表'),
                ],
                onTap: (index) {
                  setState(() {
                    _viewMode = index;
                  });
                },
              ),
              const SizedBox(height: 16),
              IndexedStack(
                index: _viewMode,
                children: [
                  MonthlyDetailList(result: _result),
                  TaxChartWidget(result: _result),
                ],
              ),
            ],
            const SizedBox(height: 16),
            HistorySection(
              history: _history,
              onItemTap: _applyHistoryItem,
              onDeleteItem: (id) async {
                await HistoryService.deleteHistoryItem(id);
                await _loadHistory();
              },
              onUpdateLabel: (data) async {
                await HistoryService.updateHistoryLabel(data.$1, data.$2);
                await _loadHistory();
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **步骤 13.2: 提交**

```bash
git add app/lib/tools/salary_calculator/salary_calculator_page.dart
git commit -m "feat: add salary calculator main page

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

### 任务 14: 注册工具到 main.dart

**文件:**
- Modify: `app/lib/main.dart`

- [ ] **步骤 14.1: 在 main.dart 中添加导入和注册**

在导入部分添加：

```dart
import 'tools/salary_calculator/salary_calculator_tool.dart';
```

在 `main()` 函数的 `ToolRegistry.register()` 调用中添加：

```dart
ToolRegistry.register(SalaryCalculatorTool());
```

- [ ] **步骤 14.2: 提交**

```bash
git add app/lib/main.dart
git commit -m "feat: register salary calculator tool

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

---

### 任务 15: 检查依赖并运行测试

**文件:**
- Modify: `app/pubspec.yaml` (如果需要)

- [ ] **步骤 15.1: 检查 fl_chart 依赖**

检查 `app/pubspec.yaml` 是否包含 `fl_chart` 依赖。如果没有，添加：

```yaml
dependencies:
  fl_chart: ^0.62.0
```

然后运行 `flutter pub get`。

- [ ] **步骤 15.2: 提交依赖更新（如果需要）**

```bash
git add app/pubspec.yaml
git commit -m "feat: add fl_chart dependency for tax chart

Generated with [Claude Code](https://claude.ai/code)
via [Happy](https://happy.engineering)

Co-Authored-By: Claude <noreply@anthropic.com>
Co-Authored-By: Happy <yesreply@happy.engineering>"
```

- [ ] **步骤 15.3: 运行构建验证**

```bash
cd app
flutter analyze
```

确保没有分析错误。

---

## 实现计划完成

**Spec 覆盖率检查:**
- ✅ 中国内地个税和五险一金计算 (Task 3)
- ✅ 预设城市配置 (Task 2)
- ✅ 自定义五险一金 (Task 6)
- ✅ 7项专项附加扣除 (Task 7)
- ✅ 累计预扣法 (Task 3)
- ✅ 月度明细和年度累计 (Task 9, 10)
- ✅ 历史记录保存 (Task 4, 11)
- ✅ 标签管理 (Task 11)
- ✅ 图表展示 (Task 10)
- ✅ 快速预设 (Task 5)

**占位符检查:** 无占位符，所有步骤都包含完整代码和命令。

**类型一致性检查:** 所有模型、服务、组件保持一致的类型定义和命名规范。
