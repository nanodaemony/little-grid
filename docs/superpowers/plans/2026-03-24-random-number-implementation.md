# 随机数工具实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现一个随机数生成工具，支持设置范围、数量、是否允许重复，并展示生成结果

**Architecture:** 采用标准的 ToolModule 模式，包含 random_tool.dart（模块注册）和 random_page.dart（UI页面）。使用 StatefulWidget 管理状态，输入校验实时反馈。

**Tech Stack:** Flutter, Dart (dart:math)

---

## 文件结构

```
app/lib/tools/random/
├── random_tool.dart    # ToolModule 实现，注册到 ToolRegistry
└── random_page.dart    # UI 页面，包含状态和生成逻辑

app/lib/main.dart       # 修改：注册 RandomTool
```

---

## Task 1: 创建 random_tool.dart

**文件：**
- Create: `app/lib/tools/random/random_tool.dart`

**参考文件：**
- `app/lib/tools/dice/dice_tool.dart` - ToolModule 实现模式
- `app/lib/core/services/tool_registry.dart` - ToolCategory 枚举

**任务：**

- [ ] **Step 1: 创建 random_tool.dart 文件**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'random_page.dart';

class RandomTool implements ToolModule {
  @override
  String get id => 'random';

  @override
  String get name => '随机数';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.shuffle;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const RandomPage();
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

- [ ] **Step 2: 验证文件创建成功**

Run: `ls -la app/lib/tools/random/random_tool.dart`
Expected: 文件存在

- [ ] **Step 3: Commit**

```bash
git add app/lib/tools/random/random_tool.dart
git commit -m "feat(random): add RandomTool module implementation

- Implement ToolModule interface for random number generator
- Configure as game category with shuffle icon
- Link to RandomPage UI

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 2: 创建 random_page.dart - 状态类和默认值

**文件：**
- Create: `app/lib/tools/random/random_page.dart`

**参考文件：**
- `app/lib/tools/dice/dice_page.dart` - 页面结构参考

**任务：**

- [ ] **Step 1: 创建状态类和页面框架**

```dart
import 'dart:math';
import 'package:flutter/material.dart';

class RandomPage extends StatefulWidget {
  const RandomPage({super.key});

  @override
  State<RandomPage> createState() => _RandomPageState();
}

class _RandomPageState extends State<RandomPage> {
  // 状态
  int _minValue = 1;
  int _maxValue = 100;
  int _count = 1;
  bool _allowDuplicate = true;
  bool _isSettingsExpanded = false;
  List<int> _results = [];

  // 错误信息
  String? _minError;
  String? _maxError;
  String? _countError;

  final Random _random = Random();
  final TextEditingController _minController = TextEditingController(text: '1');
  final TextEditingController _maxController = TextEditingController(text: '100');
  final TextEditingController _countController = TextEditingController(text: '1');

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('随机数'),
        actions: [
          IconButton(
            icon: Icon(_isSettingsExpanded ? Icons.expand_less : Icons.expand_more),
            onPressed: () {
              setState(() {
                _isSettingsExpanded = !_isSettingsExpanded;
              });
            },
          ),
        ],
      ),
      body: const Center(child: Text('TODO: implement UI')),
    );
  }
}
```

- [ ] **Step 2: 验证文件创建**

Run: `ls -la app/lib/tools/random/random_page.dart`
Expected: 文件存在

- [ ] **Step 3: Commit**

```bash
git add app/lib/tools/random/random_page.dart
git commit -m "feat(random): add RandomPage with state management

- Define state variables for min/max values, count, duplicate setting
- Add text controllers for input fields
- Implement expandable settings panel toggle
- Add dispose cleanup

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 3: 实现输入校验逻辑

**文件：**
- Modify: `app/lib/tools/random/random_page.dart` - 添加校验方法

**任务：**

- [ ] **Step 1: 添加校验方法**

在 `_RandomPageState` 类中添加以下方法：

