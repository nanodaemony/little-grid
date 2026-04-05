# 科学计算器设计文档

**日期**: 2026-03-22
**状态**: 待审核
**分类**: calc

---

## 1. 功能概述

在 LittleGrid 应用中新增一个科学计算器工具，作为可滑动切换双模式的高级计算功能。用户可通过左右滑动在「基础模式」和「科学模式」之间切换。

### 1.1 功能范围

**基础模式功能**:
- 数字输入：0-9
- 基础运算符：+、-、×、÷
- 括号：(, )
- 其他功能：正负号(±)、百分比(%)、小数点(.)、退格(⌫)、清空(C)、等于(=)

**科学模式功能**（基础模式 +）:
- 三角函数：sin、cos、tan
- 对数函数：log（常用对数）、ln（自然对数）
- 幂函数：x²、xʸ、√（平方根）
- 阶乘：n!
- 数学常量：π、e
- 角度模式切换：角度制(DEG)/弧度制(RAD)

**记忆功能**:
- M+（将当前结果加到记忆）
- M-（从记忆减去当前结果）
- MR（读取记忆值）
- MC（清除记忆）

**历史记录**:
- 会话级历史（当前页面内有效）
- 保存最近 20 条计算记录
- 支持从历史中点击重新加载表达式

---

## 2. 架构设计

### 2.1 模块结构

```
lib/tools/calculator/
├── calculator_tool.dart         # ToolModule 实现
├── calculator_page.dart         # 主页面（Scaffold + PageView）
├── models/
│   └── calculator_state.dart    # 状态管理类
├── widgets/
│   ├── display_panel.dart       # 双行显示组件
│   ├── keyboard_base.dart       # 基础键盘（4×4 网格）
│   ├── keyboard_scientific.dart # 科学键盘（5×4 网格）
│   ├── calculator_key.dart      # 单个按键组件
│   └── history_panel.dart       # 历史记录面板
└── services/
    └── calculator_service.dart  # 计算引擎封装
```

### 2.2 类定义

#### CalculatorTool
实现 `ToolModule` 接口，注册到 `ToolRegistry`。

```dart
class CalculatorTool implements ToolModule {
  @override
  String get id => 'calculator';

  @override
  String get name => '科学计算器';

  @override
  IconData get icon => Icons.calculate;

  @override
  ToolCategory get category => ToolCategory.calc;

  @override
  int get gridSize => 1;
}
```

#### CalculatorState
管理计算器状态，使用 `ChangeNotifier` 或集成到现有 Provider 架构。

```dart
class CalculatorState extends ChangeNotifier {
  String expression = '';      // 当前表达式
  String result = '0';         // 当前结果
  bool isDegreeMode = true;    // 角度/弧度模式
  double memoryValue = 0;      // 记忆值
  bool hasMemoryValue = false; // 是否有记忆值
  List<CalculationHistory> history = []; // 计算历史
}
```

#### CalculatorService
封装 `math_expressions` 库的计算逻辑。

```dart
class CalculatorService {
  String evaluate(String expression, bool isDegreeMode);
  bool isValidExpression(String expression);
  String formatResult(double value);
}
```

---

## 3. 界面设计

### 3.1 页面布局

```
┌─────────────────────────┐
│  ←  科学计算器           │  AppBar
├─────────────────────────┤
│                         │
│    3 + sin(45)          │  表达式行（20px，灰色）
│    = 3.707...           │  结果行（48px，白色加粗）
│                         │
├─────────────────────────┤
│   ●   ○                 │  页面指示器（当前页高亮）
├─────────────────────────┤
│                         │
│   ┌─────────────────┐   │
│   │                 │   │
│   │  PageView       │   │  键盘区域（占屏幕 60%）
│   │  ┌───┬───┐      │   │
│   │  │基础│科学│     │   │  左右滑动切换
│   │  └───┴───┘      │   │
│   │                 │   │
│   └─────────────────┘   │
│                         │
└─────────────────────────┘
```

