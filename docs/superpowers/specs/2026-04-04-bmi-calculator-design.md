# BMI 计算器设计文档

## 概述

BMI 计算器是一个用于计算身体质量指数（Body Mass Index）的健康工具。用户通过滑动条或直接输入身高和体重，实时获得 BMI 数值、健康等级评价和健康建议。工具采用单屏设计，输入和结果同时展示，提供即时反馈。

## 功能需求

### 核心功能
- 支持身高输入（100-250cm）
- 支持体重输入（30-200kg）
- 实时计算 BMI 数值
- 显示健康等级（偏瘦/正常/超重/肥胖）
- 提供健康建议
- 显示理想体重范围
- 保存上次计算结果

### 单位系统
- 仅支持公制单位（厘米/千克）
- 符合中国用户习惯

### BMI 分类标准（中国标准）
- 偏瘦：BMI < 18.5
- 正常：18.5 ≤ BMI < 24
- 超重：24 ≤ BMI < 28
- 肥胖：BMI ≥ 28

## 界面设计

### 布局结构

**顶部区域（结果卡片）**
- 显示当前 BMI 数值（大字体，保留 1 位小数）
- 健康等级标签（偏瘦/正常/超重/肥胖），使用不同颜色
- 健康建议简述（1-2 句话）
- 理想体重范围提示

**中部区域（输入区域）**
- 身高输入：显示当前值（cm）+ 滑动条（范围 100-250cm）
- 体重输入：显示当前值（kg）+ 滑动条（范围 30-200kg）
- 支持点击数值直接编辑

**底部区域（辅助信息）**
- 快速预设按钮（如：160cm/50kg）
- 单位说明（BMI = 体重kg / 身高m²）

### 颜色方案
- 偏瘦（<18.5）：蓝色 `Colors.blue`
- 正常（18.5-24）：绿色 `Colors.green`
- 超重（24-28）：橙色 `Colors.orange`
- 肥胖（≥28）：红色 `Colors.red`

### 交互设计
- 拖动滑动条：实时计算并更新结果
- 点击数值：弹出键盘允许精确输入
- 快速预设：一键设置常见身高体重组合
- 异常处理：身高体重为 0 时显示提示，不计算

## 数据模型

```dart
class BMIResult {
  final double bmi;           // BMI 数值
  final double height;        // 身高
  final double weight;        // 体重
  final BMIStatus status;     // 健康状态
  final String advice;        // 健康建议
  final double minWeight;     // 理想体重下限
  final double maxWeight;     // 理想体重 上限
}

enum BMIStatus {
  underweight,   // < 18.5
  normal,        // 18.5 - 24
  overweight,    // 24 - 28
  obese          // >= 28
}
```

## 核心算法

```dart
BMIResult calculateBMI(double heightCm, double weightKg) {
  final heightM = heightCm / 100;
  final bmi = weightKg / (heightM * heightM);

  BMIStatus status;
  String advice;
  double minWeight, maxWeight;

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
  minWeight = 18.5 * heightM * heightM;
  maxWeight = 24 * heightM * heightM;

  return BMIResult(bmi: bmi, height: heightCm, weight: weightKg,
                   status: status, advice: advice,
                   minWeight: minWeight, maxWeight: maxWeight);
}
```

## 技术实现

### 文件结构
```
app/lib/tools/bmi/
├── bmi_tool.dart          # 工具注册
├── bmi_page.dart          # 主页面
├── models/
│   └── bmi_result.dart    # 数据模型
├── services/
│   └── bmi_service.dart   # 计算逻辑
└── widgets/
    ├── result_card.dart    # 结果卡片
    ├── height_input.dart   # 身高输入
    └── weight_input.dart   # 体重输入
```

### 工具注册
在 `main.dart` 中注册：
```dart
import 'tools/bmi/bmi_tool.dart';
// ...
ToolRegistry.register(BMITool());
```

### 持久化存储
使用 SharedPreferences 保存：
- `bmi_last_height`：上次身高（double）
- `bmi_last_weight`：上次体重（double）

下次打开时自动加载上次值。

## 测试

### 单元测试
- BMI 计算算法准确性测试
- 边界值测试（BMI 18.5、24、28）
- 理想体重范围计算测试

### 集成测试
- 滑动条交互测试
- 精确输入测试
- 持久化保存和恢复测试
- UI 响应测试

### 测试用例
- 边界值测试（身高 100cm、250cm，体重 30kg、200kg）
- 正常值测试（身高 175cm，体重 70kg）
- BMI 分界点测试（17.9、18.5、23.9、24、27.9、28）
- 持久化测试（保存和恢复上次值）

## 版本信息
- 创建日期：2026-04-04
- 工具版本：1.0.0
- 分支：feature-bmi-calculator
