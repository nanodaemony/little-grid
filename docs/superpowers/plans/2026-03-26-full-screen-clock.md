# 全屏时钟功能实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use @superpowers:subagent-driven-development (recommended) or @superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现全屏时钟工具，包含数字时钟和圆盘时钟两种样式，支持丰富的配置选项。

**Architecture:** 使用 Provider + ChangeNotifier 管理时钟状态和配置。点击格子直接进入全屏时钟页面，5秒后自动隐藏设置图标，点击屏幕可重新显示。配置使用 SharedPreferences 持久化。

**Tech Stack:** Flutter, Provider, SharedPreferences, wakelock_plus, flutter_colorpicker

---

## 文件结构

```
app/lib/tools/clock/
├── clock_tool.dart              # ToolModule 实现
├── clock_page.dart              # 主页面（全屏时钟 + 设置面板）
├── models/
│   ├── clock_config.dart        # 配置模型（含序列化）
│   └── clock_enums.dart         # 枚举定义
├── services/
│   └── clock_service.dart       # 状态管理 + 配置持久化
└── widgets/
    ├── digital_clock.dart       # 数字时钟组件
    ├── analog_clock.dart        # 圆盘时钟组件
    ├── settings_panel.dart      # 设置面板
    ├── style_selector.dart      # 样式选择器（横向滑动）
    ├── background_picker.dart   # 背景选择器
    └── settings_icon.dart       # 设置图标（自动隐藏）
```

**修改文件：**
- `app/pubspec.yaml` - 添加 wakelock_plus 和 flutter_colorpicker 依赖
- `app/lib/main.dart` - 注册 ClockTool

---

## Task 1: 添加依赖

**Files:**
- Modify: `app/pubspec.yaml`

- [ ] **Step 1: 添加 wakelock_plus 和 flutter_colorpicker 依赖**

在 `dependencies:` 部分添加：

```yaml
  # 屏幕常亮
  wakelock_plus: ^1.2.4

  # 颜色选择器
  flutter_colorpicker: ^1.0.3
```

- [ ] **Step 2: Commit**

```bash
cd app && git add pubspec.yaml
git commit -m "deps: add wakelock_plus and flutter_colorpicker for clock tool"
```

---

## Task 2: 创建配置模型

**Files:**
- Create: `app/lib/tools/clock/models/clock_enums.dart`
- Create: `app/lib/tools/clock/models/clock_config.dart`

- [ ] **Step 1: 创建枚举文件 clock_enums.dart**

```dart
import 'package:flutter/material.dart';

enum ClockType { digital, analog }

enum ClockThemeMode { light, dark, custom }

enum FontSize { small, medium, large }

enum BackgroundType { color, gradient, image }

enum TimeFormat { auto, format12, format24 }

enum GradientDirection {
  topToBottom,
  leftToRight,
  topLeftToBottomRight,
  topRightToBottomLeft,
}

extension FontSizeExtension on FontSize {
  double get scale {
    switch (this) {
      case FontSize.small:
        return 0.7;
      case FontSize.medium:
        return 1.0;
      case FontSize.large:
        return 1.3;
    }
  }
}

extension GradientDirectionExtension on GradientDirection {
  LinearGradient toGradient(List<Color> colors) {
    final begin = switch (this) {
      GradientDirection.topToBottom => Alignment.topCenter,
      GradientDirection.leftToRight => Alignment.centerLeft,
      GradientDirection.topLeftToBottomRight => Alignment.topLeft,
      GradientDirection.topRightToBottomLeft => Alignment.topRight,
    };
    final end = switch (this) {
      GradientDirection.topToBottom => Alignment.bottomCenter,
      GradientDirection.leftToRight => Alignment.centerRight,
      GradientDirection.topLeftToBottomRight => Alignment.bottomRight,
      GradientDirection.topRightToBottomLeft => Alignment.bottomLeft,
    };
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
    );
  }
}
```

- [ ] **Step 2: 创建配置模型 clock_config.dart**