### 3.2 键盘布局

**基础键盘（4列 × 5行）**:
| C | ⌫ | % | ÷ |
|-----|-----|-----|-----|
| 7 | 8 | 9 | × |
| 4 | 5 | 6 | - |
| 1 | 2 | 3 | + |
| ± | 0 | . | = |

**科学键盘 - 第一页（5列 × 5行）**:
| DEG | C | ⌫ | % | ÷ |
|------|-----|-----|-----|-----|
| sin | 7 | 8 | 9 | × |
| cos | 4 | 5 | 6 | - |
| tan | 1 | 2 | 3 | + |
| π | 0 | . | = | e |

**科学键盘 - 第二页（5列 × 5行，从第一页右滑进入）**:
| DEG | C | ⌫ | n! | ÷ |
|------|-----|-----|-----|-----|
| log | 7 | 8 | 9 | × |
| ln | 4 | 5 | 6 | - |
| x² | 1 | 2 | 3 | + |
| √ | M+ | M- | MR | xʸ |

**说明**:
- `DEG/RAD`：全局模式切换按钮，显示在两页同一位置，点击切换角度制/弧度制，文字随之变化，状态在页面间同步
- `π`、`e`：独立按键，分别输入 `pi` 和 `e`
- `√`、`xʸ`：独立按键，分别输入 `sqrt(` 和 `^`

### 3.3 视觉规范

**颜色**:
- 显示区背景：`Colors.grey.shade900`
- 表达式文字：`Colors.grey.shade400`，20px
- 结果文字：`Colors.white`，48px，FontWeight.bold
- 数字键背景：`AppColors.surface`
- 运算符键背景：`AppColors.primary.withOpacity(0.1)`
- 函数键背景：`AppColors.categoryCalc.withOpacity(0.1)`
- 等号键背景：`AppColors.primary`
- 等号文字：`Colors.white`

**动效**:
- 按键点击：水波纹 + scale 0.95，持续 100ms
- PageView 切换：自然滑动，吸附动画
- 结果显示：fadeIn + scale，持续 200ms

---

## 4. 功能规格

### 4.1 计算引擎

使用 `math_expressions` 库（版本 ^2.6.0）。

**支持的表达式格式**:
- 基础运算：`3 + 5 * 2` → 13
- 括号：`(3 + 5) * 2` → 16
- 对数：`log(100)` → 2，`ln(e)` → 1
- 幂运算：`2^3` → 8，`sqrt(16)` → 4
- 常量：`pi * 2` → 6.28...，`e^1` → 2.718...

**角度模式处理**:
`math_expressions` 库默认使用弧度制。实现角度模式切换的方式：

使用表达式变量替换方法：
```dart
String evaluate(String expression, bool isDegreeMode) {
  Parser parser = Parser();
  Expression exp = parser.parse(expression);

  ContextModel context = ContextModel();

  // 绑定自定义三角函数
  if (isDegreeMode) {
    // 使用变量绑定方式，将角度转换为弧度
    context.bindVariable(Variable('sin'), _degreeSinFunction);
    context.bindVariable(Variable('cos'), _degreeCosFunction);
    context.bindVariable(Variable('tan'), _degreeTanFunction);
  }

  double result = exp.evaluate(EvaluationType.REAL, context);
  return formatResult(result);
}

// 自定义角度三角函数
final _degreeSinFunction = CustomFunction('sin', ['x'],
  (args) => math.sin(args[0] * math.pi / 180));
```

或者使用表达式重写方法（更简单的实现）：
```dart
String convertToDegreeExpression(String expression) {
  // 在解析前，将所有 sin/cos/tan 函数包装为 sin((...)*pi/180)
  // 使用正则表达式：sin(\(.*?)\) → sin(($1)*pi/180)
  // 需要递归处理嵌套括号
}
```

**推荐方案**：使用自定义函数绑定（第一种方法），它可以正确处理嵌套表达式如 `sin(45+30)` 和 `sin(cos(45))`。