```dart
  void _validateMin(String value) {
    final intValue = int.tryParse(value);
    if (intValue == null) {
      setState(() => _minError = '请输入有效的整数');
      return;
    }
    if (intValue < 1) {
      setState(() => _minError = '最小值不能小于1');
      return;
    }
    if (intValue >= _maxValue) {
      setState(() => _minError = '最小值必须小于最大值');
      return;
    }
    setState(() {
      _minError = null;
      _minValue = intValue;
    });
  }

  void _validateMax(String value) {
    final intValue = int.tryParse(value);
    if (intValue == null) {
      setState(() => _maxError = '请输入有效的整数');
      return;
    }
    if (intValue > 999999999) {
      setState(() => _maxError = '最大值不能超过999999999');
      return;
    }
    if (intValue <= _minValue) {
      setState(() => _maxError = '最大值必须大于最小值');
      return;
    }
    setState(() {
      _maxError = null;
      _maxValue = intValue;
    });
  }

  void _validateCount(String value) {
    final intValue = int.tryParse(value);
    if (intValue == null) {
      setState(() => _countError = '请输入有效的整数');
      return;
    }
    if (intValue < 1 || intValue > 100) {
      setState(() => _countError = '数量必须在1-100之间');
      return;
    }
    if (!_allowDuplicate && intValue > (_maxValue - _minValue + 1)) {
      setState(() => _countError = '范围不足以生成${intValue}个不重复的数');
      return;
    }
    setState(() {
      _countError = null;
      _count = intValue;
    });
  }

  bool _hasError() {
    return _minError != null || _maxError != null || _countError != null;
  }
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/random/random_page.dart
git commit -m "feat(random): add input validation methods

- Validate min value (>= 1, < max)
- Validate max value (<= 999999999, > min)
- Validate count (1-100, fits in range when no duplicates)
- Add _hasError() helper

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 4: 实现随机数生成逻辑

**文件：**
- Modify: `app/lib/tools/random/random_page.dart` - 添加生成方法

**任务：**

- [ ] **Step 1: 添加生成方法**

在 `_RandomPageState` 类中添加以下方法：

```dart
  void _generateRandomNumbers() {
    if (_hasError()) return;

    setState(() {
      if (_allowDuplicate) {
        // 允许重复：直接随机生成
        _results = List.generate(
          _count,
          (_) => _minValue + _random.nextInt(_maxValue - _minValue + 1),
        );
      } else {
        // 不允许重复：使用 Fisher-Yates 洗牌
        final range = List.generate(
          _maxValue - _minValue + 1,
          (i) => _minValue + i,
        );
        for (int i = range.length - 1; i > 0; i--) {
          final j = _random.nextInt(i + 1);
          final temp = range[i];
          range[i] = range[j];
          range[j] = temp;
        }
        _results = range.take(_count).toList();
      }
    });
  }

  void _resetToDefaults() {
    setState(() {
      _minValue = 1;
      _maxValue = 100;
      _count = 1;
      _allowDuplicate = true;
      _results = [];
      _minError = null;
      _maxError = null;
      _countError = null;
      _minController.text = '1';
      _maxController.text = '100';
      _countController.text = '1';
    });
  }
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/random/random_page.dart
git commit -m "feat(random): add random number generation logic

- Implement generation with duplicates allowed (random.nextInt)
- Implement generation without duplicates (Fisher-Yates shuffle)
- Add reset to defaults functionality
- Validate before generation

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 5: 实现设置面板 UI

**文件：**
- Modify: `app/lib/tools/random/random_page.dart` - 替换 build 方法

**任务：**

- [ ] **Step 1: 创建设置面板 widget**

在 `_RandomPageState` 类中添加以下方法：

