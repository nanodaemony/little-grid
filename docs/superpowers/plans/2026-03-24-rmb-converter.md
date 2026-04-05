# 人民币大写转换工具实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现一个人民币数字金额转大写汉字的功能格子，包含输入框、转换逻辑、结果显示和对照表展示。

**Architecture:** 采用 Flutter StatefulWidget 实现页面，核心转换逻辑封装为纯函数服务类，对照表使用网格布局展示。遵循现有工具的设计模式，单页滚动式布局。

**Tech Stack:** Flutter, Dart, Material Design

---

## 文件结构

```
app/lib/tools/rmbconvertor/
├── rmbconvertor_tool.dart      # ToolModule 实现（注册用）
├── rmbconvertor_page.dart      # 主页面（StatefulWidget）
└── services/
    └── rmb_converter.dart      # 转换逻辑核心（纯函数）

app/lib/main.dart               # 修改：注册新工具
```

---

## Task 1: 创建转换服务核心逻辑

**Files:**
- Create: `app/lib/tools/rmbconvertor/services/rmb_converter.dart`
- Test: 运行 Dart 单元测试验证转换逻辑

**描述:** 实现人民币金额转大写的核心算法，包含数字映射、单位处理、特殊规则。

- [ ] **Step 1: 创建目录结构**

```bash
cd app/lib/tools/
mkdir -p rmbconvertor/services
```

- [ ] **Step 2: 编写转换服务代码**

Create: `app/lib/tools/rmbconvertor/services/rmb_converter.dart`

```dart
/// 人民币金额转大写服务
class RmbConverter {
  // 数字映射
  static const List<String> _digits = [
    '零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖'
  ];

  // 单位映射
  static const List<String> _units = ['', '拾', '佰', '仟'];
  static const List<String> _bigUnits = ['', '万', '亿'];

  /// 将金额数字转换为人民币大写
  ///
  /// [amount]: 金额，如 1234.56
  /// 返回: 大写字符串，如 "壹仟贰佰叁拾肆元伍角陆分"
  static String convert(double amount) {
    if (amount == 0) return '零元整';

    // 分离整数和小数部分
    int integerPart = amount.floor();
    int decimalPart = ((amount - integerPart) * 100).round();

    String result = '';

    // 处理整数部分
    if (integerPart > 0) {
      result = _convertInteger(integerPart);
      result += '元';
    } else if (decimalPart == 0) {
      // 整数和小数都为0的情况已在上面处理
      result = '零元整';
      return result;
    }
    // 如果整数部分为0但小数部分不为0，不添加"零元"前缀

    // 处理小数部分（角、分）
    int jiao = decimalPart ~/ 10;
    int fen = decimalPart % 10;

    if (jiao == 0 && fen == 0) {
      // 只有整数部分，添加"整"
      if (integerPart > 0) {
        result += '整';
      }
    } else {
      if (jiao > 0) {
        result += _digits[jiao] + '角';
      }
      if (fen > 0) {
        result += _digits[fen] + '分';
      }
    }

    return result;
  }

  /// 转换整数部分
  static String _convertInteger(int number) {
    if (number == 0) return '';

    String result = '';
    int bigUnitIndex = 0;

    while (number > 0) {
      int segment = number % 10000;
      if (segment != 0) {
        String segmentStr = _convertSegment(segment);
        if (bigUnitIndex > 0) {
          segmentStr += _bigUnits[bigUnitIndex];
        }
        result = segmentStr + result;
      } else if (result.isNotEmpty && !result.startsWith('零')) {
        result = '零' + result;
      }

      number ~/= 10000;
      bigUnitIndex++;
    }

    // 清理连续的零
    result = _cleanZeros(result);

    return result;
  }

  /// 转换4位数段（个、十、百、千）
  static String _convertSegment(int number) {
    String result = '';
    int unitIndex = 0;

    while (number > 0) {
      int digit = number % 10;
      if (digit != 0) {
        result = _digits[digit] + _units[unitIndex] + result;
      } else if (result.isNotEmpty && !result.startsWith('零')) {
        result = '零' + result;
      }
      number ~/= 10;
      unitIndex++;
    }

    return result;
  }

  /// 清理连续的零
  static String _cleanZeros(String str) {
    String result = str.replaceAll(RegExp(r'零+'), '零');
    // 去除末尾的零
    if (result.endsWith('零') && result.length > 1) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  /// 验证金额是否在支持范围内
  static bool isValidAmount(double amount) {
    return amount >= 0 && amount <= 999999999.99;
  }

  /// 格式化输入（添加千分位逗号）
  static String formatInput(String input) {
    // 过滤非数字和小数点
    String filtered = input.replaceAll(RegExp(r'[^\d.]'), '');

    // 处理多个小数点
    int firstDot = filtered.indexOf('.');
    if (firstDot != -1) {
      String beforeDot = filtered.substring(0, firstDot);
      String afterDot = filtered.substring(firstDot + 1).replaceAll('.', '');
      // 限制小数位为2位
      if (afterDot.length > 2) {
        afterDot = afterDot.substring(0, 2);
      }
      filtered = beforeDot + '.' + afterDot;
    }

    // 添加千分位逗号
    List<String> parts = filtered.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? '.' + parts[1] : '';

    // 处理整数部分的千分位
    if (integerPart.length > 3) {
      StringBuffer result = StringBuffer();
      int count = 0;
      for (int i = integerPart.length - 1; i >= 0; i--) {
        if (count > 0 && count % 3 == 0) {
          result.write(',');
        }
        result.write(integerPart[i]);
        count++;
      }
      integerPart = result.toString().split('').reversed.join();
    }

    return integerPart + decimalPart;
  }

  /// 解析格式化的字符串为数字
  static double parseAmount(String formatted) {
    String cleaned = formatted.replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0;
  }
}
```