```dart
import 'package:flutter/material.dart';
import 'clock_enums.dart';

class ClockConfig {
  final ClockType type;
  final ClockThemeMode theme;
  final TimeFormat timeFormat;
  final bool showDate;
  final bool showSeconds;
  final FontSize fontSize;
  final BackgroundType backgroundType;
  final Color backgroundColor;
  final GradientDirection? gradientDirection;
  final List<Color>? gradientColors;
  final String? backgroundImagePath;
  final Color? customTextColor;

  const ClockConfig({
    required this.type,
    required this.theme,
    required this.timeFormat,
    required this.showDate,
    required this.showSeconds,
    required this.fontSize,
    required this.backgroundType,
    required this.backgroundColor,
    this.gradientDirection,
    this.gradientColors,
    this.backgroundImagePath,
    this.customTextColor,
  });

  factory ClockConfig.defaultConfig() => const ClockConfig(
        type: ClockType.digital,
        theme: ClockThemeMode.dark,
        timeFormat: TimeFormat.auto,
        showDate: true,
        showSeconds: true,
        fontSize: FontSize.large,
        backgroundType: BackgroundType.color,
        backgroundColor: Colors.black,
        gradientDirection: null,
        gradientColors: null,
        backgroundImagePath: null,
        customTextColor: null,
      );

  ClockConfig copyWith({
    ClockType? type,
    ClockThemeMode? theme,
    TimeFormat? timeFormat,
    bool? showDate,
    bool? showSeconds,
    FontSize? fontSize,
    BackgroundType? backgroundType,
    Color? backgroundColor,
    GradientDirection? gradientDirection,
    List<Color>? gradientColors,
    String? backgroundImagePath,
    Color? customTextColor,
  }) {
    return ClockConfig(
      type: type ?? this.type,
      theme: theme ?? this.theme,
      timeFormat: timeFormat ?? this.timeFormat,
      showDate: showDate ?? this.showDate,
      showSeconds: showSeconds ?? this.showSeconds,
      fontSize: fontSize ?? this.fontSize,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gradientDirection: gradientDirection ?? this.gradientDirection,
      gradientColors: gradientColors ?? this.gradientColors,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      customTextColor: customTextColor ?? this.customTextColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'theme': theme.name,
      'timeFormat': timeFormat.name,
      'showDate': showDate,
      'showSeconds': showSeconds,
      'fontSize': fontSize.name,
      'backgroundType': backgroundType.name,
      'backgroundColor': backgroundColor.value,
      'gradientDirection': gradientDirection?.name,
      'gradientColors': gradientColors?.map((c) => c.value).toList(),
      'backgroundImagePath': backgroundImagePath,
      'customTextColor': customTextColor?.value,
    };
  }

  factory ClockConfig.fromJson(Map<String, dynamic> json) {
    return ClockConfig(
      type: ClockType.values.byName(json['type'] as String),
      theme: ClockThemeMode.values.byName(json['theme'] as String),
      timeFormat: TimeFormat.values.byName(json['timeFormat'] as String),
      showDate: json['showDate'] as bool,
      showSeconds: json['showSeconds'] as bool,
      fontSize: FontSize.values.byName(json['fontSize'] as String),
      backgroundType: BackgroundType.values.byName(json['backgroundType'] as String),
      backgroundColor: Color(json['backgroundColor'] as int),
      gradientDirection: json['gradientDirection'] != null
          ? GradientDirection.values.byName(json['gradientDirection'] as String)
          : null,
      gradientColors: (json['gradientColors'] as List<dynamic>?)
          ?.map((v) => Color(v as int))
          .toList(),
      backgroundImagePath: json['backgroundImagePath'] as String?,
      customTextColor: json['customTextColor'] != null
          ? Color(json['customTextColor'] as int)
          : null,
    );
  }

  Color get effectiveTextColor {
    if (customTextColor != null) return customTextColor!;
    switch (theme) {
      case ClockThemeMode.light:
        return Colors.black;
      case ClockThemeMode.dark:
        return Colors.white;
      case ClockThemeMode.custom:
        // 根据背景亮度自动判断
        return backgroundColor.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white;
    }
  }

  bool get use24HourFormat {
    switch (timeFormat) {
      case TimeFormat.format24:
        return true;
      case TimeFormat.format12:
        return false;
      case TimeFormat.auto:
        // 根据系统设置判断
        return WidgetsBinding.instance.platformDispatcher.locale.languageCode !=
            'en';
    }
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/tools/clock/models/
git commit -m "feat(clock): add clock config model and enums"
```

