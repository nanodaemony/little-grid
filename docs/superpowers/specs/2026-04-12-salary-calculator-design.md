# 工资计算器设计文档

**日期**: 2026-04-12
**版本**: 1.0.0
**作者**: Little Grid Team

## 概述

开发一个新的工具格子：工资计算器。用户输入税前工资，自动计算五险一金、个人所得税等，最终得出税后工资。

## 需求规格

### 功能需求
- ✅ 中国内地个税和五险一金计算
- ✅ 支持预设城市配置（10+城市）
- ✅ 支持自定义五险一金缴费基数和比例
- ✅ 支持7项专项附加扣除
- ✅ 个税累计预扣法计算
- ✅ 显示每月税额和年度累计
- ✅ 计算历史记录保存
- ✅ 支持添加标签管理历史记录
- ✅ 图表展示月度税额走势
- ✅ 快速预设工资档位

### 非功能需求
- 界面简洁直观，符合项目现有风格
- 计算准确，符合中国税法规定
- 响应式设计，适配不同屏幕尺寸
- 数据本地持久化，保护用户隐私

## 架构设计

### 目录结构

```
salary_calculator/
├── salary_calculator_tool.dart    # 工具注册类
├── salary_calculator_page.dart    # 主页面
├── models/
│   ├── salary_result.dart         # 计算结果模型
│   ├── city_config.dart           # 城市社保配置
│   └── history_item.dart          # 历史记录项
├── services/
│   ├── salary_calculator_service.dart   # 核心计算服务
│   ├── city_config_service.dart         # 城市配置服务
│   └── history_service.dart             # 历史记录服务
└── widgets/
    ├── salary_input_section.dart        # 工资输入区域
    ├── insurance_section.dart           # 五险一金配置区域
    ├── deduction_section.dart           # 专项附加扣除区域
    ├── result_overview_card.dart        # 结果概览卡片
    ├── monthly_detail_list.dart         # 月度明细列表
    ├── tax_chart_widget.dart            # 税额图表
    └── history_section.dart             # 历史记录区域
```

### 工具注册信息

- **ID**: `salary_calculator`
- **名称**: `工资计算器`
- **图标**: `Icons.payment`
- **分类**: `ToolCategory.calc`
- **格子大小**: `1`

## 数据模型

### CityConfig（城市社保配置）

```dart
class CityConfig {
  final String id;           // 城市ID，如 'beijing'
  final String name;         // 城市名称，如 '北京'
  final double pensionBase;  // 养老保险基数下限
  final double pensionBaseMax; // 养老保险基数上限
  final double pensionRate;  // 养老保险个人比例
  final double medicalRate;  // 医疗保险个人比例
  final double unemploymentRate; // 失业保险个人比例
  final double housingFundRate; // 公积金个人比例
  final double housingFundBase;  // 公积金基数下限
  final double housingFundBaseMax; // 公积金基数上限
}
```

### SalaryResult（计算结果）

```dart
class SalaryResult {
  final double preTaxSalary;      // 税前工资
  final double totalInsurance;    // 五险一金总额
  final double totalDeduction;    // 专项附加扣除总额
  final double taxableIncome;     // 应纳税所得额
  final double totalTax;          // 年度个税总额
  final double afterTaxSalary;    // 税后工资（单月）
  final List<MonthlyTaxDetail> monthlyDetails; // 12个月明细
}

class MonthlyTaxDetail {
  final int month;                // 月份
  final double cumulativeTaxable;  // 累计应纳税所得额
  final double cumulativeTax;      // 累计已缴税额
  final double monthlyTax;         // 当月税额
  final double monthlyAfterTax;    // 当月税后
}
```

### HistoryItem（历史记录）

```dart
class HistoryItem {
  final String id;
  final DateTime timestamp;
  final double preTaxSalary;
  final String cityName;
  final double afterTaxSalary;
  final String? label;            // 可选标签
}
```

## 计算逻辑

### 五险一金计算

```
每项社保缴费 = min( max( 税前工资, 基数下限 ), 基数上限 ) × 比例
五险一金总额 = 养老保险 + 医疗保险 + 失业保险 + 公积金
```

### 个税计算（累计预扣法）

