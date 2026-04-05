# 科学计算器 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现一个支持基础/科学双模式、可滑动切换、带记忆和历史功能的科学计算器

**Architecture:** 使用 Flutter PageView 实现双键盘滑动切换，math_expressions 库处理计算，自定义 ContextModel 实现角度/弧度模式切换，Provider 管理状态

**Tech Stack:** Flutter, math_expressions ^2.6.0, Provider

---

## 文件结构

```
lib/tools/calculator/
├── calculator_tool.dart              # ToolModule 实现，注册到 ToolRegistry
├── calculator_page.dart              # 主页面：Scaffold + PageView + Display
├── models/
│   └── calculator_state.dart         # CalculatorState 状态管理
├── widgets/
│   ├── display_panel.dart            # 双行显示组件（表达式+结果）
│   ├── keyboard_base.dart            # 基础键盘（4列网格）
│   ├── keyboard_scientific.dart      # 科学键盘（5列网格，两页）
│   ├── calculator_key.dart           # 单个按键组件
│   └── history_panel.dart            # 历史记录侧滑面板
└── services/
    ├── calculator_service.dart       # 计算服务封装
    └── degree_context_model.dart     # 角度模式 ContextModel
```

---

## Task 1: 添加依赖

**Files:**
- Modify: `app/pubspec.yaml`

- [ ] **Step 1: 添加 math_expressions 依赖**

在 `app/pubspec.yaml` 的 dependencies 部分添加：

```yaml
dependencies:
  flutter:
    sdk: flutter
  # ... 现有依赖
  math_expressions: ^2.6.0
```

- [ ] **Step 2: 运行 flutter pub get**

Run: `cd app && flutter pub get`
Expected: 成功安装 math_expressions 包

- [ ] **Step 3: Commit**

```bash
git add app/pubspec.yaml app/pubspec.lock
git commit -m "feat: add math_expressions dependency for calculator

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 2: 创建计算服务

**Files:**
- Create: `app/lib/tools/calculator/services/calculator_service.dart`
- Create: `app/lib/tools/calculator/services/degree_context_model.dart`
- Test: 在 calculator_page 中手动测试

- [ ] **Step 1: 创建 DegreeContextModel**

Create `app/lib/tools/calculator/services/degree_context_model.dart`:

```dart
import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';

/// 支持角度模式的 ContextModel
/// 在 DEG 模式下将三角函数参数从角度转换为弧度
class DegreeContextModel extends ContextModel {
  final bool isDegreeMode;

  DegreeContextModel({this.isDegreeMode = true});

  @override
  double? getFunction(String name, List<Expression> args) {
    if (args.isEmpty) {
      return super.getFunction(name, args);
    }

    // 处理阶乘
    if (name == 'fact') {
      final argValue = args[0].evaluate(EvaluationType.REAL, ContextModel());
      final n = argValue.toInt();
      if (n < 0) return double.nan;
      if (n > 170) return double.infinity; // 防止溢出
      double result = 1;
      for (int i = 2; i <= n; i++) {
        result *= i;
      }
      return result;
    }

    // 对于三角函数，在DEG模式下转换参数
    if (isDegreeMode && (name == 'sin' || name == 'cos' || name == 'tan')) {
      final argValue = args[0].evaluate(EvaluationType.REAL, ContextModel());
      final radValue = argValue * math.pi / 180;

      switch (name) {
        case 'sin':
          return math.sin(radValue);
        case 'cos':
          return math.cos(radValue);
        case 'tan':
          return math.tan(radValue);
      }
    }

    return super.getFunction(name, args);
  }
}
```

- [ ] **Step 2: 创建 CalculatorService**

Create `app/lib/tools/calculator/services/calculator_service.dart`:

```dart
import 'dart:math' as math;
import 'package:math_expressions/math_expressions.dart';
import 'degree_context_model.dart';

class CalculatorService {
  static final Parser _parser = Parser();

  /// 计算表达式
  static String evaluate(String expression, bool isDegreeMode) {
    try {
      // 预处理表达式
      String processedExpr = _preprocessExpression(expression);

      // 解析表达式
      final exp = _parser.parse(processedExpr);

      // 创建上下文
      final context = DegreeContextModel(isDegreeMode: isDegreeMode);

      // 绑定常量
      context.bindVariable(Variable('pi'), Number(math.pi));
      context.bindVariable(Variable('e'), Number(math.e));

      // 计算结果
      final result = exp.evaluate(EvaluationType.REAL, context);

      return _formatResult(result);
    } catch (e) {
      return 'Error';
    }
  }

