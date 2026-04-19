---
name: In-App Banner Notification Design
description: Design spec for in-app banner notifications and system notification integration
type: spec
---

# APP内横幅通知与系统通知集成设计

## 概述

为"小方格"APP添加APP内横幅通知功能，并为番茄钟、纪念日、奶茶计划接入系统通知。

## 目标

1. 提供优雅的APP内横幅通知体验
2. 为合适的工具接入系统级通知
3. 统一通知管理架构

## 接入通知的工具

### 已接入
- **闹钟** - 已有系统通知，保持现状

### 新增接入
| 工具 | 通知类型 | 触发场景 | 是否跳转 |
|------|----------|----------|----------|
| 番茄钟 | 系统通知 + APP内横幅 | 专注结束、休息结束 | 是，跳转到番茄钟 |
| 纪念日 | 系统通知 + APP内横幅 | 纪念日当天、提前1天提醒 | 是，跳转到纪念日 |
| 奶茶计划 | 系统通知 + APP内横幅 | 定时喝水提醒 | 否，仅提示 |

## APP内横幅设计

### 视觉样式

采用**方案A - 简洁卡片**风格：

```
┌─────────────────────────────────┐
│  [状态栏]                        │
├─────────────────────────────────┤
│ ┌───┐  番茄钟结束         [×]  │
│ │ ⏰ │  休息一下吧，喝杯水~      │
│ └───┘                            │
└─────────────────────────────────┘
```

**设计规范：**
- 容器：白色背景，圆角12px，阴影 `0 4px 12px rgba(0,0,0,0.15)`
- 内边距：16px
- 图标：48x48px，圆角12px，彩色背景（根据工具类型）
- 标题：15px，字重600
- 副标题：13px，颜色#666
- 关闭按钮：32x32px，点击区域

### 交互行为

1. **显示动画**
   - 从状态栏下方滑入
   - 动画时长：300ms，曲线：easeOutCubic

2. **关闭方式**
   - 点击右侧关闭按钮 → 立即关闭
   - 左右滑动 → 跟随手势，松手后滑出关闭
   - 滑动距离阈值：50px

3. **点击内容区域**
   - 根据通知类型决定：
     - **可跳转类型**：跳转到对应工具页面
     - **仅提示类型**：无操作（或可配置关闭）

4. **多条通知处理**
   - 采用**队列显示**方式
   - 一次只显示一条通知
   - 当前通知关闭后，下一条自动滑入
   - 队列最大长度：10条（超出则丢弃最早的）

### 横幅位置

- 显示在**状态栏下方**，不覆盖状态栏
- 距离左右屏幕边缘：8px
- 距离顶部（状态栏下方）：8px

## 架构设计

### 新增文件结构

```
lib/core/
├── services/
│   ├── notification_service.dart      (增强，已存在)
│   ├── in_app_banner_service.dart     (新增)
│   └── banner_queue.dart               (新增)
└── widgets/
    └── in_app_banner.dart              (新增)
```

### 核心组件

#### 1. `InAppBanner` (Widget)

横幅UI组件，负责：
- 渲染横幅内容
- 处理点击关闭
- 处理滑动手势
- 进入/退出动画

**Props:**
```dart
final String title;
final String body;
final IconData icon;
final Color iconBackgroundColor;
final VoidCallback? onTap;
final VoidCallback onClose;
```

#### 2. `BannerQueue` (Service)

通知队列管理，负责：
- 维护待显示横幅队列
- 控制当前显示状态
- 提供入队/出队接口

**API:**
```dart
class BannerQueue {
  void enqueue(BannerData data);
  void dismissCurrent();
  Stream<BannerData?> get currentBanner;
}
```

#### 3. `InAppBannerService` (Service)

APP内横幅服务，负责：
- 管理横幅Overlay
- 协调队列显示
- 提供全局展示接口

**API:**
```dart
class InAppBannerService {
  static Future<void> initialize();
  static void show({
    required String title,
    required String body,
    required IconData icon,
    Color? iconBackgroundColor,
    VoidCallback? onTap,
    String? toolId,
  });
  static void dismiss();
}
```

#### 4. `NotificationService` (增强)

系统通知服务，已有基础上增强：

**新增功能：**
- 新增通知渠道
- 支持更多通知类型
- 提供工具专用的便捷方法