---

## Task 3: 创建 ClockService

**Files:**
- Create: `app/lib/tools/clock/services/clock_service.dart`

- [ ] **Step 1: 创建 ClockService**

```dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/clock_config.dart';

class ClockService extends ChangeNotifier {
  ClockConfig _config = ClockConfig.defaultConfig();
  DateTime _currentTime = DateTime.now();
  Timer? _timer;

  ClockConfig get config => _config;
  DateTime get currentTime => _currentTime;

  ClockService() {
    _loadConfig();
    startClock();
  }

  Future<void> _loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('clock_config');
      if (configJson != null) {
        _config = ClockConfig.fromJson(
          Map<String, dynamic>.from(
            const JsonDecoder().convert(configJson),
          ),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load clock config: $e');
    }
  }

  Future<void> saveConfig(ClockConfig newConfig) async {
    _config = newConfig;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'clock_config',
        const JsonEncoder().convert(_config.toJson()),
      );
    } catch (e) {
      debugPrint('Failed to save clock config: $e');
    }
    notifyListeners();
  }

  void startClock() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _currentTime = DateTime.now();
      notifyListeners();
    });
  }

  void stopClock() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    stopClock();
    super.dispose();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/clock/services/
git commit -m "feat(clock): add ClockService for state management"
```

---

## Task 4: 创建数字时钟组件

**Files:**
- Create: `app/lib/tools/clock/widgets/digital_clock.dart`

- [ ] **Step 1: 创建 DigitalClock 组件**

```dart
import 'package:flutter/material.dart';
import '../models/clock_config.dart';
import '../models/clock_enums.dart';

class DigitalClock extends StatelessWidget {
  final DateTime time;
  final ClockConfig config;

  const DigitalClock({
    super.key,
    required this.time,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = config.effectiveTextColor;
    final baseFontSize = 120.0 * config.fontSize.scale;

    String timeText;
    if (config.use24HourFormat) {
      timeText =
          '${_twoDigits(time.hour)}:${_twoDigits(time.minute)}${_showSeconds()}';
    } else {
      final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
      final period = time.hour >= 12 ? 'PM' : 'AM';
      timeText =
          '${_twoDigits(hour)}:${_twoDigits(time.minute)}${_showSeconds()} $period';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          timeText,
          style: TextStyle(
            fontSize: baseFontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
            fontFamily: 'monospace',
            letterSpacing: 8,
          ),
        ),
        if (config.showDate) ...[
          const SizedBox(height: 16),
          Text(
            '${time.year}年${_twoDigits(time.month)}月${_twoDigits(time.day)}日 星期${_weekdayName(time.weekday)}',
            style: TextStyle(
              fontSize: baseFontSize * 0.25,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      ],
    );
  }

  String _showSeconds() {
    return config.showSeconds ? ':${_twoDigits(time.second)}' : '';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  String _weekdayName(int weekday) {
    const names = ['一', '二', '三', '四', '五', '六', '日'];
    return names[weekday - 1];
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/clock/widgets/digital_clock.dart
git commit -m "feat(clock): add digital clock widget"
```

---

## Task 5: 创建圆盘时钟组件

**Files:**
- Create: `app/lib/tools/clock/widgets/analog_clock.dart`

- [ ] **Step 1: 创建 AnalogClock 组件**

```dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/clock_config.dart';

class AnalogClock extends StatelessWidget {
  final DateTime time;
  final ClockConfig config;

  const AnalogClock({
    super.key,
    required this.time,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.shortestSide * 0.7;
    final textColor = config.effectiveTextColor;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _ClockPainter(
              time: time,
              config: config,
            ),
          ),
        ),
        if (config.showDate) ...[
          const SizedBox(height: 24),
          Text(
            '${time.year}/${_twoDigits(time.month)}/${_twoDigits(time.day)}',
            style: TextStyle(
              fontSize: 24 * config.fontSize.scale,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      ],
    );
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}

class _ClockPainter extends CustomPainter {
  final DateTime time;
  final ClockConfig config;

  _ClockPainter({
    required this.time,
    required this.config,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final textColor = config.effectiveTextColor;

    // 绘制表盘背景
    final bgPaint = Paint()
      ..color = textColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // 绘制表盘边框
    final borderPaint = Paint()
      ..color = textColor.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, borderPaint);

    // 绘制刻度
    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * math.pi / 180;
      final isMainTick = i % 3 == 0;
      final tickStart = radius * (isMainTick ? 0.85 : 0.9);
      final tickEnd = radius * 0.95;

      final start = Offset(
        center.dx + tickStart * math.sin(angle),
        center.dy - tickStart * math.cos(angle),
      );
      final end = Offset(
        center.dx + tickEnd * math.sin(angle),
        center.dy - tickEnd * math.cos(angle),
      );

      final tickPaint = Paint()
        ..color = textColor.withOpacity(isMainTick ? 0.8 : 0.4)
        ..strokeWidth = isMainTick ? 3 : 1;
      canvas.drawLine(start, end, tickPaint);
    }

    // 绘制时针
    final hourAngle =
        (time.hour % 12 + time.minute / 60) * 30 * math.pi / 180;
    _drawHand(canvas, center, radius * 0.5, hourAngle, textColor, 6);

    // 绘制分针
    final minuteAngle = (time.minute + time.second / 60) * 6 * math.pi / 180;
    _drawHand(canvas, center, radius * 0.75, minuteAngle, textColor, 4);

    // 绘制秒针
    if (config.showSeconds) {
      final secondAngle = time.second * 6 * math.pi / 180;
      _drawHand(canvas, center, radius * 0.85, secondAngle, Colors.red, 2);
    }

    // 绘制中心点
    final centerPaint = Paint()
      ..color = textColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, centerPaint);
  }

  void _drawHand(Canvas canvas, Offset center, double length, double angle,
      Color color, double width) {
    final end = Offset(
      center.dx + length * math.sin(angle),
      center.dy - length * math.cos(angle),
    );

    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/clock/widgets/analog_clock.dart
git commit -m "feat(clock): add analog clock widget"
```

---

## Task 6: 创建样式选择器和背景选择器

**Files:**
- Create: `app/lib/tools/clock/widgets/style_selector.dart`
- Create: `app/lib/tools/clock/widgets/background_picker.dart`

- [ ] **Step 1: 创建 StyleSelector 组件**