实现细节：
1. 创建 `DegreeContextModel` 类继承 `ContextModel`
2. 重写 `getFunction` 方法，返回包装后的三角函数
3. 包装函数内部将参数从角度转换为弧度
4. 示例：`sin(45)` + DEG 模式 → 计算 `sin(45°)` → 1.0
5. 嵌套表达式：`sin(cos(45))` → 计算 `sin(cos(45°))` → `sin(0.707...)` → `sin(0.707°)` → 0.0123...

### 4.2 输入处理

**运算符处理**:
- 连续运算符：替换上一个（`3++5` → `3+5`）
- 以小数点开头：自动补零（`.5` → `0.5`）
- ~~括号自动补全~~：**本期不包含**，用户需手动输入完整括号

**记忆功能逻辑**:
- M+：`memory += currentResult`
- M-：`memory -= currentResult`
- MR：将 memory 值插入当前表达式
- MC：`memory = 0`，隐藏记忆指示器

### 4.3 历史记录

**数据模型**:
```dart
class CalculationHistory {
  final String expression;
  final String result;
  final DateTime timestamp;
}
```

**行为**:
- 点击 = 后自动保存到历史
- 历史面板从右侧滑入（类似现有 drawer）
- 点击历史项将表达式加载到当前输入
- 限制 20 条，超出后删除最旧的
- 页面关闭后清空（会话级）

---

## 5. 错误处理

### 5.1 计算错误

| 错误类型 | 处理方式 | 显示信息 |
|---------|---------|---------|
| 除零错误 | 捕获异常 | "不能除以零" |
| 无效表达式 | 预检查或异常捕获 | "无效输入" |
| 数值溢出 | 结果值检查 | "数值过大" |
| 括号不匹配 | 预检查 | "括号不匹配" |
| 空表达式点击= | 无操作 | 无显示或保持当前结果 |

### 5.2 边界情况

- 表达式字符限制：最多 100 字符，超限后禁用输入
- 结果精度：小数位最多 10 位，超出使用科学计数法
- 浮点精度：sin(90°) 可能显示 0.999999，智能取整到 6 位小数

---

## 6. 依赖项

```yaml
dependencies:
  math_expressions: ^2.6.0
  # 现有依赖保持不变
```

---

## 7. 文件清单

| 文件路径 | 描述 | 行数预估 |
|---------|------|---------|
| `lib/tools/calculator/calculator_tool.dart` | ToolModule 实现 | 40 |
| `lib/tools/calculator/calculator_page.dart` | 主页面 | 150 |
| `lib/tools/calculator/models/calculator_state.dart` | 状态管理 | 80 |
| `lib/tools/calculator/widgets/display_panel.dart` | 显示组件 | 60 |
| `lib/tools/calculator/widgets/keyboard_base.dart` | 基础键盘 | 80 |
| `lib/tools/calculator/widgets/keyboard_scientific.dart` | 科学键盘 | 100 |
| `lib/tools/calculator/widgets/calculator_key.dart` | 按键组件 | 60 |
| `lib/tools/calculator/widgets/history_panel.dart` | 历史面板 | 80 |
| `lib/tools/calculator/services/calculator_service.dart` | 计算服务 | 60 |
| **总计** | | **~710 行** |

---

## 8. 验收标准

- [ ] 基础四则运算结果正确
- [ ] 科学函数（sin/cos/tan/log/ln）结果正确
- [ ] 角度/弧度切换工作正常
- [ ] 记忆功能（M+/M-/MR/MC）工作正常
- [ ] PageView 滑动切换流畅
- [ ] 历史记录保存和加载正常
- [ ] 错误处理显示友好提示
- [ ] 视觉风格与现有应用一致
- [ ] 响应式布局适配不同屏幕

---

## 9. 后续扩展（可选）

- 单位转换功能（长度、重量、温度等）
- 方程式求解器
- 图形绘制功能
- 自定义主题颜色
- 历史记录持久化存储
