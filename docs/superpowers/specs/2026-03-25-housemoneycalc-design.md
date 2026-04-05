# 房贷计算器设计文档

## 概述

房贷计算器是一个帮助用户计算房屋贷款还款详情的工具，支持中国主流的房贷计算方式。

## 功能需求

### 核心功能
- 支持等额本息和等额本金两种还款方式
- 支持商业贷款、公积金贷款、组合贷三种贷款类型
- 支持固定利率和LPR浮动利率两种利率模式
- 显示月供、总还款额、总利息等关键指标
- 还款计划表（年度汇总 + 可展开逐月明细）
- 图表可视化（本金利息占比饼图、还款趋势折线图）

### 用户体验
- 分步向导式交互，降低使用门槛
- 实时计算，即时显示结果
- 清晰的数据展示，支持多维度查看

## 技术架构

### 目录结构

```
lib/tools/housemoneycalc/
├── housemoneycalc_tool.dart      # ToolModule 实现
├── housemoneycalc_page.dart      # 主页面（分步向导容器）
├── models/
│   ├── loan_params.dart          # 贷款参数数据类
│   ├── repayment_result.dart     # 计算结果数据类
│   └── repayment_schedule.dart   # 还款计划数据类
├── services/
│   └── mortgage_calculator.dart  # 核心计算服务
├── widgets/
│   ├── step_loan_type.dart       # 步骤1：贷款类型选择
│   ├── step_loan_params.dart     # 步骤2：参数输入
│   ├── result_summary.dart       # 结果概览卡片
│   ├── result_schedule.dart      # 还款计划表（年度+逐月）
│   └── result_charts.dart        # 图表组件（饼图、趋势图）
└── housemoneycalc_test.dart      # 单元测试
```

### 数据模型

#### LoanParams（贷款参数）

```dart
class LoanParams {
  final RepaymentMethod repaymentMethod;  // 等额本息 / 等额本金
  final LoanType loanType;                // 商业贷 / 公积金 / 组合贷
  final double commercialAmount;          // 商业贷款金额（万元）
  final double providentAmount;           // 公积金贷款金额（万元）
  final int loanTermYears;                // 贷款期限（1-30年）
  final InterestRateType rateType;        // 固定利率 / LPR浮动
  final double? fixedRate;                // 固定利率值（%）
  final double? lprRate;                  // LPR基准利率（%）
  final double? basisPoints;              // 加减基点（%）
}
```

#### RepaymentResult（计算结果）

```dart
class RepaymentResult {
  final double firstMonthPayment;         // 首月月供
  final double lastMonthPayment;          // 末月月供（仅等额本金有效）
  final double totalPayment;              // 总还款额
  final double totalInterest;             // 总利息
  final double totalPrincipal;            // 总本金
  final List<MonthlyData> monthlyData;    // 逐月数据
  final List<YearlyData> yearlyData;      // 年度汇总
}
```

#### MonthlyData（月度数据）

```dart
class MonthlyData {
  final int month;                        // 第几月
  final double payment;                   // 月供
  final double principal;                 // 本金部分
  final double interest;                  // 利息部分
  final double remainingPrincipal;        // 剩余本金
}
```

#### YearlyData（年度数据）

```dart
class YearlyData {
  final int year;                         // 第几年
  final double yearPayment;               // 年度还款总额
  final double yearPrincipal;             // 年度本金
  final double yearInterest;              // 年度利息
  final List<MonthlyData> monthlyData;    // 该年逐月明细
}
```

### 核心算法

#### 等额本息计算公式

```
月利率 = 年利率 / 12
还款月数 = 贷款期限 × 12
月供 = [贷款本金 × 月利率 × (1+月利率)^还款月数] / [(1+月利率)^还款月数 - 1]
总利息 = 月供 × 还款月数 - 贷款本金
```

#### 等额本金计算公式

```
每月本金 = 贷款本金 / 还款月数
第n月利息 = (贷款本金 - 每月本金 × (n-1)) × 月利率
第n月月供 = 每月本金 + 第n月利息
总利息 = (还款月数 + 1) × 贷款本金 × 月利率 / 2
```

#### 组合贷计算

分别计算商业贷款和公积金贷款的还款计划，然后将每月月供相加。

## UI 设计

### 分步向导流程

#### 步骤1：选择贷款类型

```
┌─────────────────────────────────────┐
│  步骤 1/2                            │
├─────────────────────────────────────┤
│                                      │
│  还款方式                             │
│  ┌────────────┐  ┌────────────┐     │
│  │ 等额本息   │  │ 等额本金   │     │
│  │ （月供固定）│  │（逐月递减）│     │
│  └────────────┘  └────────────┘     │
│                                      │
│  贷款类型                             │
│  ┌────────┐ ┌────────┐ ┌────────┐   │
│  │商业贷款 │ │公积金  │ │ 组合贷 │   │
│  └────────┘ └────────┘ └────────┘   │
│                                      │
│           [    下一步    ]           │
└─────────────────────────────────────┘
```