**新增渠道:**
| 渠道ID | 名称 | 说明 | 重要性 |
|--------|------|------|--------|
| alarm_channel | 闹钟 | 已有 | high |
| timer_channel | 倒计时 | 已有 | high |
| pomodoro_channel | 番茄钟 | 新增 | high |
| anniversary_channel | 纪念日 | 新增 | default |
| drink_plan_channel | 喝水提醒 | 新增 | default |

**便捷API:**
```dart
// 番茄钟通知
static Future<void> showPomodoroNotification({
  required int id,
  required bool isWorkFinished,
  required DateTime scheduledDate,
});

// 纪念日通知
static Future<void> showAnniversaryNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDate,
});

// 喝水提醒
static Future<void> showDrinkPlanNotification({
  required int id,
  required DateTime scheduledDate,
});
```

### 集成到应用

#### 在 `main.dart` 中初始化

```dart
void main() async {
  // ... 现有代码 ...

  // 初始化通知服务
  await NotificationService().initialize();
  await InAppBannerService.initialize();

  runApp(const MyApp());
}
```

#### 在 `MyApp` 中添加横幅Overlay

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ... 现有 providers ...
        ChangeNotifierProvider(create: (_) => InAppBannerService()),
      ],
      child: Builder(
        builder: (context) => MaterialApp(
          // ... 现有配置 ...
          builder: (context, child) {
            return Stack(
              children: [
                child!,
                const InAppBannerOverlay(),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

## 各工具接入详情

### 1. 番茄钟

**文件：** `lib/tools/pomodoro/`

**改动：**
- 在 `PomodoroService` 中，当计时结束时：
  1. 调用 `NotificationService.showPomodoroNotification()` 安排系统通知
  2. 如果APP在前台，同时调用 `InAppBannerService.show()` 显示横幅

**横幅内容：**
- 专注结束：`title="番茄钟结束"`, `body="休息一下吧，喝杯水~"`, `icon=Icons.timer`
- 休息结束：`title="休息结束"`, `body="开始新的专注吧！"`, `icon=Icons.play_circle`

**跳转：** 点击横幅跳转到番茄钟页面

### 2. 纪念日

**文件：** `lib/tools/anniversary/`

**改动：**
- 创建/编辑纪念日时，安排通知（提前1天 + 当天）
- 使用 `NotificationService.showAnniversaryNotification()`
- APP前台时同时显示横幅

**横幅内容：**
- `title="${anniversary.title}"`, `body="还有${days}天就是纪念日了！"`, `icon=Icons.favorite`

**跳转：** 点击横幅跳转到纪念日页面

### 3. 奶茶计划

**文件：** `lib/tools/drink_plan/`

**改动：**
- 开启喝水提醒时，安排定时通知
- 使用 `NotificationService.showDrinkPlanNotification()`
- APP前台时同时显示横幅

**横幅内容：**
- `title="喝水时间到"`, `body="记得补充水分哦~"`, `icon=Icons.local_drink`

**跳转：** 不跳转，仅提示

## 通知ID分配

避免ID冲突，采用以下分配规则：

| 工具 | ID范围 | 示例 |
|------|--------|------|
| 闹钟 | 1-999 | 1, 2, 3... |
| 番茄钟 | 1000-1999 | 1000（专注结束）、1001（休息结束） |
| 纪念日 | 2000-2999 | 2000 + anniversary.id |
| 奶茶计划 | 3000-3999 | 3000, 3001... |

## 错误处理

1. **通知权限未授予**
   - 首次使用时请求权限
   - 若用户拒绝，系统通知不可用，但APP内横幅仍可用

2. **通知调度失败**
   - 记录错误日志
   - 提供降级体验（仅APP内横幅）

3. **队列溢出**
   - 队列最大10条
   - 超出时丢弃最早的通知

## 测试用例

### 功能测试
- [ ] 横幅正常显示、关闭
- [ ] 点击关闭按钮正常工作
- [ ] 滑动关闭正常工作
- [ ] 点击内容区域跳转正常
- [ ] 多条通知队列显示正常
- [ ] 系统通知正常发出
- [ ] APP在前台/后台时行为正确

### 兼容性测试
- [ ] iOS 14+
- [ ] Android 8.0+ (SDK 26+)
- [ ] 不同屏幕尺寸适配

## 后续优化（可选）

1. 横幅样式可配置（不同工具不同颜色）
2. 通知历史记录
3. 用户可自定义通知偏好
4. 横幅支持操作按钮（如"再提醒我"、"忽略"）