```
每月应纳税所得额 = 税前工资 - 5000（起征点）- 五险一金 - 专项附加扣除

累计应纳税所得额 = 当年截至本月的应纳税所得额之和

累计应纳税额 = 根据累计应纳税所得额查找税率表计算

当月应纳税额 = 累计应纳税额 - 上月累计已缴税额
```

### 个税税率表（综合所得）

| 级数 | 累计应纳税所得额 | 税率 | 速算扣除数 |
|------|-----------------|------|-----------|
| 1 | ≤36,000元 | 3% | 0 |
| 2 | 36,000-144,000元 | 10% | 2,520 |
| 3 | 144,000-300,000元 | 20% | 16,920 |
| 4 | 300,000-420,000元 | 25% | 31,920 |
| 5 | 420,000-660,000元 | 30% | 52,920 |
| 6 | 660,000-960,000元 | 35% | 85,920 |
| 7 | >960,000元 | 45% | 181,920 |

### 预设城市列表

1. 北京
2. 上海
3. 广州
4. 深圳
5. 杭州
6. 南京
7. 成都
8. 武汉
9. 西安
10. 重庆

### 专项附加扣除项

1. 子女教育
2. 继续教育
3. 大病医疗
4. 住房贷款利息
5. 住房租金
6. 赡养老人
7. 3岁以下婴幼儿照护

### 快速预设工资档位

- 5,000元
- 8,000元
- 10,000元
- 15,000元
- 20,000元
- 30,000元
- 50,000元

## UI界面设计

### 主页面布局

```
┌─────────────────────────────────┐
│  工资计算器          [ ⋮ ]      │ ← AppBar（带保存、分享按钮）
├─────────────────────────────────┤
│  [ 滚动区域 ]                    │
│                                 │
│  ┌─────────────────────────┐   │
│  │  税前工资：[ 输入框 ]   │   │ ← 输入区域
│  │  城市：[ 下拉选择 ]     │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │  五险一金配置  [展开/收起] │ │ ← 可折叠区域
│  │  [ 自定义开关 ]          │   │
│  │  各项社保基数和比例...   │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │  专项附加扣除  [展开/收起] │ │ ← 可折叠区域
│  │  • 子女教育 [金额]       │   │
│  │  • 继续教育 [金额]       │   │
│  │  • 大病医疗 [金额]       │   │
│  │  • 住房贷款利息 [金额]   │   │
│  │  • 住房租金 [金额]       │   │
│  │  • 赡养老人 [金额]       │   │
│  │  • 3岁以下婴幼儿 [金额]  │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │  📊 结果概览            │   │
│  │  税前：¥XX,XXX          │   │ ← 结果卡片
│  │  税后：¥XX,XXX          │   │
│  │  个税：¥XX,XXX          │   │
│  │  五险一金：¥X,XXX       │   │
│  └─────────────────────────┘   │
│                                 │
│  [ 单月 / 全年 ]  切换标签     │
│                                 │
│  ┌─────────────────────────┐   │
│  │  月度明细列表           │   │ ← 或 图表
│  │  1月：税额¥XXX...       │   │
│  │  2月：税额¥XXX...       │   │
│  │  ...                    │   │
│  └─────────────────────────┘   │
│                                 │
│  ┌─────────────────────────┐   │
│  │  📜 计算历史            │   │
│  │  [ 历史列表 ]           │   │
│  │  [ 添加标签 ] [ 删除 ]  │   │
│  └─────────────────────────┘   │
│                                 │
└─────────────────────────────────┘
```

## 数据持久化

### SharedPreferences 保存内容

- 上次使用的城市
- 上次输入的工资
- 自定义的社保配置
- 专项附加扣除历史输入

### 历史记录保存

使用 SQLite 或 JSON 文件保存计算历史记录，支持：
- 无限保存
- 添加标签
- 删除记录
- 按时间排序

## 错误处理

- 输入验证：工资必须大于0
- 基数验证：确保自定义基数在合理范围内
- 优雅降级：计算出错时显示友好提示

## 依赖关系

- 遵循项目现有的工具注册机制
- 使用项目现有的主题和组件
- 复用项目现有的 SharedPreferences 封装
