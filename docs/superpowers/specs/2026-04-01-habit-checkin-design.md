# 习惯打卡功能设计文档

## 概述

实现 APP 端的习惯打卡功能，用户可以创建自定义打卡目标或选择内置模板，每日完成打卡。数据存储在云端，需要登录才能使用，支持统计和目标删除。

## 功能需求

| 功能 | 说明 |
|-----|------|
| 创建目标 | 用户自定义或选择内置模板 |
| 每日打卡 | 每天可打卡一次，可取消 |
| 目标列表 | 展示所有目标、图标、名称、完成天数 |
| 统计功能 | 总打卡天数、连续打卡天数、历史记录 |
| 删除目标 | 支持删除已创建的目标 |
| 登录验证 | 需要登录才能使用 |

## 非功能需求

- **数据存储**：云端存储，支持多设备同步
- **认证**：需要登录才能使用
- **模块集成**：整合到 eladmin-app 模块

## 数据模型

### 习惯目标表 (habit)

```sql
CREATE TABLE habit (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    name VARCHAR(64) NOT NULL COMMENT '习惯名称',
    icon VARCHAR(32) NOT NULL DEFAULT 'check_circle' COMMENT '图标名称',
    description VARCHAR(255) COMMENT '描述',
    color VARCHAR(16) DEFAULT '#4CAF50' COMMENT '主题颜色',
    is_active TINYINT(1) DEFAULT 1 COMMENT '是否激活',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user (user_id),
    FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE
) COMMENT='习惯打卡目标';
```

### 打卡记录表 (habit_record)

```sql
CREATE TABLE habit_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    habit_id BIGINT NOT NULL COMMENT '习惯ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    record_date DATE NOT NULL COMMENT '打卡日期',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_habit_date (habit_id, record_date),
    INDEX idx_user_date (user_id, record_date),
    FOREIGN KEY (habit_id) REFERENCES habit(id) ON DELETE CASCADE
) COMMENT='打卡记录';
```

### 内置模板表 (habit_template)

```sql
CREATE TABLE habit_template (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(64) NOT NULL COMMENT '模板名称',
    icon VARCHAR(32) NOT NULL COMMENT '图标名称',
    description VARCHAR(255) COMMENT '描述',
    category VARCHAR(32) COMMENT '分类',
    sort_order INT DEFAULT 0 COMMENT '排序'
) COMMENT='习惯内置模板';
```

**内置模板数据**：
- 晨跑 (directions_run)
- 早睡 (bedtime)
- 早起 (wb_sunny)
- 阅读 (menu_book)
- 喝水 (water_drop)
- 冥想 (spa)
- 运动 (fitness_center)
- 学习 (school)

## 后端 API 设计

### 1. 获取习惯列表

```http
GET /api/app/habits
Authorization: Bearer {token}
```

**响应 (200)**
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "name": "晨跑",
      "icon": "directions_run",
      "description": "每天早晨跑步5公里",
      "color": "#4CAF50",
      "isActive": true,
      "completedDays": 15,
      "todayChecked": true,
      "createdAt": "2026-03-20T00:00:00Z"
    }
  ]
}
```

### 2. 创建习惯

```http
POST /api/app/habits
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "晨跑",
  "icon": "directions_run",
  "description": "每天早晨跑步5公里",
  "color": "#4CAF50"
}
```

**响应 (200)**
```json
{
  "code": 200,
  "message": "创建成功",
  "data": {
    "id": 1,
    "name": "晨跑",
    "icon": "directions_run",
    "description": "每天早晨跑步5公里",
    "color": "#4CAF50",
    "isActive": true,
    "completedDays": 0,
    "todayChecked": false
  }
}
```

### 3. 删除习惯

```http
DELETE /api/app/habits/{id}
Authorization: Bearer {token}
```

**响应 (200)**
```json
{
  "code": 200,
  "message": "删除成功"
}
```

### 4. 打卡/取消打卡

```http
POST /api/app/habits/{id}/check-in
Authorization: Bearer {token}
Content-Type: application/json

{
  "date": "2026-04-01"
}
```

**响应 (200)**
```json
{
  "code": 200,
  "message": "打卡成功",
  "data": {
    "todayChecked": true,
    "completedDays": 16
  }
}
```

**特殊处理**：如果当天已打卡，再次调用则取消打卡

### 5. 获取习惯统计

```http
GET /api/app/habits/{id}/stats?startDate=2026-03-01&endDate=2026-03-31
Authorization: Bearer {token}
```

**响应 (200)**
```json
{
  "code": 200,
  "message": "success",
  "data": {
    "totalDays": 25,
    "currentStreak": 7,
    "longestStreak": 15,
    "records": [
      {
        "date": "2026-03-31",
        "checked": true
      },
      {
        "date": "2026-03-30",
        "checked": true
      }
    ]
  }
}
```

### 6. 获取内置模板

```http
GET /api/app/habit-templates
Authorization: Bearer {token}
```

**响应 (200)**
```json
{
  "code": 200,
  "message": "success",
  "data": [
    {
      "id": 1,
      "name": "晨跑",
      "icon": "directions_run",
      "description": "每天早晨跑步",
      "category": "运动",
      "sortOrder": 1
    }
  ]
}
```

## 后端模块结构

```
backend/eladmin-app/src/main/java/com/littlegrid/modules/app/
├── domain/
│   ├── Habit.java
│   ├── HabitRecord.java
│   └── HabitTemplate.java
├── service/
│   ├── HabitService.java
│   ├── impl/
│   │   └── HabitServiceImpl.java
│   └── dto/
│       ├── HabitDTO.java
│       ├── HabitCreateDTO.java
│       ├── HabitUpdateDTO.java
│       ├── HabitRecordDTO.java
│       └── HabitStatsDTO.java
└── rest/
    └── HabitController.java
