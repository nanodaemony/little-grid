# 天气工具设计文档

**日期**: 2026-03-23
**状态**: 已批准
**作者**: Claude + nano

---

## 1. 概述

### 1.1 目标
开发一个天气功能格子，支持 GPS 定位和手动城市搜索，展示当前天气及未来3天预报。

### 1.2 约束
- 使用 Open-Meteo 免费 API（无需 API Key）
- 遵循现有工具架构模式
- 首页格子大小与其他工具一致（1x1）

---

## 2. 架构设计

### 2.1 文件结构
```
app/lib/tools/weather/
├── weather_tool.dart      # 工具注册入口，实现 ToolModule 接口
├── weather_page.dart      # 天气主页面，全屏展示
└── weather_service.dart   # API 服务、数据模型、缓存逻辑
```

### 2.2 数据流
```
用户打开天气工具
    ↓
读取本地缓存（30分钟内有效）
    ↓
├─ 有缓存 → 显示缓存数据 → 后台静默刷新
└─ 无缓存 → 显示加载状态 → 请求 API → 保存缓存 → 显示数据
```

### 2.3 工具注册信息
| 属性 | 值 |
|------|-----|
| id | `weather` |
| name | `天气` |
| icon | `Icons.wb_sunny` |
| category | `ToolCategory.life` |
| gridSize | `1` |

---

## 3. 功能规格

### 3.1 城市定位

**GPS 定位（首次进入）**
- 请求位置权限
- 成功：根据坐标反向查询城市名
- 失败：提示用户手动选择城市

**城市搜索**
- 底部弹窗形式
- 输入城市名，实时搜索
- 显示城市列表（名称 + 省份/国家）
- 选择后记住该城市

### 3.2 页面布局

**顶部栏**
- 标题：天气
- 右侧：刷新按钮

**城市选择区**
- 可点击的城市名称卡片
- 显示当前定位/选择的城市
- 点击打开城市搜索弹窗

**当前天气卡片**
- 大尺寸显示当前温度
- 天气图标（动态根据天气状况）
- 天气描述文字（晴/多云/雨等）

**详情信息**
- 湿度百分比
- 风速 km/h

**未来3天预报**
- 列表形式展示
- 每行：星期几 | 天气图标 | 最高温/最低温

### 3.3 天气代码映射

Open-Meteo 天气代码转 Flutter 图标：

| 代码 | 描述 | 图标 |
|------|------|------|
| 0 | 晴 | `Icons.wb_sunny` |
| 1-3 | 多云 | `Icons.wb_cloudy` |
| 45, 48 | 雾 | `Icons.cloud` |
| 51-55 | 毛毛雨 | `Icons.grain` |
| 61-67 | 雨 | `Icons.water_drop` |
| 71-77 | 雪 | `Icons.ac_unit` |
| 80-82 | 阵雨 | `Icons.thunderstorm` |
| 95+ | 雷雨 | `Icons.flash_on` |

---

## 4. API 接口

### 4.1 城市搜索
```
GET https://geocoding-api.open-meteo.com/v1/search
Params:
  - name: 城市名
  - count: 10
  - language: zh
  - format: json
```

### 4.2 天气数据
```
GET https://api.open-meteo.com/v1/forecast
Params:
  - latitude: 纬度
  - longitude: 经度
  - current: temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m
  - daily: weather_code,temperature_2m_max,temperature_2m_min
  - timezone: auto
  - forecast_days: 4
```

---

## 5. 缓存策略

### 5.1 缓存键
```dart
'weather_${cityName}'
```

### 5.2 缓存内容
- 当前天气数据
- 未来3天预报
- 缓存时间戳

### 5.3 缓存时长
- **有效期**: 30分钟
- **刷新方式**: 下拉刷新强制更新

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
| 网络请求失败 | 显示"网络异常"，保留缓存数据（如有） |
| GPS 权限拒绝 | 提示手动选择城市 |
| 城市搜索无结果 | 显示"未找到城市" |
| API 限流 | 显示"请稍后重试" |

---

## 8. 验收标准

- [ ] 首页天气格子大小与其他工具一致
- [ ] 点击进入天气详情页
- [ ] 支持 GPS 自动定位
- [ ] 支持手动搜索并选择城市
- [ ] 显示当前温度、天气状况、湿度、风速
- [ ] 显示未来3天预报
- [ ] 30分钟缓存生效
- [ ] 下拉刷新强制更新
- [ ] 记住用户选择的城市

---

## 9. 后续优化（可选）

- 支持多城市切换
- 空气质量指数显示
- 小时级预报
- 天气预警通知
- 背景随天气变化（晴=蓝天，雨=灰蓝等）