  /// 预处理表达式
  static String _preprocessExpression(String expression) {
    return expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('√', 'sqrt')
        .replaceAll('π', 'pi')
        .replaceAll('ln(', 'log('); // ln 转换为自然对数 log
  }

  /// 格式化结果
  static String _formatResult(double value) {
    if (value.isNaN) return 'Error';
    if (value.isInfinite) return '∞';

    // 处理接近整数的浮点数
    if ((value - value.round()).abs() < 1e-10) {
      return value.round().toString();
    }

    // 保留最多10位小数
    String result = value.toStringAsPrecision(10);

    // 移除末尾的0
    if (result.contains('.')) {
      result = result.replaceAll(RegExp(r'0+$'), '');
      if (result.endsWith('.')) {
        result = result.substring(0, result.length - 1);
      }
    }

    return result;
  }

  /// 检查表达式是否有效
  static bool isValidExpression(String expression) {
    if (expression.isEmpty) return false;
    try {
      final processed = _preprocessExpression(expression);
      _parser.parse(processed);
      return true;
    } catch (e) {
      return false;
    }
  }
}
```

- [ ] **Step 3: 手动测试计算服务**

在 `app/lib/main.dart` 临时添加测试代码：

```dart
void main() {
  // 临时测试
  print(CalculatorService.evaluate('3 + 5', true)); // 期望: 8
  print(CalculatorService.evaluate('sin(90)', true)); // 期望: 1
  print(CalculatorService.evaluate('sin(pi/2)', false)); // 期望: 1

  runApp(const MyApp());
}
```

运行应用，检查控制台输出是否正确。

- [ ] **Step 4: 移除测试代码并 Commit**

移除 main.dart 中的测试代码：

```bash
git add app/lib/tools/calculator/
git commit -m "feat: add calculator service with degree mode support

- CalculatorService for expression evaluation
- DegreeContextModel for DEG/RAD mode handling
- Support for sin/cos/tan in both modes

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 3: 创建状态管理

**Files:**
- Create: `app/lib/tools/calculator/models/calculator_state.dart`

- [ ] **Step 1: 创建历史记录模型**

Create `app/lib/tools/calculator/models/calculator_state.dart`:

```dart
import 'package:flutter/foundation.dart';

/// 计算历史记录项
class CalculationHistory {
  final String expression;
  final String result;
  final DateTime timestamp;

  CalculationHistory({
    required this.expression,
    required this.result,
    required this.timestamp,
  });
}

/// 计算器状态管理
class CalculatorState extends ChangeNotifier {
  String _expression = '';
  String _result = '0';
  bool _isDegreeMode = true;
  double _memoryValue = 0;
  bool _hasMemoryValue = false;
  final List<CalculationHistory> _history = [];

  // Getters
  String get expression => _expression;
  String get result => _result;
  bool get isDegreeMode => _isDegreeMode;
  double get memoryValue => _memoryValue;
  bool get hasMemoryValue => _hasMemoryValue;
  List<CalculationHistory> get history => List.unmodifiable(_history);

  /// 输入数字或符号
  void input(String value) {
    if (_expression.length >= 100) return;
    _expression += value;
    notifyListeners();
  }

  /// 清空
  void clear() {
    _expression = '';
    _result = '0';
    notifyListeners();
  }

  /// 退格
  void backspace() {
    if (_expression.isNotEmpty) {
      _expression = _expression.substring(0, _expression.length - 1);
      notifyListeners();
    }
  }

  /// 切换角度模式
  void toggleAngleMode() {
    _isDegreeMode = !_isDegreeMode;
    notifyListeners();
  }

  /// 计算结果
  void calculate(String computedResult) {
    _result = computedResult;

    // 保存到历史
    if (_expression.isNotEmpty && computedResult != 'Error') {
      _addToHistory(_expression, computedResult);
    }

    notifyListeners();
  }

  /// 设置表达式（从历史加载）
  void setExpression(String expression) {
    _expression = expression;
    notifyListeners();
  }

  /// 记忆加
  void memoryAdd(double value) {
    _memoryValue += value;
    _hasMemoryValue = true;
    notifyListeners();
  }

  /// 记忆减
  void memorySubtract(double value) {
    _memoryValue -= value;
    _hasMemoryValue = true;
    notifyListeners();
  }

  /// 记忆读取
  void memoryRecall() {
    if (_hasMemoryValue) {
      _expression += _formatMemoryValue();
      notifyListeners();
    }
  }

  /// 记忆清除
  void memoryClear() {
    _memoryValue = 0;
    _hasMemoryValue = false;
    notifyListeners();
  }

  /// 格式化记忆值
  String _formatMemoryValue() {
    if (_memoryValue == _memoryValue.roundToDouble()) {
      return _memoryValue.round().toString();
    }
    return _memoryValue.toString();
  }

  /// 添加到历史
  void _addToHistory(String expression, String result) {
    _history.add(CalculationHistory(
      expression: expression,
      result: result,
      timestamp: DateTime.now(),
    ));

    // 限制历史记录数量
    if (_history.length > 20) {
      _history.removeAt(0);
    }
  }

  /// 从历史加载
  void loadFromHistory(CalculationHistory item) {
    _expression = item.expression;
    _result = item.result;
    notifyListeners();
  }

  /// 清空历史
  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/calculator/models/
git commit -m "feat: add calculator state management

- CalculatorState with ChangeNotifier
- Support for expression, result, degree mode, memory, history

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 4: 创建按键组件

**Files:**
- Create: `app/lib/tools/calculator/widgets/calculator_key.dart`

- [ ] **Step 1: 创建 CalculatorKey 组件**

Create `app/lib/tools/calculator/widgets/calculator_key.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';