```dart
import 'package:flutter/material.dart';
import '../models/clock_config.dart';
import '../models/clock_enums.dart';
import 'digital_clock.dart';
import 'analog_clock.dart';

class StyleSelector extends StatelessWidget {
  final ClockConfig config;
  final ValueChanged<ClockConfig> onConfigChanged;
  final DateTime previewTime;

  const StyleSelector({
    super.key,
    required this.config,
    required this.onConfigChanged,
    required this.previewTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: PageView(
        controller: PageController(
          initialPage: config.type == ClockType.digital ? 0 : 1,
        ),
        onPageChanged: (index) {
          onConfigChanged(config.copyWith(
            type: index == 0 ? ClockType.digital : ClockType.analog,
          ));
        },
        children: [
          _buildPreviewCard(
            title: '数字时钟',
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: DigitalClock(
                time: previewTime,
                config: config.copyWith(showDate: false),
              ),
            ),
          ),
          _buildPreviewCard(
            title: '圆盘时钟',
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: AnalogClock(
                time: previewTime,
                config: config.copyWith(showDate: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Expanded(child: Center(child: child)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: config.effectiveTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 创建 BackgroundPicker 组件**

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/clock_config.dart';
import '../models/clock_enums.dart';

class BackgroundPicker extends StatelessWidget {
  final ClockConfig config;
  final ValueChanged<ClockConfig> onConfigChanged;

  const BackgroundPicker({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  static const List<Color> presetColors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('背景类型'),
        const SizedBox(height: 8),
        SegmentedButton<BackgroundType>(
          segments: const [
            ButtonSegment(
              value: BackgroundType.color,
              label: Text('纯色'),
            ),
            ButtonSegment(
              value: BackgroundType.gradient,
              label: Text('渐变'),
            ),
            ButtonSegment(
              value: BackgroundType.image,
              label: Text('图片'),
            ),
          ],
          selected: {config.backgroundType},
          onSelectionChanged: (value) {
            onConfigChanged(config.copyWith(
              backgroundType: value.first,
            ));
          },
        ),
        const SizedBox(height: 16),
        _buildBackgroundOptions(context),
      ],
    );
  }

  Widget _buildBackgroundOptions(BuildContext context) {
    switch (config.backgroundType) {
      case BackgroundType.color:
        return _buildColorPicker(context);
      case BackgroundType.gradient:
        return _buildGradientPicker(context);
      case BackgroundType.image:
        return _buildImagePicker(context);
    }
  }

  Widget _buildColorPicker(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presetColors.map((color) {
        final isSelected = config.backgroundColor == color;
        return GestureDetector(
          onTap: () {
            onConfigChanged(config.copyWith(backgroundColor: color));
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: Colors.blue, width: 3)
                  : Border.all(color: Colors.grey.shade300),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGradientPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('渐变方向'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildDirectionButton('上下', GradientDirection.topToBottom),
            _buildDirectionButton('左右', GradientDirection.leftToRight),
            _buildDirectionButton('对角↘', GradientDirection.topLeftToBottomRight),
            _buildDirectionButton('对角↙', GradientDirection.topRightToBottomLeft),
          ],
        ),
        const SizedBox(height: 16),
        const Text('渐变颜色'),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGradientColorButton(0),
            const SizedBox(width: 16),
            _buildGradientColorButton(1),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionButton(String label, GradientDirection direction) {
    final isSelected = config.gradientDirection == direction;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        onConfigChanged(config.copyWith(gradientDirection: direction));
      },
    );
  }

  Widget _buildGradientColorButton(int index) {
    final colors = config.gradientColors ?? [Colors.blue, Colors.purple];
    final color = colors[index];

    return GestureDetector(
      onTap: () => _showColorPicker(color, (newColor) {
        final newColors = List<Color>.from(colors);
        newColors[index] = newColor;
        onConfigChanged(config.copyWith(gradientColors: newColors));
      }),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    final hasImage = config.backgroundImagePath != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage)
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(File(config.backgroundImagePath!)),
                fit: BoxFit.cover,
              ),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => _pickImage(context),
          icon: const Icon(Icons.image),
          label: Text(hasImage ? '更换图片' : '选择图片'),
        ),
        if (hasImage) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              onConfigChanged(config.copyWith(backgroundImagePath: null));
            },
            child: const Text('清除图片'),
          ),
        ],
      ],
    );
  }

  void _showColorPicker(Color currentColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择颜色'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      onConfigChanged(config.copyWith(backgroundImagePath: picked.path));
    }
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/tools/clock/widgets/style_selector.dart
git add app/lib/tools/clock/widgets/background_picker.dart
git commit -m "feat(clock): add style selector and background picker widgets"
```

---

## Task 7: 创建设置面板