```dart
  Widget _buildSettingsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 最小值
          Row(
            children: [
              const SizedBox(width: 80, child: Text('最小值:')),
              Expanded(
                child: TextField(
                  controller: _minController,
                  keyboardType: TextInputType.number,
                  onChanged: _validateMin,
                  decoration: InputDecoration(
                    errorText: _minError,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 最大值
          Row(
            children: [
              const SizedBox(width: 80, child: Text('最大值:')),
              Expanded(
                child: TextField(
                  controller: _maxController,
                  keyboardType: TextInputType.number,
                  onChanged: _validateMax,
                  decoration: InputDecoration(
                    errorText: _maxError,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 数量
          Row(
            children: [
              const SizedBox(width: 80, child: Text('数量:')),
              Expanded(
                child: TextField(
                  controller: _countController,
                  keyboardType: TextInputType.number,
                  onChanged: _validateCount,
                  decoration: InputDecoration(
                    errorText: _countError,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: const OutlineInputBorder(),
                    suffixText: '个',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 允许重复
          Row(
            children: [
              const SizedBox(width: 80, child: Text('选项:')),
              Checkbox(
                value: _allowDuplicate,
                onChanged: (value) {
                  setState(() {
                    _allowDuplicate = value ?? true;
                    _validateCount(_countController.text);
                  });
                },
              ),
              const Text('允许重复'),
            ],
          ),
          const SizedBox(height: 8),
          // 重置按钮
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _resetToDefaults,
              child: const Text('重置为默认值'),
            ),
          ),
        ],
      ),
    );
  }
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/random/random_page.dart
git commit -m "feat(random): add settings panel UI

- Add input fields for min/max values and count
- Add checkbox for duplicate setting
- Add reset to defaults button
- Style with grey background and borders

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 6: 实现主页面布局

**文件：**
- Modify: `app/lib/tools/random/random_page.dart` - 替换 build 方法

**任务：**

- [ ] **Step 1: 替换 build 方法**

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('随机数'),
        actions: [
          IconButton(
            icon: Icon(_isSettingsExpanded ? Icons.expand_less : Icons.expand_more),
            tooltip: _isSettingsExpanded ? '收起设置' : '展开设置',
            onPressed: () {
              setState(() {
                _isSettingsExpanded = !_isSettingsExpanded;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 设置摘要
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '范围: $_minValue - $_maxValue  数量: $_count个  ${_allowDuplicate ? "" : "(不重复)"}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          // 设置面板（可展开）
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildSettingsPanel(),
            crossFadeState: _isSettingsExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          // 结果展示区域
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shuffle,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '点击下方按钮生成随机数',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: _results.map((number) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$number',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ),
          // 生成按钮
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _hasError() ? null : _generateRandomNumbers,
                icon: const Icon(Icons.shuffle),
                label: const Text(
                  '生成随机数',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/random/random_page.dart
git commit -m "feat(random): implement main page layout

- Add settings summary bar showing current configuration
- Implement collapsible settings panel with animation
- Add empty state with icon and hint text
- Style results with primary container background
- Add large generate button at bottom
- Disable button when validation errors exist

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 7: 在 main.dart 中注册工具

**文件：**
- Modify: `app/lib/main.dart` - 添加 import 和注册

**参考：** 查看其他工具的 import 和注册方式

**任务：**

- [ ] **Step 1: 添加 import**

在 main.dart 中找到其他工具的 import 位置，添加：

```dart
import 'tools/random/random_tool.dart';
```

- [ ] **Step 2: 注册工具**

在 `ToolRegistry.registerAll` 或其他工具注册的位置，添加：

```dart
ToolRegistry.register(RandomTool());
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/main.dart
git commit -m "feat(random): register RandomTool in app

- Add import for RandomTool
- Register RandomTool in ToolRegistry

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 8: 验证实现

**任务：**

- [ ] **Step 1: 检查代码格式**

Run: `cd app && flutter format lib/tools/random/`
Expected: 无错误

- [ ] **Step 2: 分析代码**

Run: `cd app && flutter analyze lib/tools/random/`
Expected: 无错误

- [ ] **Step 3: 验证文件结构**

Run:
```bash
ls -la app/lib/tools/random/
```
Expected:
```
random_tool.dart
random_page.dart
```

- [ ] **Step 4: 验证 main.dart 修改**

Run:
```bash
grep -n "RandomTool" app/lib/main.dart
```
Expected: 包含 import 和 register 两行

- [ ] **Step 5: 最终 Commit（如果需要）**

如果上一步有格式化改动：

```bash
git add app/lib/tools/random/
git commit -m "style(random): apply dart formatting

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## 测试清单

实现完成后，手动测试以下场景：

- [ ] 生成默认设置的随机数（1-100，1个，允许重复）
- [ ] 修改范围为 1-6，数量 2，模拟骰子效果
- [ ] 设置数量 10，验证能生成 10 个数字
- [ ] 取消"允许重复"，范围 1-5，数量 5，验证生成 1,2,3,4,5
- [ ] 输入非法值（负数、超大数、非数字）验证错误提示
- [ ] 验证最小值 >= 最大值时显示错误
- [ ] 验证不重复时数量超过范围显示错误
- [ ] 点击"重置为默认值"恢复初始状态
- [ ] 展开/折叠设置面板正常

---

## 参考模式

**类似工具实现：**
- `app/lib/tools/dice/dice_tool.dart` - ToolModule 模式
- `app/lib/tools/dice/dice_page.dart` - 游戏类工具页面结构
- `app/lib/tools/coin/coin_tool.dart` - 简单工具模式

**相关文档：**
- `docs/superpowers/specs/2026-03-24-random-number-design.md` - 设计文档
