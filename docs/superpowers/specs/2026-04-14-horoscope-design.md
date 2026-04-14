# 星座运势工具设计文档

**日期**: 2026-04-14
**状态**: 草稿
**作者**: Claude + nano

---

## 1. 概述

### 1.1 目标
开发一个星座运势功能格子，支持设置默认星座，展示今日和本周运势，包含综合指数及爱情、事业、财运、健康分项指数。

### 1.2 约束
- 使用第三方免费 API，本地算法兜底
- 遵循现有工具架构模式
- 首页格子大小：1x1（小格子）
- 分类：ToolCategory.life（生活实用）

---

## 2. 架构设计

### 2.1 文件结构
```
app/lib/tools/horoscope/
├── horoscope_tool.dart      # 工具注册入口，实现 ToolModule 接口
├── horoscope_page.dart      # 星座运势主页面
├── horoscope_service.dart   # API 服务、本地生成算法、数据模型
├── models/
│   ├── zodiac_sign.dart     # 星座数据模型
│   └── horoscope_data.dart  # 运势数据模型
└── widgets/
    ├── zodiac_selector.dart # 星座选择器（底部弹窗）
    ├── fortune_card.dart    # 综合运势卡片
    └── fortune_item.dart    # 分项运势项组件
```

### 2.2 数据流
```
用户打开星座运势工具
    ↓
读取本地保存的默认星座
    ↓
├─ 无默认星座 → 显示"请选择星座"提示
└─ 有默认星座 → 加载该星座今日运势
    ↓
优先请求 API → 失败时切换本地生成
    ↓
显示运势数据
```

### 2.3 工具注册信息
| 属性 | 值 |
|------|-----|
| id | `horoscope` |
| name | `星座运势` |
| icon | `Icons.star` |
| category | `ToolCategory.life` |
| gridSize | `1` |

---

## 3. 功能规格

### 3.1 12星座数据

| 星座 | 日期范围 | 图标 |
|------|----------|------|
| 白羊座 | 3.21-4.19 | Icons.emoji_events |
| 金牛座 | 4.20-5.20 | Icons.eco |
| 双子座 | 5.21-6.21 | Icons.people |
| 巨蟹座 | 6.22-7.22 | Icons.nightlight |
| 狮子座 | 7.23-8.23 | Icons.wb_sunny |
| 处女座 | 8.24-9.23 | Icons.check_circle |
| 天秤座 | 9.24-10.23 | Icons.balance |
| 天蝎座 | 10.24-11.22 | Icons.visibility |
| 射手座 | 11.23-12.21 | Icons.rocket_launch |
| 摩羯座 | 12.22-1.19 | Icons.terrain |
| 水瓶座 | 1.20-2.18 | Icons.water |
| 双鱼座 | 2.19-3.20 | Icons.waves |

### 3.2 页面布局

**AppBar**
- 标题：星座运势
- 右侧：刷新按钮

**星座选择栏**
- 可点击卡片
- 左侧：星座图标
- 中间：星座名称 + 日期范围
- 右侧：箭头图标
- 点击打开星座选择器底部弹窗

**日期切换 Tab**
- 两个选项："今日" | "本周"
- 下划线指示当前选中
- 点击切换运势类型

**综合运势卡片**
- 渐变背景（根据指数颜色：红=低，黄=中，绿=高）
- 左侧：圆形进度条显示综合指数（0-100）
- 右侧：
  - 上方：指数数值 + "分"
  - 下方：综合运势描述文字

**分项运势列表**
- 4 个卡片：爱情、事业、财运、健康
- 每项结构：
  - 左侧：图标
  - 中间：
    - 标题（如"爱情运势"）
    - 线性进度条
  - 右侧：
    - 指数数值
    - 简短描述（1行）

### 3.3 星座选择器
- 底部弹窗形式
- 网格布局（3列 x 4行）
- 每个星座：图标 + 名称
- 点击选择后自动关闭弹窗并保存为默认星座

---

## 4. 数据模型

### 4.1 ZodiacSign（星座）
```dart
class ZodiacSign {
  final String id;          // 'aries', 'taurus', ...
  final String name;        // '白羊座', '金牛座', ...
  final String dateRange;   // '3.21-4.19'
  final IconData icon;
}
```

### 4.2 HoroscopeData（运势）
```dart
class HoroscopeData {
  final String type;            // 'today', 'week'
  final int overallScore;       // 综合指数 0-100
  final String overallDesc;     // 综合描述

  final int loveScore;          // 爱情指数
  final String loveDesc;        // 爱情描述

  final int careerScore;        // 事业指数
  final String careerDesc;      // 事业描述

  final int wealthScore;        // 财运指数
  final String wealthDesc;      // 财运描述

  final int healthScore;        // 健康指数
  final String healthDesc;      // 健康描述
}
```

---

## 5. API 策略

### 5.1 混合模式
**优先 API**：尝试使用第三方免费 API 获取真实运势数据
**本地兜底**：API 失败时，使用本地算法生成运势

### 5.2 本地生成算法
- 使用星座 ID + 日期作为种子
- 伪随机生成各指数（今日范围：40-95，本周范围：35-90）
- 预设描述模板库，根据指数区间随机选择

### 5.3 缓存策略
- 缓存键：`horoscope_${zodiacId}_${type}`
- 缓存时长：今日运势 4 小时，本周运势 12 小时
- 下拉刷新强制更新

---

## 6. 依赖

```yaml
dependencies:
  http: ^1.1.0  # 网络请求（如未添加）
  # 已有依赖：flutter_animate
```

---

## 7. 错误处理

| 场景 | 处理方式 |
|------|----------|
| 网络请求失败 | 自动切换到本地生成模式，静默提示用户 |
| 未选择默认星座 | 显示占位卡片，点击打开选择器 |
| API 返回数据异常 | 降级到本地生成 |

---

## 8. 验收标准

- [ ] 首页星座运势格子大小 1x1，与其他工具一致
- [ ] 点击进入星座运势详情页
- [ ] 支持选择并保存默认星座
- [ ] 支持切换查看其他星座
- [ ] 显示今日运势（综合+4分项）
- [ ] 显示本周运势（综合+4分项）
- [ ] Tab 切换今日/本周
- [ ] API + 本地混合模式正常工作
- [ ] 下拉刷新强制更新
- [ ] 记住用户选择的默认星座

---

## 9. 后续优化（可选）

- 支持明日/本月/年度运势
- 幸运色/幸运数字显示
- 星座配对功能
- 运势分享截图
- 每日运势通知提醒