**Files:**
- Create: `app/lib/tools/clock/widgets/settings_panel.dart`

- [ ] **Step 1: 创建设置面板组件**

```dart
import 'package:flutter/material.dart';
import '../models/clock_config.dart';
import '../models/clock_enums.dart';
import 'style_selector.dart';
import 'background_picker.dart';

class SettingsPanel extends StatelessWidget {
  final ClockConfig config;
  final ValueChanged<ClockConfig> onConfigChanged;
  final DateTime previewTime;
  final VoidCallback onClose;

  const SettingsPanel({
    super.key,
    required this.config,
    required this.onConfigChanged,
    required this.previewTime,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽把手
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // 标题栏
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '时钟设置',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(),
            // 设置内容
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 样式选择
                    const Text(
                      '时钟样式',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    StyleSelector(
                      config: config,
                      onConfigChanged: onConfigChanged,
                      previewTime: previewTime,
                    ),
                    const SizedBox(height: 24),

                    // 主题颜色
                    const Text(
                      '主题',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<ClockThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ClockThemeMode.light,
                          label: Text('浅色'),
                          icon: Icon(Icons.light_mode),
                        ),
                        ButtonSegment(
                          value: ClockThemeMode.dark,
                          label: Text('深色'),
                          icon: Icon(Icons.dark_mode),
                        ),
                        ButtonSegment(
                          value: ClockThemeMode.custom,
                          label: Text('自定义'),
                          icon: Icon(Icons.palette),
                        ),
                      ],
                      selected: {config.theme},
                      onSelectionChanged: (value) {
                        onConfigChanged(config.copyWith(theme: value.first));
                      },
                    ),
                    const SizedBox(height: 24),

                    // 时间格式
                    const Text(
                      '时间格式',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<TimeFormat>(
                      segments: const [
                        ButtonSegment(
                          value: TimeFormat.auto,
                          label: Text('自动'),
                        ),
                        ButtonSegment(
                          value: TimeFormat.format12,
                          label: Text('12小时'),
                        ),
                        ButtonSegment(
                          value: TimeFormat.format24,
                          label: Text('24小时'),
                        ),
                      ],
                      selected: {config.timeFormat},
                      onSelectionChanged: (value) {
                        onConfigChanged(
                            config.copyWith(timeFormat: value.first));
                      },
                    ),
                    const SizedBox(height: 24),

                    // 显示选项
                    const Text(
                      '显示选项',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('显示日期'),
                      value: config.showDate,
                      onChanged: (value) {
                        onConfigChanged(config.copyWith(showDate: value));
                      },
                    ),
                    SwitchListTile(
                      title: const Text('显示秒数'),
                      value: config.showSeconds,
                      onChanged: (value) {
                        onConfigChanged(config.copyWith(showSeconds: value));
                      },
                    ),
                    const SizedBox(height: 24),

                    // 字体大小
                    const Text(
                      '字体大小',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<FontSize>(
                      segments: const [
                        ButtonSegment(
                          value: FontSize.small,
                          label: Text('小'),
                        ),
                        ButtonSegment(
                          value: FontSize.medium,
                          label: Text('中'),
                        ),
                        ButtonSegment(
                          value: FontSize.large,
                          label: Text('大'),
                        ),
                      ],
                      selected: {config.fontSize},
                      onSelectionChanged: (value) {
                        onConfigChanged(config.copyWith(fontSize: value.first));
                      },
                    ),
                    const SizedBox(height: 24),

                    // 背景设置
                    BackgroundPicker(
                      config: config,
                      onConfigChanged: onConfigChanged,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/clock/widgets/settings_panel.dart
git commit -m "feat(clock): add settings panel widget"
```

---

## Task 8: 创建主页面

**Files:**
- Create: `app/lib/tools/clock/clock_page.dart`

- [ ] **Step 1: 创建 ClockPage**

```dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:provider/provider.dart';
import 'models/clock_config.dart';
import 'models/clock_enums.dart';
import 'services/clock_service.dart';
import 'widgets/digital_clock.dart';
import 'widgets/analog_clock.dart';
import 'widgets/settings_panel.dart';

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  bool _showSettingsIcon = true;
  bool _showSettingsPanel = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _enterFullScreen();
    WakelockPlus.enable();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    WakelockPlus.disable();
    _exitFullScreen();
    super.dispose();
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_showSettingsPanel) {
        setState(() => _showSettingsIcon = false);
      }
    });
  }

  void _onScreenTap() {
    if (_showSettingsPanel) return;
    setState(() => _showSettingsIcon = true);
    _startHideTimer();
  }

  void _openSettings() {
    setState(() {
      _showSettingsPanel = true;
      _showSettingsIcon = false;
    });
    _hideTimer?.cancel();
  }

  void _closeSettings() {
    setState(() => _showSettingsPanel = false);
    _startHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClockService(),
      child: Consumer<ClockService>(
        builder: (context, service, child) {
          return GestureDetector(
            onTap: _onScreenTap,
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  // 背景
                  _buildBackground(service.config),

                  // 时钟显示
                  Center(
                    child: _buildClock(service),
                  ),

                  // 设置图标
                  AnimatedOpacity(
                    opacity: _showSettingsIcon ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: _buildSettingsIcon(),
                  ),

                  // 设置面板
                  if (_showSettingsPanel)
                    _buildSettingsOverlay(service),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground(ClockConfig config) {
    switch (config.backgroundType) {
      case BackgroundType.color:
        return Container(color: config.backgroundColor);
      case BackgroundType.gradient:
        final gradient = config.gradientDirection?.toGradient(
              config.gradientColors ?? [Colors.blue, Colors.purple],
            ) ??
            const LinearGradient(
              colors: [Colors.blue, Colors.purple],
            );
        return Container(
          decoration: BoxDecoration(gradient: gradient),
        );
      case BackgroundType.image:
        if (config.backgroundImagePath != null) {
          return Image.file(
            File(config.backgroundImagePath!),
            fit: BoxFit.cover,
          );
        }
        return Container(color: config.backgroundColor);
    }
  }

  Widget _buildClock(ClockService service) {
    final config = service.config;
    final time = service.currentTime;

    switch (config.type) {
      case ClockType.digital:
        return DigitalClock(time: time, config: config);
      case ClockType.analog:
        return AnalogClock(time: time, config: config);
    }
  }

  Widget _buildSettingsIcon() {
    return Positioned(
      top: 16,
      right: 16,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.3),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOverlay(ClockService service) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SettingsPanel(
              config: service.config,
              onConfigChanged: (newConfig) {
                service.saveConfig(newConfig);
              },
              previewTime: service.currentTime,
              onClose: _closeSettings,
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/clock/clock_page.dart
git commit -m "feat(clock): add main clock page with fullscreen and settings"
```

---

## Task 9: 创建 ToolModule

**Files:**
- Create: `app/lib/tools/clock/clock_tool.dart`

- [ ] **Step 1: 创建 ClockTool**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'clock_page.dart';

class ClockTool implements ToolModule {
  @override
  String get id => 'clock';

  @override
  String get name => '全屏时钟';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.access_time;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const ClockPage();
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

- [ ] **Step 2: Commit**

```bash
git add app/lib/tools/clock/clock_tool.dart
git commit -m "feat(clock): add ClockTool module"
```

---

## Task 10: 注册工具

**Files:**
- Modify: `app/lib/main.dart`

- [ ] **Step 1: 导入并注册 ClockTool**

在 main.dart 中找到工具导入区域，添加：

```dart
import 'tools/clock/clock_tool.dart';
```

在 ToolRegistry.register 区域添加：

```dart
ToolRegistry.register(ClockTool());
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/main.dart
git commit -m "feat(clock): register ClockTool in main.dart"
```


## 验收标准检查

所有任务完成后，验证以下功能：

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

---

**计划完成，准备执行**