#### 步骤2：输入贷款参数

```
┌─────────────────────────────────────┐
│  步骤 2/2                            │
├─────────────────────────────────────┤
│                                      │
│  贷款金额          [        ] 万元   │
│  （组合贷时显示两行：商贷金额、公积金金额）│
│                                      │
│  贷款期限          [    ▼   ] 年     │
│  （1-30年下拉选择）                   │
│                                      │
│  利率类型                             │
│  ● 固定利率    ○ LPR浮动利率          │
│                                      │
│  [年利率      ] %                    │
│  或                                  │
│  LPR [ 3.95 ▼]%  [基点  -0.3]%       │
│                                      │
│  [   开始计算   ]                    │
└─────────────────────────────────────┘
```

#### 步骤3：计算结果（概览标签）

```
┌─────────────────────────────────────┐
│  [概览]  [还款计划]  [图表]          │
├─────────────────────────────────────┤
│                                      │
│  ┌─────────────────────────────────┐│
│  │ 首月月供                        ││
│  │       ¥8,432.56                ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────┐ ┌─────────┐ ┌────────┐ │
│  │ 总还款  │ │ 总利息  │ │ 总本金 │ │
│  │303万   │ │ 103万   │ │ 200万  │ │
│  └─────────┘ └─────────┘ └────────┘ │
│                                      │
│  ┌─────────────────────────────────┐│
│  │ 与等额本金对比                  ││
│  │ 多付利息：¥32,456              ││
│  │ 但前期月供更低                  ││
│  └─────────────────────────────────┘│
│                                      │
│           [ 重新计算 ]               │
└─────────────────────────────────────┘
```

#### 步骤3：计算结果（还款计划标签）

```
┌─────────────────────────────────────┐
│  [概览]  [还款计划]  [图表]          │
├─────────────────────────────────────┤
│                                      │
│  年份    累计还款   本金     利息    │
│  ─────────────────────────────────── │
│  ▼ 第1年  101,232  32,456   68,776  │
│    ├─ 1月  8,432    2,704    5,728  │
│    ├─ 2月  8,432    2,715    5,717  │
│    ├─ ...                          │
│    └─ 12月 8,432    2,823    5,609  │
│  ▶ 第2年  101,232  34,567   66,665  │
│  ▶ 第3年  101,232  36,789   64,443  │
│  ...                                │
│                                      │
└─────────────────────────────────────┘
```

#### 步骤3：计算结果（图表标签）

```
┌─────────────────────────────────────┐
│  [概览]  [还款计划]  [图表]          │
├─────────────────────────────────────┤
│                                      │
│  ┌─────────────────────────────────┐│
│  │      本金 vs 利息 饼图          ││
│  │                                 ││
│  │    ┌───────────┐                ││
│  │    │  本金 66% │                ││
│  │    │  利息 34% │                ││
│  │    └───────────┘                ││
│  └─────────────────────────────────┘│
│                                      │
│  ┌─────────────────────────────────┐│
│  │      月供趋势折线图              ││
│  │                                 ││
│  │  月供 ▲                         ││
│  │      │╲                        ││
│  │      │  ╲___                   ││
│  │      │      ╲_________         ││
│  │      └────────────────────▶ 月数││
│  └─────────────────────────────────┘│
│                                      │
└─────────────────────────────────────┘
```

## 实现细节

### ToolModule 实现

```dart
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
  // ... 其他方法
}
```

### 状态管理

使用 StatefulWidget 管理分步向导状态：
- `currentStep`: 当前步骤（1或2）
- `loanParams`: 用户输入的贷款参数
- `calculationResult`: 计算结果（步骤3显示）

### 图表实现

使用 `fl_chart` 库绘制：
- 饼图：展示本金和利息的比例
- 折线图：展示月供变化趋势（等额本金显示递减曲线）

## 测试计划

### 单元测试

1. **计算公式测试**
   - 等额本息计算准确性（对比Excel结果）
   - 等额本金计算准确性
   - 组合贷计算准确性

2. **边界测试**
   - 最小贷款金额（1万元）
   - 最长期限（30年）
   - 最低利率（1%）和最高利率（10%）

3. **数据模型测试**
   - 月度数据累加等于年度数据
   - 总本金等于贷款金额

### 集成测试

1. 分步向导页面流转
2. 参数输入验证
3. 还款计划表展开/收起

## 依赖项

- `fl_chart: ^0.66.0` - 图表绘制

## 注册方式

在 `main.dart` 中添加：

```dart
import 'tools/housemoneycalc/housemoneycalc_tool.dart';

void main() {
  // ...
  ToolRegistry.register(HouseMoneyCalcTool());
  // ...
}
```

## 参考资源

- 等额本息公式：https://zh.wikipedia.org/wiki/等额本息
- 等额本金公式：https://zh.wikipedia.org/wiki/等额本金
- LPR利率说明：https://www.pbc.gov.cn/ 中国人民银行官网