- [ ] **Step 3: 编写测试验证**

Create: `app/test/tools/rmbconvertor/rmb_converter_test.dart`（如果目录不存在则创建）

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:app/tools/rmbconvertor/services/rmb_converter.dart';

void main() {
  group('RmbConverter', () {
    test('converts 0 correctly', () {
      expect(RmbConverter.convert(0), '零元整');
    });

    test('converts single digits', () {
      expect(RmbConverter.convert(1), '壹元整');
      expect(RmbConverter.convert(5), '伍元整');
      expect(RmbConverter.convert(9), '玖元整');
    });

    test('converts tens correctly', () {
      expect(RmbConverter.convert(10), '壹拾元整');
      expect(RmbConverter.convert(15), '壹拾伍元整');
      expect(RmbConverter.convert(20), '贰拾元整');
    });

    test('converts hundreds correctly', () {
      expect(RmbConverter.convert(100), '壹佰元整');
      expect(RmbConverter.convert(101), '壹佰零壹元整');
      expect(RmbConverter.convert(110), '壹佰壹拾元整');
      expect(RmbConverter.convert(123), '壹佰贰拾叁元整');
    });

    test('converts thousands correctly', () {
      expect(RmbConverter.convert(1000), '壹仟元整');
      expect(RmbConverter.convert(1001), '壹仟零壹元整');
      expect(RmbConverter.convert(1234), '壹仟贰佰叁拾肆元整');
    });

    test('converts ten thousands correctly', () {
      expect(RmbConverter.convert(10000), '壹万元整');
      expect(RmbConverter.convert(10001), '壹万零壹元整');
      expect(RmbConverter.convert(12345), '壹万贰仟叁佰肆拾伍元整');
    });

    test('converts hundred millions correctly', () {
      expect(RmbConverter.convert(100000000), '壹亿元整');
      expect(RmbConverter.convert(100000001), '壹亿零壹元整');
      expect(RmbConverter.convert(123456789), '壹亿贰仟叁佰肆拾伍万陆仟柒佰捌拾玖元整');
    });

    test('converts decimals correctly', () {
      expect(RmbConverter.convert(0.01), '壹分');
      expect(RmbConverter.convert(0.10), '壹角');
      expect(RmbConverter.convert(0.15), '壹角伍分');
      expect(RmbConverter.convert(1.23), '壹元贰角叁分');
      expect(RmbConverter.convert(100.50), '壹佰元伍角');
    });

    test('converts complex amounts', () {
      expect(RmbConverter.convert(1004.06), '壹仟零肆元零陆分');
      expect(RmbConverter.convert(100000.01), '壹拾万零壹分');
    });

    test('formatInput adds thousand separators', () {
      expect(RmbConverter.formatInput('1234'), '1,234');
      expect(RmbConverter.formatInput('1234.56'), '1,234.56');
      expect(RmbConverter.formatInput('1234567'), '1,234,567');
    });

    test('parseAmount parses formatted string', () {
      expect(RmbConverter.parseAmount('1,234.56'), 1234.56);
      expect(RmbConverter.parseAmount('1,234'), 1234.0);
    });
  });
}
```

- [ ] **Step 4: 运行测试**

Run:
```bash
cd app
flutter test test/tools/rmbconvertor/rmb_converter_test.dart
```

Expected: All tests pass.

- [ ] **Step 5: Commit**

```bash
git add app/lib/tools/rmbconvertor/services/rmb_converter.dart
git add app/test/tools/rmbconvertor/rmb_converter_test.dart
git commit -m "feat(rmbconvertor): add RMB converter core service with tests"
```

---

## Task 2: 创建 ToolModule 实现

**Files:**
- Create: `app/lib/tools/rmbconvertor/rmbconvertor_tool.dart`
- Modify: `app/lib/tools/rmbconvertor/services/rmb_converter.dart` (if needed)

**描述:** 实现 ToolModule 接口，用于工具注册。

- [ ] **Step 1: 编写 ToolModule 实现**

Create: `app/lib/tools/rmbconvertor/rmbconvertor_tool.dart`

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'rmbconvertor_page.dart';

class RmbConvertorTool implements ToolModule {
  @override
  String get id => 'rmbconvertor';

  @override
  String get name => '人民币大写';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.currency_yen;

  @override
  ToolCategory get category => ToolCategory.calc;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const RmbConvertorPage();
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
git add app/lib/tools/rmbconvertor/rmbconvertor_tool.dart
git commit -m "feat(rmbconvertor): add ToolModule implementation"
```

