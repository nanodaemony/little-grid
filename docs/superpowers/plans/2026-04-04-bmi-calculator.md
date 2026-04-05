# BMI Calculator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a BMI calculator tool that calculates Body Mass Index from height and weight inputs, displays health status, advice, and ideal weight range, with real-time feedback and persistence.

**Architecture:** Single-page Flutter widget with result card at top, input controls (sliders + direct input) in middle, and quick presets at bottom. Uses Provider for state management and SharedPreferences for persistence. Follows existing ToolModule pattern.

**Tech Stack:** Flutter 3.0+, Provider, SharedPreferences

---

## File Structure

```
app/lib/tools/bmi/
├── bmi_tool.dart          # ToolModule implementation
├── bmi_page.dart          # Main page widget
├── models/
│   └── bmi_result.dart    # BMIResult model + BMIStatus enum
├── services/
│   └── bmi_service.dart   # BMI calculation logic
└── widgets/
    ├── result_card.dart    # Result display card
    ├── height_input.dart   # Height slider/input widget
    └── weight_input.dart   # Weight slider/input widget
```

---

### Task 1: Create BMIResult Model and BMIStatus Enum

**Files:**
- Create: `app/lib/tools/bmi/models/bmi_result.dart`

- [ ] **Step 1: Create BMIResult model file**

```dart
enum BMIStatus {
  underweight,   // < 18.5
  normal,        // 18.5 - 24
  overweight,    // 24 - 28
  obese          // >= 28
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
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/bmi/models/bmi_result.dart
git commit -m "feat(bmi): add BMIResult model and BMIStatus enum"
```

---

### Task 2: Create BMIService with Calculation Logic

**Files:**
- Create: `app/lib/tools/bmi/services/bmi_service.dart`

- [ ] **Step 1: Create BMIService class**

```dart
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
      status = BMIStatus.underweight;
      advice = "您的体重偏轻，建议适当增加营养摄入，多做增肌运动。";
    } else if (bmi < 24) {
      status = BMIStatus.normal;
      advice = "您的体重在健康范围内，请继续保持良好的生活习惯。";
    } else if (bmi < 28) {
      status = BMIStatus.overweight;
      advice = "您的体重偏重，建议控制饮食，增加运动量。";
    } else {
      status = BMIStatus.obese;
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
      case BMIStatus.underweight:
        return const Color(0xFF2196F3); // Blue
      case BMIStatus.normal:
        return const Color(0xFF4CAF50); // Green
      case BMIStatus.overweight:
        return const Color(0xFFFF9800); // Orange
      case BMIStatus.obese:
        return const Color(0xFFF44336); // Red
    }
  }

  static String getStatusText(BMIStatus status) {
    switch (status) {
      case BMIStatus.underweight:
        return '偏瘦';
      case BMIStatus.normal:
        return '正常';
      case BMIStatus.overweight:
        return '超重';
      case BMIStatus.obese:
        return '肥胖';
    }
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/bmi/services/bmi_service.dart
git commit -m "feat(bmi): add BMIService with calculation logic"
```

---

### Task 3: Create HeightInput Widget

**Files:**
- Create: `app/lib/tools/bmi/widgets/height_input.dart`

- [ ] **Step 1: Create height input widget**

```dart
import 'package:flutter/material.dart';

class HeightInput extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const HeightInput({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '身高',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: 100,
                max: 250,
                divisions: 150,
                label: '${value.toInt()} cm',
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  suffixText: 'cm',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                controller: TextEditingController(
                  text: value.toInt().toString(),
                ),
                onSubmitted: (text) {
                  final parsed = double.tryParse(text);
                  if (parsed != null && parsed >= 100 && parsed <= 250) {
                    onChanged(parsed);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/bmi/widgets/height_input.dart
git commit -m "feat(bmi): add HeightInput widget with slider and text field"
```

---

### Task 4: Create WeightInput Widget

**Files:**
- Create: `app/lib/tools/bmi/widgets/weight_input.dart`

- [ ] **Step 1: Create weight input widget**

```dart
import 'package:flutter/material.dart';

class WeightInput extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const WeightInput({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '体重',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: 30,
                max: 200,
                divisions: 170,
                label: '${value.toInt()} kg',
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 80,
              child: TextField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  suffixText: 'kg',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                controller: TextEditingController(
                  text: value.toInt().toString(),
                ),
                onSubmitted: (text) {
                  final parsed = double.tryParse(text);
                  if (parsed != null && parsed >= 30 && parsed <= 200) {
                    onChanged(parsed);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/bmi/widgets/weight_input.dart
git commit -m "feat(bmi): add WeightInput widget with slider and text field"
```

---

### Task 5: Create ResultCard Widget

**Files:**
- Create: `app/lib/tools/bmi/widgets/result_card.dart`

- [ ] **Step 1: Create result card widget**

```dart
import 'package:flutter/material.dart';
import '../models/bmi_result.dart';
import '../services/bmi_service.dart';

class ResultCard extends StatelessWidget {
  final BMIResult? result;

  const ResultCard({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              '请输入身高和体重',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ),
      );
    }

    final statusColor = BMIService.getStatusColor(result!.status);
    final statusText = BMIService.getStatusText(result!.status);

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              statusColor.withOpacity(0.1),
              statusColor.withOpacity(0.2),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // BMI 数值
              Text(
                'BMI',
                style: TextStyle(
                  fontSize: 20,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result!.bmi.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const SizedBox(height: 16),
              // 健康等级标签
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 健康建议
              Text(
                result!.advice,
                style: const TextStyle(fontSize: 14),
                textAlign textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // 理想体重范围
              Text(
                '理想体重范围: ${result!.minWeight.toStringAsFixed(1)} - ${result!.maxWeight.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/bmi/widgets/result_card.dart
git commit -m "feat(bmi): add ResultCard widget with BMI display and health status"
```