```

## 前端设计

### 目录结构

```
app/lib/tools/habit/
├── habit_tool.dart              # 工具注册
├── habit_page.dart              # 主页面
├── habit_create_page.dart       # 创建习惯页面
├── habit_stats_page.dart        # 统计页面
├── widgets/
│   ├── habit_card.dart          # 习惯卡片
│   ├── habit_list.dart          # 习惯列表
│   ├── template_selector.dart   # 模板选择器
│   └── stats_chart.dart         # 统计图表
├── models/
│   ├── habit.dart               # 习惯模型
│   ├── habit_record.dart        # 打卡记录模型
│   └── habit_template.dart      # 模板模型
└── services/
    └── habit_service.dart        # API服务
```

### 核心类设计

**HabitService**
```dart
class HabitService {
  // 获取习惯列表
  Future<List<Habit>> getHabits();

  // 创建习惯
  Future<Habit> createHabit(HabitCreateDTO dto);

  // 删除习惯
  Future<void> deleteHabit(int id);

  // 打卡/取消打卡
  Future<CheckInResult> checkIn(int habitId, DateTime date);

  // 获取统计
  Future<HabitStats> getStats(int habitId, DateTime start, DateTime end);

  // 获取模板
  Future<List<HabitTemplate>> getTemplates();
}
```

**HabitProvider**
```dart
class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  List<HabitTemplate> _templates = [];
  bool _isLoading = false;

  // 加载习惯列表
  Future<void> loadHabits();

  // 创建习惯
  Future<void> createHabit(HabitCreateDTO dto);

  // 删除习惯
  Future<void> deleteHabit(int id);

  // 打卡/取消打卡
  Future<void> toggleCheckIn(int habitId);

  // 获取统计
  Future<HabitStats> getStats(int habitId);
}
```

### 页面交互流程

```
习惯打卡主页
   │
   ├─ 显示习惯卡片列表
   │   每个卡片包含：
   │   - 图标
   │   - 名称
   │   - 已完成天数
   │   - 打钩按钮（灰色/绿色）
   │
   ├─ 点击打钩按钮
   │   ├─ 未打卡 → 调用API打卡 → 变成绿色
   │   └─ 已打卡 → 调用API取消 → 变成灰色
   │
   ├─ 点击卡片（除打钩按钮外）
   │   └→ 跳转到统计页面
   │
   └─ 点击右下角浮动按钮
       └→ 跳转到创建页面

创建习惯页面
   │
   ├─ 显示模板选择区域
   │   - 点击模板快速填充
   │
   ├─ 自定义输入区域
   │   - 名称输入框
   │   - 图标选择器
   │   - 颜色选择器
   │   - 描述输入框（可选）
   │
   └─ 确认按钮
       └→ 调用创建API → 返回主页

统计页面
   │
   ├─ 显示统计信息
   │   - 总打卡天数
   │   - 当前连续天数
   │   - 最长连续天数
   │
   ├─ 显示日历视图
   │   - 已打卡日期标记
   │
   └─ 删除按钮（右上角）
       └→ 确认对话框 → 调用删除API → 返回主页
```

### 错误处理

| 场景 | 处理方式 |
|-----|---------|
| 未登录 | 跳转到登录页 |
| 网络错误 | 显示错误提示，支持重试 |
| 习惯不存在 | 刷新列表，移除无效数据 |
| 重复打卡 | 服务器自动处理（toggle逻辑） |
| 删除失败 | 显示错误提示 |

### 数据刷新策略

- 进入页面时刷新习惯列表
- 打卡成功后局部刷新（乐观更新 + 服务器确认）
- 切换回页面时自动刷新
- 统计页面按需加载

## 数据库迁移

在 `backend/eladmin-app/src/main/resources/db/migration/` 目录下创建迁移文件：

```
V3__create_habit_tables.sql
```

包含：
1. habit 表创建
2. habit_record 表创建
3. habit_template 表创建
4. 内置模板数据插入

## 安全考虑

1. **权限控制**：所有接口需登录验证，使用 `SecurityUtils.getCurrentUserId()` 获取用户
2. **数据隔离**：查询时必须带上 `user_id` 条件，防止越权访问
3. **删除权限**：只能删除自己的习惯
4. **打卡限制**：同一天同一习惯只能有一条记录

## 内置模板初始数据

```sql
INSERT INTO habit_template (name, icon, description, category, sort_order) VALUES
('晨跑', 'directions_run', '每天早晨跑步', '运动', 1),
('早睡', 'bedtime', '每晚10点前睡觉', '健康', 2),
('早起', 'wb_sunny', '每天7点前起床', '健康', 3),
('阅读', 'menu_book', '每天阅读30分钟', '学习', 4),
('喝水', 'water_drop', '每天喝8杯水', '健康', 5),
('冥想', 'spa', '每天冥想10分钟', '健康', 6),
('运动', 'fitness_center', '每天运动1小时', '运动', 7),
('学习', 'school', '每天学习新知识', '学习', 8);
```

## 后续扩展（暂不做）

- 习惯分享功能
- 习惯挑战（多人PK）
- 提醒通知
- 习惯分类管理
- 数据导出