---

## Task 3: 创建主页面

**Files:**
- Create: `app/lib/tools/rmbconvertor/rmbconvertor_page.dart`
- Reference: `app/lib/tools/calculator/calculator_page.dart` (查看 UsageService 使用方式)

**描述:** 实现主页面 UI，包含输入框、转换按钮、结果显示、复制功能和对照表。

- [ ] **Step 1: 编写主页面代码**

Create: `app/lib/tools/rmbconvertor/rmbconvertor_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/usage_service.dart';
import 'services/rmb_converter.dart';

class RmbConvertorPage extends StatefulWidget {
  const RmbConvertorPage({super.key});

  @override
  State<RmbConvertorPage> createState() => _RmbConvertorPageState();
}

class _RmbConvertorPageState extends State<RmbConvertorPage> {
  final TextEditingController _controller = TextEditingController();
  String _result = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    UsageService.recordEnter('rmbconvertor');
  }

  @override
  void dispose() {
    _controller.dispose();
    UsageService.recordExit('rmbconvertor');
    super.dispose();
  }

  void _onInputChanged(String value) {
    // 格式化输入
    String formatted = RmbConverter.formatInput(value);
    if (formatted != value) {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    setState(() {
      _errorMessage = '';
    });
  }

  void _convert() {
    String input = _controller.text.replaceAll(',', '');
    double? amount = double.tryParse(input);

    if (amount == null) {
      setState(() {
        _errorMessage = '请输入有效的金额';
        _result = '';
      });
      return;
    }

    if (amount < 0) {
      setState(() {
        _errorMessage = '金额不能为负数';
        _result = '';
      });
      return;
    }

    if (!RmbConverter.isValidAmount(amount)) {
      setState(() {
        _errorMessage = '金额过大，最大支持9亿9999万元';
        _result = '';
      });
      return;
    }

    setState(() {
      _result = RmbConverter.convert(amount);
      _errorMessage = '';
    });
  }

  void _clear() {
    _controller.clear();
    setState(() {
      _result = '';
      _errorMessage = '';
    });
  }

  void _copyResult() {
    if (_result.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _result));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已复制到剪贴板'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('人民币大写转换'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 输入区域
            _buildInputSection(),
            const SizedBox(height: 24),
            // 结果显示区域
            _buildResultSection(),
            const SizedBox(height: 32),
            // 分隔线
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 24),
            // 对照表
            _buildReferenceTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '输入金额',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: _onInputChanged,
          decoration: InputDecoration(
            prefixText: '¥ ',
            prefixStyle: const TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
            hintText: '请输入金额',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clear,
                  )
                : null,
            errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
          ),
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _convert,
          icon: const Icon(Icons.currency_exchange),
          label: const Text('转换'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '转换结果',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              if (_result.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: _copyResult,
                  tooltip: '复制结果',
                  color: Colors.blue,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _result.isNotEmpty ? _result : '等待转换...',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _result.isNotEmpty ? Colors.black87 : Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferenceTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.table_chart, size: 20, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              '数字与人民币大写对照表',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 数字对照
        _buildDigitTable(),
        const SizedBox(height: 16),
        // 单位对照
        _buildUnitTable(),
      ],
    );
  }

  Widget _buildDigitTable() {
    final digits = ['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '数字',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(10, (index) {
                return Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$index',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        digits[index],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitTable() {
    final units = [
      {'name': '拾', 'value': '十'},
      {'name': '佰', 'value': '百'},
      {'name': '仟', 'value': '千'},
      {'name': '万', 'value': '万'},
      {'name': '亿', 'value': '亿'},
      {'name': '元', 'value': '元'},
      {'name': '角', 'value': '角'},
      {'name': '分', 'value': '分'},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '单位',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: units.map((unit) {
                return Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    children: [
                      Text(
                        unit['name']!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        unit['value']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
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
git add app/lib/tools/rmbconvertor/rmbconvertor_page.dart
git commit -m "feat(rmbconvertor): add main page with input, conversion, and reference table"
```

