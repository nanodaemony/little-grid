# 全屏时钟功能设计文档

**日期**: 2026-03-26
**功能**: 全屏时钟 (Full Screen Clock)
**状态**: 设计完成，待实现

---

## 1. 功能概述

在"小方格"APP中新增一个"全屏时钟"工具格子。点击格子后直接进入全屏时钟显示界面，适用于活动、比赛、演讲、课堂、辩论等场景。支持多种时钟样式、主题颜色、时间格式等配置。

---

## 2. 用户场景

- **活动倒计时**: 活动现场大屏显示时间
- **比赛计时**: 体育比赛、演讲比赛等场景
- **课堂使用**: 教师控制课堂时间
- **个人专注**: 全屏显示时间，减少干扰

---

## 3. 交互流程

```
用户点击"全屏时钟"格子
    ↓
直接进入全屏时钟页面
    ↓
右上角显示设置图标（⚙️/齿轮）
    ↓
5秒后图标自动淡出隐藏
    ↓
点击屏幕任意位置 → 图标重新显示（重置5秒计时器）
    ↓
点击图标 → 呼出设置面板
    ↓
在设置面板中配置样式
    ↓
关闭设置面板 → 返回全屏时钟，图标5秒后自动隐藏
```

---

## 4. 页面结构

### 4.1 全屏时钟页面 (ClockPage)

- **全屏显示**: 无 AppBar，使用 `SystemUiMode.immersiveSticky`
- **时钟显示区域**: 屏幕中央大字显示时间
- **设置图标**: 右上角固定位置，5秒后自动隐藏
- **日期显示**: 时间下方（可选）
- **背景**: 根据设置显示（纯色/渐变/图片）

### 4.2 设置面板 (SettingsPanel)

从底部滑入的抽屉式面板，包含：

- **样式预览区**: 底部横向滑动选择器
  - 数字时钟预览
  - 圆盘时钟预览
  - 左右滑动切换

- **配置选项列表**:
  - 时钟类型（数字/圆盘）
  - 主题颜色（深色/浅色/自定义）
  - 时间格式（12小时/24小时/自动检测）
  - 显示日期（开关）
  - 显示秒数（开关）
  - 字体大小（小/中/大）
  - 背景设置（预设颜色/颜色选择器/渐变/图片）

---

## 5. 组件设计

### 5.1 数字时钟组件 (DigitalClock)

```dart
class DigitalClock extends StatelessWidget {
  final DateTime time;
  final bool showSeconds;
  final bool use24HourFormat;
  final bool showDate;
  final FontSize fontSize;
  final Color textColor;

  // 大字体显示时:分:秒
  // 可选显示 AM/PM
  // 日期显示在下方（如果开启）
}
```

**样式特点**:
- 大号数字，清晰可读
- 等宽字体，数字对齐
- 支持 AM/PM 显示

### 5.2 圆盘时钟组件 (AnalogClock)

```dart
class AnalogClock extends StatelessWidget {
  final DateTime time;
  final bool showSeconds;
  final bool showDate;
  final Color dialColor;
  final Color handColor;
  final Color secondHandColor;

  // 传统表盘设计
  // 时针、分针、秒针
  // 可选显示刻度
  // 日期显示在表盘下方
}
```

**样式特点**:
- 经典表盘设计
- 秒针平滑移动或跳动
- 可选罗马数字或阿拉伯数字刻度

### 5.3 设置面板组件 (SettingsPanel)

```dart
class SettingsPanel extends StatefulWidget {
  final ClockConfig currentConfig;
  final Function(ClockConfig) onConfigChanged;

  // 可拖拽手势关闭
  // 配置项分组显示
  // 实时预览效果
}
```

---

## 6. 数据模型

### 6.1 配置模型

```dart
enum ClockType { digital, analog }

enum ThemeMode { light, dark, custom }

enum FontSize { small, medium, large }

enum BackgroundType { color, gradient, image }

enum TimeFormat { auto, format12, format24 }

enum GradientDirection { topToBottom, leftToRight, topLeftToBottomRight, topRightToBottomLeft }

class ClockConfig {
  final ClockType type;
  final ThemeMode theme;
  final TimeFormat timeFormat;
  final bool showDate;
  final bool showSeconds;
  final FontSize fontSize;
  final BackgroundType backgroundType;
  final Color backgroundColor;
  final GradientDirection? gradientDirection;
  final List<Color>? gradientColors;
  final String? backgroundImagePath;

  ClockConfig copyWith({...});
  Map<String, dynamic> toJson();
  factory ClockConfig.fromJson(Map<String, dynamic> json);
  factory ClockConfig.defaultConfig();

  // 将渐变配置转换为 LinearGradient
  LinearGradient? toLinearGradient();
}
```

### 6.2 默认配置

```dart
ClockConfig.defaultConfig() => ClockConfig(
  type: ClockType.digital,
  theme: ThemeMode.dark,
  timeFormat: TimeFormat.auto,
  showDate: true,
  showSeconds: true,
  fontSize: FontSize.large,
  backgroundType: BackgroundType.color,
  backgroundColor: Colors.black,
  gradientDirection: null,
  gradientColors: null,
  backgroundImagePath: null,
);
```