---

### Task 6: Create BMIPage Main Widget

**Files:**
- Create: `app/lib/tools/bmi/bmi_page.dart`

- [ ] **Step 1: Create BMI page widget**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/bmi_result.dart';
import 'services/bmi_service.dart';
import 'widgets/result_card.dart';
import 'widgets/height_input.dart';
import 'widgets/weight_input.dart';

class BMIPage extends StatefulWidget {
  const BMIPage({super.key});

  @override
  State<BMIPage> createState() => _BMIPageState();
}

class _BMIPageState extends State<BMIPage> {
  double _height = 170.0;
  double _weight = 65.0;
  BMIResult? _result;

  @override
  void initState() {
    super.initState();
    _loadLastValues();
  }

  Future<void> _loadLastValues() async {
    final prefs = await SharedPreferences.getInstance();
    final lastHeight = prefs.getDouble('bmi_last_height');
    final lastWeight = prefs.getDouble('bmi_last_weight');

    if (mounted) {
      setState(() {
        if (lastHeight != null) _height = lastHeight;
        if (lastWeight != null) _weight = lastWeight;
        _calculateBMI();
      });
    }
  }

  Future<void> _saveValues() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bmi_last_height', _height);
    await prefs.setDouble('bmi_last_weight', _weight);
  }

  void _calculateBMI() {
    try {
      setState(() {
        _result = BMIService.calculate(_height, _weight);
      });
      _saveValues();
    } catch (e) {
      setState(() {
        _result = null;
      });
    }
  }

  void _applyPreset(double height, double weight) {
    setState(() {
      _height = height;
      _weight = weight;
      _calculateBMI();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI 计算器'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 结果卡片
            ResultCard(result: _result),
            const SizedBox(height: 24),

            // 输入区域
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  HeightInput(
                    value: _height,
                    onChanged: (value) {
                      setState(() {
                        _height = value;
                        _calculateBMI();
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  WeightInput(
                    value: _weight,
                    onChanged: (value) {
                      setState(() {
                        _weight = value;
                        _calculateBMI();
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 快速预设
            const Text(
              '快速预设',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _PresetButton(
                  label: '160cm / 50kg',
                  onTap: () => _applyPreset(160, 50),
                ),
                _PresetButton(
                  label: '165cm / 55kg',
                  onTap: () => _applyPreset(165, 55),
                ),
                _PresetButton(
                  label: '170cm / 60kg',
                  onTap: () => _applyPreset(170, 60),
                ),
                _PresetButton(
                  label: '175cm / 70kg',
                  onTap: () => _applyPreset(175, 70),
                ),
                _PresetButton(
                  label: '180cm / 75kg',
                  onTap: () => _applyPreset(180, 75),
                ),
                _PresetButton(
                  label: '185cm / 80kg',
                  onTap: () => _applyPreset(185, 80),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 单位说明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'BMI = 体重kg / 身高m²',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[100],
        foregroundColor: Colors.blue[700],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(label),
    );
  }
}
```

-` [ ] **Step 2: Commit**

```bash
git add app/lib/tools/bmi/bmi_page.dart
git commit -m "feat(bmi): add BMIPage with state management and persistence"
```

---

### Task 7: Create BMITool and Register

**Files:**
- Create: `app/lib/tools/bmi/bmi_tool.dart`
- Modify: `app/lib/main.dart`

- [ ] **Step 1: Create BMITool class**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'bmi_page.dart';

class BMITool implements ToolModule {
  @override
  String get id => 'bmi';

  @override
  String get name => 'BMI计算器';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.monitor_weight;

  @override
  ToolCategory get category => ToolCategory.calc;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const BMIPage();
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

- [ ] **Step 2: Register BMITool in main.dart**

Add import at the top:
```dart
import 'tools/bmi/bmi_tool.dart';
```

Add registration in main() function:
```dart
ToolRegistry.register(BMITool());
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/tools/bmi/bmi_tool.dart app/lib/main.dart
git commit -m "feat(bmi): create BMITool and register in main"
```

---

### Task 8: Add shared_preferences Dependency

**Files:**
- Modify: `app/pubspec.yaml`

- [ ] **Step 1: Add shared_preferences to dependencies**

Add to dependencies section:
```yaml
  # 本地存储
  shared_preferences: ^2.2.0
```

- [ ] **Step 2: Commit**

```bash
git add app/pubspec.yaml
git commit -m "chore(bmi): add shared_preferences dependency"
```

---

### Task 9: Update README with BMI Calculator

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add BMI calculator to built-in tools table**

Add row to table:
```markdown
| ⚖️ **BMI计算器** | `CALC` | 计算身体质量指数，提供健康建议 |
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add BMI calculator to README"
```

---

### Task 10: Final Verification

**Files:**
- None

- [ ] **Step 1: Build and check for compilation errors**

```bash
cd app && flutter analyze
```

Expected: No errors

- [ ] **Step 2: Verify all files are created**

```bash
ls -la app/lib/tools/bmi/
```

Expected: All files created successfully

- [ ] **Step 3: Final commit with verification note**

```bash
git commit --allow-empty -m "chore(bmi): implementation complete, ready for testing"
```

---