/// 计算器按键类型
enum KeyType {
  number,      // 数字
  operator,    // 运算符
  function,    // 函数
  equals,      // 等于
  clear,       // 清空
}

class CalculatorKey extends StatelessWidget {
  final String label;
  final KeyType type;
  final VoidCallback onTap;
  final int flex;

  const CalculatorKey({
    super.key,
    required this.label,
    required this.type,
    required this.onTap,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case KeyType.number:
        return AppColors.surface;
      case KeyType.operator:
        return AppColors.primary.withOpacity(0.1);
      case KeyType.function:
        return AppColors.categoryCalc.withOpacity(0.15);
      case KeyType.equals:
        return AppColors.primary;
      case KeyType.clear:
        return Colors.orange.withOpacity(0.2);
    }
  }

  Color _getTextColor() {
    if (type == KeyType.equals) {
      return Colors.white;
    }
    return AppColors.textPrimary;
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/calculator/widgets/calculator_key.dart
git commit -m "feat: add calculator key widget

- CalculatorKey with different types
- Visual styling matching app theme

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 5: 创建显示面板

**Files:**
- Create: `app/lib/tools/calculator/widgets/display_panel.dart`

- [ ] **Step 1: 创建 DisplayPanel 组件**

Create `app/lib/tools/calculator/widgets/display_panel.dart`:

```dart
import 'package:flutter/material.dart';
import '../../../../core/ui/app_colors.dart';

class DisplayPanel extends StatelessWidget {
  final String expression;
  final String result;

  const DisplayPanel({
    super.key,
    required this.expression,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 表达式行
          Text(
            expression.isEmpty ? ' ' : expression,
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // 结果行
          Text(
            result,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/calculator/widgets/display_panel.dart
git commit -m "feat: add calculator display panel

- DisplayPanel with expression and result rows
- Dark theme styling

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 6: 创建基础键盘

**Files:**
- Create: `app/lib/tools/calculator/widgets/keyboard_base.dart`

- [ ] **Step 1: 创建 KeyboardBase 组件**

Create `app/lib/tools/calculator/widgets/keyboard_base.dart`:

```dart
import 'package:flutter/material.dart';
import 'calculator_key.dart';

class KeyboardBase extends StatelessWidget {
  final Function(String) onInput;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback onCalculate;
  final VoidCallback onToggleSign;

  const KeyboardBase({
    super.key,
    required this.onInput,
    required this.onClear,
    required this.onBackspace,
    required this.onCalculate,
    required this.onToggleSign,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 第一行: C ⌫ % ÷
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'C',
                type: KeyType.clear,
                onTap: onClear,
              ),
              CalculatorKey(
                label: '⌫',
                type: KeyType.operator,
                onTap: onBackspace,
              ),
              CalculatorKey(
                label: '%',
                type: KeyType.operator,
                onTap: () => onInput('%'),
              ),
              CalculatorKey(
                label: '÷',
                type: KeyType.operator,
                onTap: () => onInput('÷'),
              ),
            ],
          ),
        ),
        // 第二行: 7 8 9 ×
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: '7',
                type: KeyType.number,
                onTap: () => onInput('7'),
              ),
              CalculatorKey(
                label: '8',
                type: KeyType.number,
                onTap: () => onInput('8'),
              ),
              CalculatorKey(
                label: '9',
                type: KeyType.number,
                onTap: () => onInput('9'),
              ),
              CalculatorKey(
                label: '×',
                type: KeyType.operator,
                onTap: () => onInput('×'),
              ),
            ],
          ),
        ),
        // 第三行: 4 5 6 -
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: '4',
                type: KeyType.number,
                onTap: () => onInput('4'),
              ),
              CalculatorKey(
                label: '5',
                type: KeyType.number,
                onTap: () => onInput('5'),
              ),
              CalculatorKey(
                label: '6',
                type: KeyType.number,
                onTap: () => onInput('6'),
              ),
              CalculatorKey(
                label: '-',
                type: KeyType.operator,
                onTap: () => onInput('-'),
              ),
            ],
          ),
        ),
        // 第四行: 1 2 3 +
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: '1',
                type: KeyType.number,
                onTap: () => onInput('1'),
              ),
              CalculatorKey(
                label: '2',
                type: KeyType.number,
                onTap: () => onInput('2'),
              ),
              CalculatorKey(
                label: '3',
                type: KeyType.number,
                onTap: () => onInput('3'),
              ),
              CalculatorKey(
                label: '+',
                type: KeyType.operator,
                onTap: () => onInput('+'),
              ),
            ],
          ),
        ),
        // 第五行: ( 0 . )
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: '(',
                type: KeyType.operator,
                onTap: () => onInput('('),
              ),
              CalculatorKey(
                label: '0',
                type: KeyType.number,
                onTap: () => onInput('0'),
              ),
              CalculatorKey(
                label: '.',
                type: KeyType.number,
                onTap: () => onInput('.'),
              ),
              CalculatorKey(
                label: ')',
                type: KeyType.operator,
                onTap: () => onInput(')'),
              ),
            ],
          ),
        ),
        // 第六行: ± =
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: '±',
                type: KeyType.operator,
                onTap: onToggleSign,
                flex: 1,
              ),
              CalculatorKey(
                label: '=',
                type: KeyType.equals,
                onTap: onCalculate,
                flex: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/calculator/widgets/keyboard_base.dart
git commit -m "feat: add base calculator keyboard

- 4x6 grid layout with parentheses support
- Number, operator, and function keys

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 7: 创建科学键盘

**Files:**
- Create: `app/lib/tools/calculator/widgets/keyboard_scientific.dart`

- [ ] **Step 1: 创建 KeyboardScientific 组件**

Create `app/lib/tools/calculator/widgets/keyboard_scientific.dart`:

```dart
import 'package:flutter/material.dart';
import 'calculator_key.dart';

class KeyboardScientific extends StatefulWidget {
  final Function(String) onInput;
  final VoidCallback onClear;
  final VoidCallback onBackspace;
  final VoidCallback onCalculate;
  final VoidCallback onToggleSign;
  final bool isDegreeMode;
  final VoidCallback onToggleAngleMode;
  final bool hasMemoryValue;
  final VoidCallback onMemoryAdd;
  final VoidCallback onMemorySubtract;
  final VoidCallback onMemoryRecall;
  final VoidCallback onMemoryClear;

  const KeyboardScientific({
    super.key,
    required this.onInput,
    required this.onClear,
    required this.onBackspace,
    required this.onCalculate,
    required this.onToggleSign,
    required this.isDegreeMode,
    required this.onToggleAngleMode,
    required this.hasMemoryValue,
    required this.onMemoryAdd,
    required this.onMemorySubtract,
    required this.onMemoryRecall,
    required this.onMemoryClear,
  });

  @override
  State<KeyboardScientific> createState() => _KeyboardScientificState();
}

class _KeyboardScientificState extends State<KeyboardScientific> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: [
        _buildFirstPage(),
        _buildSecondPage(),
      ],
    );
  }

  Widget _buildFirstPage() {
    return Column(
      children: [
        // 第一行: DEG C ⌫ % ÷
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: widget.isDegreeMode ? 'DEG' : 'RAD',
                type: KeyType.function,
                onTap: widget.onToggleAngleMode,
              ),
              CalculatorKey(
                label: 'C',
                type: KeyType.clear,
                onTap: widget.onClear,
              ),
              CalculatorKey(
                label: '⌫',
                type: KeyType.operator,
                onTap: widget.onBackspace,
              ),
              CalculatorKey(
                label: '%',
                type: KeyType.operator,
                onTap: () => widget.onInput('%'),
              ),
              CalculatorKey(
                label: '÷',
                type: KeyType.operator,
                onTap: () => widget.onInput('÷'),
              ),
            ],
          ),
        ),
        // 第二行: sin 7 8 9 ×
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'sin',
                type: KeyType.function,
                onTap: () => widget.onInput('sin('),
              ),
              CalculatorKey(
                label: '7',
                type: KeyType.number,
                onTap: () => widget.onInput('7'),
              ),
              CalculatorKey(
                label: '8',
                type: KeyType.number,
                onTap: () => widget.onInput('8'),
              ),
              CalculatorKey(
                label: '9',
                type: KeyType.number,
                onTap: () => widget.onInput('9'),
              ),
              CalculatorKey(
                label: '×',
                type: KeyType.operator,
                onTap: () => widget.onInput('×'),
              ),
            ],
          ),
        ),
        // 第三行: cos 4 5 6 -
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'cos',
                type: KeyType.function,
                onTap: () => widget.onInput('cos('),
              ),
              CalculatorKey(
                label: '4',
                type: KeyType.number,
                onTap: () => widget.onInput('4'),
              ),
              CalculatorKey(
                label: '5',
                type: KeyType.number,
                onTap: () => widget.onInput('5'),
              ),
              CalculatorKey(
                label: '6',
                type: KeyType.number,
                onTap: () => widget.onInput('6'),
              ),
              CalculatorKey(
                label: '-',
                type: KeyType.operator,
                onTap: () => widget.onInput('-'),
              ),
            ],
          ),
        ),
        // 第四行: tan 1 2 3 +
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'tan',
                type: KeyType.function,
                onTap: () => widget.onInput('tan('),
              ),
              CalculatorKey(
                label: '1',
                type: KeyType.number,
                onTap: () => widget.onInput('1'),
              ),
              CalculatorKey(
                label: '2',
                type: KeyType.number,
                onTap: () => widget.onInput('2'),
              ),
              CalculatorKey(
                label: '3',
                type: KeyType.number,
                onTap: () => widget.onInput('3'),
              ),
              CalculatorKey(
                label: '+',
                type: KeyType.operator,
                onTap: () => widget.onInput('+'),
              ),
            ],
          ),
        ),
        // 第五行: π ( 0 . ) e
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'π',
                type: KeyType.function,
                onTap: () => widget.onInput('π'),
              ),
              CalculatorKey(
                label: '(',
                type: KeyType.operator,
                onTap: () => widget.onInput('('),
              ),
              CalculatorKey(
                label: '0',
                type: KeyType.number,
                onTap: () => widget.onInput('0'),
              ),
              CalculatorKey(
                label: '.',
                type: KeyType.number,
                onTap: () => widget.onInput('.'),
              ),
              CalculatorKey(
                label: ')',
                type: KeyType.operator,
                onTap: () => widget.onInput(')'),
              ),
            ],
          ),
        ),
        // 第六行: = e
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'e',
                type: KeyType.function,
                onTap: () => widget.onInput('e'),
                flex: 1,
              ),
              CalculatorKey(
                label: '=',
                type: KeyType.equals,
                onTap: widget.onCalculate,
                flex: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecondPage() {
    return Column(
      children: [
        // 第一行: DEG C ⌫ n! ÷
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: widget.isDegreeMode ? 'DEG' : 'RAD',
                type: KeyType.function,
                onTap: widget.onToggleAngleMode,
              ),
              CalculatorKey(
                label: 'C',
                type: KeyType.clear,
                onTap: widget.onClear,
              ),
              CalculatorKey(
                label: '⌫',
                type: KeyType.operator,
                onTap: widget.onBackspace,
              ),
              CalculatorKey(
                label: 'n!',
                type: KeyType.function,
                onTap: () => widget.onInput('!'),
              ),
              CalculatorKey(
                label: '÷',
                type: KeyType.operator,
                onTap: () => widget.onInput('÷'),
              ),
            ],
          ),
        ),
        // 第二行: log 7 8 9 ×
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'log',
                type: KeyType.function,
                onTap: () => widget.onInput('log('),
              ),
              CalculatorKey(
                label: '7',
                type: KeyType.number,
                onTap: () => widget.onInput('7'),
              ),
              CalculatorKey(
                label: '8',
                type: KeyType.number,
                onTap: () => widget.onInput('8'),
              ),
              CalculatorKey(
                label: '9',
                type: KeyType.number,
                onTap: () => widget.onInput('9'),
              ),
              CalculatorKey(
                label: '×',
                type: KeyType.operator,
                onTap: () => widget.onInput('×'),
              ),
            ],
          ),
        ),
        // 第三行: ln 4 5 6 -
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'ln',
                type: KeyType.function,
                onTap: () => widget.onInput('ln('),
              ),
              CalculatorKey(
                label: '4',
                type: KeyType.number,
                onTap: () => widget.onInput('4'),
              ),
              CalculatorKey(
                label: '5',
                type: KeyType.number,
                onTap: () => widget.onInput('5'),
              ),
              CalculatorKey(
                label: '6',
                type: KeyType.number,
                onTap: () => widget.onInput('6'),
              ),
              CalculatorKey(
                label: '-',
                type: KeyType.operator,
                onTap: () => widget.onInput('-'),
              ),
            ],
          ),
        ),
        // 第四行: x² 1 2 3 +
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: 'x²',
                type: KeyType.function,
                onTap: () => widget.onInput('^2'),
              ),
              CalculatorKey(
                label: '1',
                type: KeyType.number,
                onTap: () => widget.onInput('1'),
              ),
              CalculatorKey(
                label: '2',
                type: KeyType.number,
                onTap: () => widget.onInput('2'),
              ),
              CalculatorKey(
                label: '3',
                type: KeyType.number,
                onTap: () => widget.onInput('3'),
              ),
              CalculatorKey(
                label: '+',
                type: KeyType.operator,
                onTap: () => widget.onInput('+'),
              ),
            ],
          ),
        ),
        // 第五行: ( M+ M- MR )
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: '(',
                type: KeyType.operator,
                onTap: () => widget.onInput('('),
              ),
              CalculatorKey(
                label: 'M+',
                type: widget.hasMemoryValue ? KeyType.function : KeyType.number,
                onTap: widget.onMemoryAdd,
              ),
              CalculatorKey(
                label: 'M-',
                type: widget.hasMemoryValue ? KeyType.function : KeyType.number,
                onTap: widget.onMemorySubtract,
              ),
              CalculatorKey(
                label: 'MR',
                type: widget.hasMemoryValue ? KeyType.function : KeyType.number,
                onTap: widget.onMemoryRecall,
              ),
              CalculatorKey(
                label: ')',
                type: KeyType.operator,
                onTap: () => widget.onInput(')'),
              ),
            ],
          ),
        ),
        // 第六行: √ xʸ =
        Expanded(
          child: Row(
            children: [
              CalculatorKey(
                label: '√',
                type: KeyType.function,
                onTap: () => widget.onInput('√('),
                flex: 1,
              ),
              CalculatorKey(
                label: 'xʸ',
                type: KeyType.function,
                onTap: () => widget.onInput('^'),
                flex: 1,
              ),
              CalculatorKey(
                label: '=',
                type: KeyType.equals,
                onTap: widget.onCalculate,
                flex: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/calculator/widgets/keyboard_scientific.dart
git commit -m "feat: add scientific calculator keyboard

- 5x6 grid with PageView for two pages
- Scientific functions, memory operations, constants, parentheses
- DEG/RAD toggle on both pages

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 8: 创建历史面板

**Files:**
- Create: `app/lib/tools/calculator/widgets/history_panel.dart`

- [ ] **Step 1: 创建 HistoryPanel 组件**

Create `app/lib/tools/calculator/widgets/history_panel.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/calculator_state.dart';

class HistoryPanel extends StatelessWidget {
  final List<CalculationHistory> history;
  final Function(CalculationHistory) onSelect;
  final VoidCallback onClear;

  const HistoryPanel({
    super.key,
    required this.history,
    required this.onSelect,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // 头部
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '计算历史',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (history.isNotEmpty)
                  TextButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('清空'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 历史列表
          Expanded(
            child: history.isEmpty
                ? const Center(
                    child: Text(
                      '暂无历史记录',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: history.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final item = history[history.length - 1 - index];
                      return _HistoryItem(
                        item: item,
                        onTap: () => onSelect(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final CalculationHistory item;
  final VoidCallback onTap;

  const _HistoryItem({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.expression,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '= ${item.result}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/calculator/widgets/history_panel.dart
git commit -m "feat: add calculator history panel

- Side panel showing calculation history
- Tap to load expression
- Clear all history button

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 9: 创建主页面

**Files:**
- Create: `app/lib/tools/calculator/calculator_page.dart`

- [ ] **Step 1: 创建 CalculatorPage**

Create `app/lib/tools/calculator/calculator_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/tool_registry.dart';
import '../../core/services/usage_service.dart';
import 'models/calculator_state.dart';
import 'services/calculator_service.dart';
import 'widgets/display_panel.dart';
import 'widgets/keyboard_base.dart';
import 'widgets/keyboard_scientific.dart';
import 'widgets/history_panel.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  late CalculatorState _state;
  final PageController _keyboardController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _state = CalculatorState();
    UsageService.recordEnter('calculator');
  }

  @override
  void dispose() {
    _keyboardController.dispose();
    UsageService.recordExit('calculator');
    _state.dispose();
    super.dispose();
  }

  void _handleInput(String value) {
    _state.input(value);
  }

  void _handleClear() {
    _state.clear();
  }

  void _handleBackspace() {
    _state.backspace();
  }

  void _handleCalculate() {
    final result = CalculatorService.evaluate(
      _state.expression,
      _state.isDegreeMode,
    );
    _state.calculate(result);
  }

  void _handleToggleSign() {
    // 正负号切换：在当前数字前添加/移除负号
    if (_state.expression.isEmpty) {
      // 表达式为空时，直接输入负号
      _state.input('-');
      return;
    }

    // 找到当前正在输入的数字位置（从末尾开始）
    String expr = _state.expression;

    // 如果最后一个字符是数字或小数点，找到这个数字的起始位置
    if (RegExp(r'[\d.]$').hasMatch(expr)) {
      // 从后向前查找数字的开始
      int i = expr.length - 1;
      while (i >= 0 && RegExp(r'[\d.]$').hasMatch(expr[i])) {
        i--;
      }

      // 检查这个数字前是否有负号
      if (i >= 0 && expr[i] == '-') {
        // 检查是否是减号运算符（前面是数字或右括号）
        if (i > 0 && RegExp(r'[\d)]$').hasMatch(expr[i - 1])) {
          // 这是减号运算符，在当前数字前加负号
          _state.setExpression('${expr.substring(0, i + 1)}(-${expr.substring(i + 1)}');
        } else {
          // 这是负号，移除它
          _state.setExpression('${expr.substring(0, i)}${expr.substring(i + 1)}');
        }
      } else {
        // 没有负号，在当前数字前加负号
        _state.setExpression('${expr.substring(0, i + 1)}(-${expr.substring(i + 1)}');
      }
    } else {
      // 最后一个字符不是数字，直接添加负号
      _state.input('-');
    }
  }

  void _handleToggleAngleMode() {
    _state.toggleAngleMode();
  }

  void _handleMemoryAdd() {
    final currentResult = double.tryParse(_state.result);
    if (currentResult != null) {
      _state.memoryAdd(currentResult);
    }
  }

  void _handleMemorySubtract() {
    final currentResult = double.tryParse(_state.result);
    if (currentResult != null) {
      _state.memorySubtract(currentResult);
    }
  }

  void _handleMemoryRecall() {
    _state.memoryRecall();
  }

  void _handleMemoryClear() {
    _state.memoryClear();
  }

  void _handleHistorySelect(CalculationHistory item) {
    _state.loadFromHistory(item);
  }

  void _handleClearHistory() {
    _state.clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _state,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('科学计算器'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
        ),
        endDrawer: Consumer<CalculatorState>(
          builder: (context, state, child) {
            return HistoryPanel(
              history: state.history,
              onSelect: _handleHistorySelect,
              onClear: _handleClearHistory,
            );
          },
        ),
        body: Column(
          children: [
            // 显示面板
            Consumer<CalculatorState>(
              builder: (context, state, child) {
                return DisplayPanel(
                  expression: state.expression,
                  result: state.result,
                );
              },
            ),
            // 页面指示器
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIndicator(0),
                  const SizedBox(width: 8),
                  _buildIndicator(1),
                ],
              ),
            ),
            // 键盘区域
            Expanded(
              child: PageView(
                controller: _keyboardController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  // 基础键盘页
                  KeyboardBase(
                    onInput: _handleInput,
                    onClear: _handleClear,
                    onBackspace: _handleBackspace,
                    onCalculate: _handleCalculate,
                    onToggleSign: _handleToggleSign,
                  ),
                  // 科学键盘页
                  Consumer<CalculatorState>(
                    builder: (context, state, child) {
                      return KeyboardScientific(
                        onInput: _handleInput,
                        onClear: _handleClear,
                        onBackspace: _handleBackspace,
                        onCalculate: _handleCalculate,
                        onToggleSign: _handleToggleSign,
                        isDegreeMode: state.isDegreeMode,
                        onToggleAngleMode: _handleToggleAngleMode,
                        hasMemoryValue: state.hasMemoryValue,
                        onMemoryAdd: _handleMemoryAdd,
                        onMemorySubtract: _handleMemorySubtract,
                        onMemoryRecall: _handleMemoryRecall,
                        onMemoryClear: _handleMemoryClear,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(int page) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == page
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade300,
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/calculator/calculator_page.dart
git commit -m "feat: add calculator main page

- PageView with base and scientific keyboards
- Display panel with expression and result
- End drawer for history
- All calculator operations integrated

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 10: 创建 ToolModule

**Files:**
- Create: `app/lib/tools/calculator/calculator_tool.dart`

- [ ] **Step 1: 创建 CalculatorTool**

Create `app/lib/tools/calculator/calculator_tool.dart`:

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'calculator_page.dart';

class CalculatorTool implements ToolModule {
  @override
  String get id => 'calculator';

  @override
  String get name => '科学计算器';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.calculate;

  @override
  ToolCategory get category => ToolCategory.calc;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const CalculatorPage();
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
git add app/lib/tools/calculator/calculator_tool.dart
git commit -m "feat: add calculator tool module

- CalculatorTool implements ToolModule
- Registered as calc category tool

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 11: 注册工具

**Files:**
- Modify: `app/lib/main.dart`

- [ ] **Step 1: 导入并注册 CalculatorTool**

修改 `app/lib/main.dart`，在文件顶部添加导入：

```dart
import 'tools/calculator/calculator_tool.dart';
```

在 `ToolRegistry.registerAll()` 调用处添加 `CalculatorTool()`：

```dart
ToolRegistry.registerAll([
  CoinTool(),
  DiceTool(),
  CardTool(),
  TodoTool(),
  CalculatorTool(), // 添加这一行
]);
```

- [ ] **Step 2: 验证注册成功**

运行应用，检查：
1. 首页格子中是否出现「科学计算器」图标
2. 点击后是否能进入计算器页面

- [ ] **Step 3: Commit**

```bash
git add app/lib/main.dart
git commit -m "feat: register calculator tool in app

- Add CalculatorTool to ToolRegistry
- Calculator now available in grid

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 12: 添加阶乘支持

**Files:**
- Modify: `app/lib/tools/calculator/services/calculator_service.dart`

- [ ] **Step 1: 添加阶乘函数**

修改 `CalculatorService`，在 `_preprocessExpression` 中添加阶乘处理：

```dart
static String _preprocessExpression(String expression) {
  String processed = expression
      .replaceAll('×', '*')
      .replaceAll('÷', '/')
      .replaceAll('√', 'sqrt')
      .replaceAll('π', 'pi');

  // 处理阶乘: 将 n! 转换为 fact(n)
  processed = _convertFactorial(processed);

  return processed;
}

/// 将阶乘语法 n! 转换为 fact(n)
static String _convertFactorial(String expression) {
  // 匹配数字后跟 ! 的模式
  final regex = RegExp(r'(\d+)!');
  return expression.replaceAllMapped(regex, (match) {
    final number = match.group(1);
    return 'fact($number)';
  });
}
```

**注意**：`DegreeContextModel` 已在 Task 2 中添加了 `fact` 函数支持，无需再次修改。

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/calculator/services/calculator_service.dart
git commit -m "feat: add factorial support to calculator

- Convert n! syntax to fact(n) function
- Bind custom factorial function to context

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 13: 修复和优化

**Files:**
- Test: 运行应用进行全面测试

- [ ] **Step 1: 测试所有功能**

测试清单：
- [ ] 基础运算：3 + 5 = 8
- [ ] 连续运算：3 + 5 × 2 = 13（优先级正确）
- [ ] 括号：(3 + 5) × 2 = 16
- [ ] 小数：0.1 + 0.2 = 0.3
- [ ] 退格：输入 123，退格后 12
- [ ] 清空：C 键清空所有
- [ ] 正负号：± 切换正负
- [ ] 百分比：50% = 0.5

- [ ] 三角函数 - DEG 模式：sin(90) = 1
- [ ] 三角函数 - RAD 模式：sin(π/2) = 1
- [ ] 对数：log(100) = 2
- [ ] 自然对数：ln(e) = 1
- [ ] 平方根：√16 = 4
- [ ] 幂运算：2^3 = 8
- [ ] 阶乘：5! = 120
- [ ] 常量：π ≈ 3.14159，e ≈ 2.71828

- [ ] 记忆功能：M+、M-、MR、MC
- [ ] 历史记录：计算后保存，从历史加载
- [ ] 滑动切换：左右滑动切换键盘

- [ ] **Step 2: 修复发现的问题**

根据测试结果修复问题，例如：
- 浮点精度问题
- 错误提示不友好
- UI 布局问题

- [ ] **Step 3: 最终 Commit**

```bash
git add .
git commit -m "feat: complete scientific calculator implementation

- Full support for basic and scientific operations
- DEG/RAD mode with custom context model
- Memory and history features
- PageView for keyboard switching
- All functions tested and working

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## 总结

| 任务 | 文件 | 功能 |
|-----|------|------|
| 1 | pubspec.yaml | 添加 math_expressions 依赖 |
| 2 | services/ | 计算服务和角度模式 |
| 3 | models/ | 状态管理 |
| 4-8 | widgets/ | 显示、键盘、历史组件 |
| 9 | calculator_page.dart | 主页面 |
| 10 | calculator_tool.dart | ToolModule 实现 |
| 11 | main.dart | 注册工具 |
| 12 | services/ | 阶乘支持 |
| 13 | - | 测试和修复 |

**预计总代码量**: ~800 行