---

## 7. 状态管理

### 7.1 ClockService

```dart
class ClockService extends ChangeNotifier {
  ClockConfig _config;
  Timer? _clockTimer;
  DateTime _currentTime;

  ClockConfig get config => _config;
  DateTime get currentTime => _currentTime;

  // 加载保存的配置
  Future<void> loadConfig() async;

  // 保存配置
  Future<void> saveConfig(ClockConfig config) async;

  // 更新配置
  void updateConfig(ClockConfig config);

  // 启动时钟更新
  void startClock();

  // 停止时钟更新
  void stopClock();
}
```

### 7.2 配置持久化

使用 `StorageService` 保存配置到本地 SQLite：

```dart
// 保存配置
await StorageService.saveToolData('clock', config.toJson());

// 加载配置
final json = await StorageService.getToolData('clock');
if (json != null) {
  config = ClockConfig.fromJson(json);
}
```

---

## 8. 技术实现要点

### 8.1 全屏模式

```dart
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
```

### 8.2 设置图标自动隐藏

```dart
class _ClockPageState extends State<ClockPage> {
  bool _showSettingsIcon = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(Duration(seconds: 5), () {
      setState(() => _showSettingsIcon = false);
    });
  }

  void _onScreenTap() {
    setState(() => _showSettingsIcon = true);
    _startHideTimer();
  }
}
```

### 8.3 屏幕常亮

使用 `wakelock_plus` 保持屏幕常亮：

```dart
import 'package:wakelock_plus/wakelock_plus.dart';

// 进入页面时启用
@override
void initState() {
  super.initState();
  WakelockPlus.enable();
}

// 离开页面时禁用
@override
void dispose() {
  WakelockPlus.disable();
  super.dispose();
}
```

### 8.4 屏幕方向

支持横竖屏切换，默认跟随系统：

```dart
// 允许所有方向
SystemChrome.setPreferredOrientations([
  DeviceOrientation.portraitUp,
  DeviceOrientation.portraitDown,
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
]);
```

### 8.5 时间更新

```dart
Timer.periodic(Duration(seconds: 1), (timer) {
  setState(() => _currentTime = DateTime.now());
});
```

### 8.6 地区时间格式自动检测

```dart
import 'package:intl/intl.dart';

bool shouldUse24HourFormat() {
  final locale = Intl.getCurrentLocale();
  // 使用24小时制的地区：中国、欧洲大部分国家等
  final use24HourLocales = ['zh', 'de', 'fr', 'it', 'es', 'ru', 'ja', 'ko'];
  final langCode = locale.split('_').first;
  return use24HourLocales.contains(langCode);
}
```

### 8.7 依赖包

- `wakelock_plus`: 屏幕常亮
- `flutter_colorpicker`: 颜色选择器（需添加到 pubspec.yaml）
- `image_picker`: 图片背景选择（已存在）
- `intl`: 国际化和地区检测（已存在）

---

## 9. 文件结构

```
app/lib/tools/clock/
├── clock_tool.dart              # ToolModule 实现
├── clock_page.dart              # 主页面
├── models/
│   └── clock_config.dart        # 配置模型
├── services/
│   └── clock_service.dart       # 状态管理
├── widgets/
│   ├── digital_clock.dart       # 数字时钟组件
│   ├── analog_clock.dart        # 圆盘时钟组件
│   ├── settings_panel.dart      # 设置面板
│   ├── style_selector.dart      # 样式选择器
│   └── background_picker.dart   # 背景选择器
└── utils/
    └── time_formatter.dart      # 时间格式化工具
```

---

## 10. 工具注册

在 `main.dart` 中注册：

```dart
import 'tools/clock/clock_tool.dart';

void main() {
  ToolRegistry.register(ClockTool());
  // ...
}
```

---

## 11. 验收标准

- [ ] 点击格子直接进入全屏时钟页面
- [ ] 右上角设置图标5秒后自动隐藏
- [ ] 点击屏幕任意位置重新显示设置图标
- [ ] 支持数字时钟和圆盘时钟两种样式
- [ ] 支持12/24小时格式切换，支持自动检测地区
- [ ] 支持显示/隐藏日期
- [ ] 支持显示/隐藏秒数
- [ ] 支持字体大小调节（小/中/大）
- [ ] 支持深色/浅色主题切换
- [ ] 支持自定义背景（纯色/渐变/图片）
- [ ] 配置自动保存，下次打开使用上次设置
- [ ] 全屏模式下时钟每秒更新
- [ ] 时钟页面保持屏幕常亮
- [ ] 支持横竖屏切换
- [ ] 渐变背景可序列化/反序列化

---

## 12. 未来扩展（可选）

- 倒计时模式
- 正计时/秒表模式
- 番茄钟集成
- 闹钟提醒
- 多时区显示
- 天气信息显示

---

**设计完成，等待实现**