---

## Task 4: 注册工具

**Files:**
- Modify: `app/lib/main.dart`

**描述:** 在 main.dart 中导入并注册 RmbConvertorTool。

- [ ] **Step 1: 修改 main.dart**

Modify: `app/lib/main.dart`

在所有其他 tool imports 之后添加：
```dart
import 'tools/rmbconvertor/rmbconvertor_tool.dart';
```

在所有其他 `ToolRegistry.register` 调用之后添加：
```dart
ToolRegistry.register(RmbConvertorTool());
```

完整修改后的相关部分应如下：

```dart
import 'tools/rmbconvertor/rmbconvertor_tool.dart';  // ADD THIS LINE

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 注册工具
  ToolRegistry.register(CoinTool());
  ToolRegistry.register(DiceTool());
  ToolRegistry.register(CardTool());
  ToolRegistry.register(TodoTool());
  ToolRegistry.register(CalculatorTool());
  ToolRegistry.register(CalendarTool());
  ToolRegistry.register(WeatherTool());
  ToolRegistry.register(GomokuTool());
  ToolRegistry.register(AlarmTool());
  ToolRegistry.register(CanvasTool());
  ToolRegistry.register(PomodoroTool());
  ToolRegistry.register(SnakeTool());
  ToolRegistry.register(QRCodeTool());
  ToolRegistry.register(SudokuTool());
  ToolRegistry.register(AccountTool());
  ToolRegistry.register(RmbConvertorTool());  // ADD THIS LINE

  runApp(const MyApp());
}
```

- [ ] **Step 2: 验证编译**

Run:
```bash
cd app
flutter analyze
```

Expected: No errors or warnings.

- [ ] **Step 3: Commit**

```bash
git add app/lib/main.dart
git commit -m "feat(rmbconvertor): register RmbConvertorTool in main"
```

---

## Task 5: 最终验证

**描述:** 运行完整测试并验证功能。

- [ ] **Step 1: 运行所有测试**

```bash
cd app
flutter test
```

Expected: All tests pass.

- [ ] **Step 2: 检查代码风格**

```bash
cd app
flutter analyze
```

Expected: No issues found.

- [ ] **Step 3: 提交最终变更**

```bash
git log --oneline -5
```

Expected: 看到最近的 4 个提交：
- feat(rmbconvertor): register RmbConvertorTool in main
- feat(rmbconvertor): add main page with input, conversion, and reference table
- feat(rmbconvertor): add ToolModule implementation
- feat(rmbconvertor): add RMB converter core service with tests

---

## 参考文件

- 设计文档: `docs/superpowers/specs/2026-03-24-rmb-converter-design.md`
- 现有工具示例: `app/lib/tools/calculator/`
- 工具注册: `app/lib/core/services/tool_registry.dart`
- UsageService: `app/lib/core/services/usage_service.dart`

---

## 测试场景

实现完成后，请验证以下场景：

1. **基本转换**
   - 输入: 1234.56 → 输出: 壹仟贰佰叁拾肆元伍角陆分
   - 输入: 100000 → 输出: 壹拾万元整

2. **边界值**
   - 输入: 0 → 输出: 零元整
   - 输入: 0.01 → 输出: 壹分
   - 输入: 999999999.99 → 输出正确

3. **错误处理**
   - 输入负数 → 显示错误提示
   - 输入超出范围 → 显示错误提示
   - 输入为空 → 显示等待提示

4. **复制功能**
   - 点击复制按钮 → 显示"已复制到剪贴板"
   - 结果正确复制到剪贴板

5. **UI 验证**
   - 对照表完整显示
   - 输入格式化（千分位）正常
   - 页面可滚动
