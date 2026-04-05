# 手持弹幕功能设计文档

## 1. 概述

### 1.1 功能目标
新增"手持弹幕"功能格子，用于演唱会、应援接机等场景，让手机可以像弹幕一样滚动播出文字，或像举牌一样静止显示文字。

### 1.2 核心模式

**滚动模式**：
- 文字从右向左水平滚动（传统弹幕效果）
- 支持调整滚动速度

**常驻模式**：
- 文字居中静止显示（举牌效果）
- 适合需要持续展示固定信息的场景

### 1.3 设计原则
- 即开即用，用完即走
- 简洁直观，无需学习成本
- 不保存历史记录，保护隐私

---

## 2. 数据模型设计

### 2.1 枚举类型

```dart
/// 弹幕显示模式
enum DanmakuMode {
  scroll,   // 滚动模式（从右向左）
  static,   // 常驻模式（居中静止）
}
```

### 2.2 弹幕配置类

```dart
/// 弹幕配置
class DanmakuConfig {
  final String text;           // 显示文本
  final DanmakuMode mode;      // 显示模式
  final double fontSize;       // 字体大小 (50-300)
  final Color textColor;       // 文字颜色
  final Color backgroundColor; // 背景颜色
  final double speed;          // 滚动速度 (1-10，仅滚动模式)
  final String fontFamily;     // 字体（系统内置）

  DanmakuConfig({
    required this.text,
    this.mode = DanmakuMode.scroll,
    this.fontSize = 120,
    this.textColor = Colors.white,
    this.backgroundColor = Colors.black,
    this.speed = 5,
    this.fontFamily = 'system', // 系统默认字体
  });

  DanmakuConfig copyWith({
    String? text,
    DanmakuMode? mode,
    double? fontSize,
    Color? textColor,
    Color? backgroundColor,
    double? speed,
    String? fontFamily,
  }) {
    return DanmakuConfig(
      text: text ?? this.text,
      mode: mode ?? this.mode,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      speed: speed ?? this.speed,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}
```

### 2.3 预设文案

```dart
/// 预设文案
class PresetText {
  final String text;
  final String category; // 分类：应援/表白/搞笑/通用

  const PresetText({required this.text, required this.category});
}

/// 系统预设文案列表
final List<PresetText> presetTexts = [
  // 应援
  PresetText(text: '加油！', category: '应援'),
  PresetText(text: '我爱你', category: '应援'),
  PresetText(text: '欢迎回家', category: '应援'),
  PresetText(text: '最棒的', category: '应援'),
  // 表白
  PresetText(text: '做我女朋友吧', category: '表白'),
  PresetText(text: '嫁给我', category: '表白'),
  PresetText(text: '喜欢你', category: '表白'),
  // 搞笑
  PresetText(text: '我是路人甲', category: '搞笑'),
  PresetText(text: '求合影', category: '搞笑'),
  PresetText(text: '请投食', category: '搞笑'),
  // 通用
  PresetText(text: '找人', category: '通用'),
  PresetText(text: '求助', category: '通用'),
  PresetText(text: '谢谢', category: '通用'),
];
```

---

## 3. UI 设计

### 3.1 文件结构

```
lib/tools/handscrollingtext/
├── handscrollingtext_tool.dart    # ToolModule 实现
├── handscrollingtext_page.dart    # 主页面（配置页）
├── danmaku_player_page.dart       # 全屏弹幕播放页
├── models/
│   └── danmaku_models.dart        # 数据模型
└── widgets/
    ├── danmaku_player.dart        # 弹幕播放器（全屏）
    ├── preset_text_grid.dart      # 预设文案网格
    ├── config_panel.dart          # 设置面板
    ├── color_picker_button.dart   # 颜色选择按钮
    └── mode_switcher.dart         # 模式切换器
```

### 3.2 主页面布局（配置页）

```
┌─────────────────────────────┐
│  ← 手持弹幕          [播放]  │  ← AppBar
├─────────────────────────────┤
│                             │
│     ┌─────────────────┐     │
│     │                 │     │
│     │   预览区域      │     │  ← 实时预览效果
│     │   (实时效果)    │     │
│     │                 │     │
│     └─────────────────┘     │
│                             │
├─────────────────────────────┤
│  文案输入                    │
│  ┌─────────────────────┐    │
│  │ [文本输入框]        │    │  ← 支持手动输入
│  └─────────────────────┘    │
├─────────────────────────────┤
│  预设文案 [应援] [表白] [全部]│  ← 分类标签
│  ┌────┐ ┌────┐ ┌────┐      │
│  │加油│ │我爱│ │欢迎│ ...   │  ← 点击填入输入框
│  └────┘ └────┘ └────┘      │
├─────────────────────────────┤
│  模式: [滚动 ●○ 常驻]        │  ← 切换开关
│  字体: [系统默认 ▼]          │  ← 下拉选择
│  [文字颜色 ●] [背景颜色 ●]   │  ← 颜色选择器
│  字体大小: ━━━━●━━━ 120     │  ← 滑块 (50-300)
│  滚动速度: ━━━●━━━━ 5       │  ← 滑块 (1-10，滚动模式显示)
└─────────────────────────────┘
```

**界面元素说明**:

| 元素 | 说明 |
|------|------|
| 预览区域 | 实时显示当前配置的效果 |
| 文案输入框 | 支持手动输入，显示当前选中的预设文案 |
| 预设文案网格 | 网格展示，点击快速填入 |
| 分类标签 | 筛选预设文案类别 |
| 模式切换 | 滚动/常驻双模式切换 |
| 字体选择 | 系统内置字体下拉选择 |
| 颜色选择器 | 弹出颜色面板选择 |
| 滑块 | 调整字体大小和滚动速度 |

### 3.3 全屏弹幕页（横屏锁定）

```
┌──────────────────────────────────────────────────┐
│                                                  │
│                                                  │
│    ←  [超大文字滚动或居中显示]  →               │  ← 文字区域
│                                                  │
│                                                  │
│    (点击任意位置返回配置页)                      │
└──────────────────────────────────────────────────┘
```

**交互**:
- 点击屏幕任意位置 → 返回配置页
- 系统返回键 → 返回配置页
- 强制横屏显示

### 3.4 预设文案分类

| 分类 | 文案示例 |
|------|----------|
| 应援 | 加油！、我爱你、欢迎回家、最棒的 |
| 表白 | 做我女朋友吧、嫁给我、喜欢你 |
| 搞笑 | 我是路人甲、求合影、请投食 |
| 通用 | 找人、求助、谢谢 |

---

## 4. 动画设计

### 4.1 滚动模式动画

```dart
class DanmakuScrollAnimation {
  late AnimationController _controller;
  late Animation<double> _animation;

  void initAnimation(TickerProvider vsync, double screenWidth, double textWidth, double speed) {
    // 计算持续时间：距离 / 速度
    final distance = screenWidth + textWidth;
    final duration = Duration(milliseconds: (distance / speed * 10).toInt());

    _controller = AnimationController(
      duration: duration,
      vsync: vsync,
    );

    _animation = Tween<double>(
      begin: screenWidth,      // 从屏幕右侧开始
      end: -textWidth,         // 到文字完全离开左侧
    ).animate(_controller);

    _controller.repeat(); // 循环播放
  }
}
```

### 4.2 常驻模式

无需动画，文字使用 `Center` 组件居中显示。

---

## 5. 页面流程

```
┌─────────────────────────────────────────────────────────────┐
│                        配置页 (竖屏)                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  • 预览区域                                          │   │
│  │  • 文案输入框                                        │   │
│  │  • 预设文案网格                                      │   │
│  │  • 设置面板                                          │   │
│  └─────────────────────────────────────────────────────┘   │
│                          │                                  │
│                          │ 点击【播放】按钮                  │
│                          ▼                                  │
│              ┌───────────────────────┐                     │
│              │ 强制横屏              │                     │
│              │ 传递 DanmakuConfig    │                     │
│              └───────────────────────┘                     │
│                          │                                  │
│                          ▼                                  │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              全屏弹幕页 (横屏锁定)                    │   │
│  │                                                     │   │
│  │         [滚动或静止的超大文字]                      │   │
│  │                                                     │   │
│  │  点击屏幕 / 返回键 ──────→ 返回配置页               │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 6. 组件职责

### 6.1 HandScrollingTextPage

**职责**：
- 管理 `DanmakuConfig` 状态
- 响应用户输入更新配置
- 处理预设文案点击
- 导航到全屏播放页

**状态**：
```dart
class _HandScrollingTextPageState extends State<HandScrollingTextPage> {
  late DanmakuConfig _config;
  final TextEditingController _textController = TextEditingController();
  String _selectedCategory = '全部';
}
```

### 6.2 DanmakuPlayerPage

**职责**：
- 接收 `DanmakuConfig` 参数
- 强制横屏显示
- 渲染弹幕动画
- 处理返回手势

### 6.3 DanmakuPlayer

**职责**：
- 根据模式渲染不同效果
- 滚动模式：管理动画控制器
- 常驻模式：居中显示文字
- 响应配置变化

### 6.4 PresetTextGrid

**职责**：
- 根据分类筛选显示预设文案
- 点击回调传递文案文本

### 6.5 ConfigPanel

**职责**：
- 模式切换开关
- 字体下拉选择
- 颜色选择按钮
- 滑块控件

---

## 7. 边界情况处理

### 7.1 输入处理

| 情况 | 处理方式 |
|------|----------|
| 文案为空 | 禁用播放按钮，显示提示 |
| 文案过长 (>100字) | 提示用户简化文案 |
| 超长文本显示 | 自动缩小字号或截断 |
| 特殊字符 | 正常显示，支持 Emoji |

### 7.2 屏幕方向

| 情况 | 处理方式 |
|------|----------|
| 进入播放页 | 强制锁定横屏 |
| 返回配置页 | 恢复竖屏 |
| 播放中切后台 | 保持横屏状态 |

### 7.3 性能优化

| 优化点 | 实现方式 |
|--------|----------|
| 减少重绘 | 使用 `RepaintBoundary` |
| 动画性能 | 使用 `Ticker` 精确控制帧率 |
| 内存管理 | 及时释放动画控制器 |

### 7.4 交互细节

| 细节 | 处理方式 |
|------|----------|
| 播放页点击 | 返回配置页（透明按钮覆盖） |
| 返回键 | 正常返回配置页 |
| 配置变化 | 预览区域实时更新 |

---

## 8. 集成点

### 8.1 ToolModule 实现

```dart
class HandScrollingTextTool implements ToolModule {
  @override
  String get id => 'handscrollingtext';

  @override
  String get name => '手持弹幕';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.text_fields;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1; // 小格子

  @override
  Widget buildPage(BuildContext context) => const HandScrollingTextPage();

  @override
  Future<void> initialize() async {
    // 无需初始化
  }

  @override
  Future<void> dispose() async {
    // 无需清理
  }
}
```

### 8.2 注册到 ToolRegistry

在 `main.dart` 中添加：

```dart
import 'tools/handscrollingtext/handscrollingtext_tool.dart';

void main() {
  // ...
  ToolRegistry.register(HandScrollingTextTool());
  // ...
}
```

### 8.3 依赖

- 无需数据库（用完即走）
- 无需网络请求
- 纯前端实现

---

## 9. 测试要点

### 9.1 功能测试

| 测试项 | 验证内容 |
|--------|----------|
| 预设文案点击 | 是否正确填入输入框 |
| 模式切换 | 滚动/常驻模式是否正确切换 |
| 颜色选择 | 文字和背景颜色是否正确应用 |
| 字体大小 | 滑块调整是否实时生效 |
| 滚动速度 | 滑块调整是否影响滚动速度 |
| 全屏播放 | 是否正确锁定横屏并播放 |
| 返回操作 | 点击屏幕/返回键是否正确返回 |

### 9.2 边界测试

| 测试项 | 验证内容 |
|--------|----------|
| 空文案 | 播放按钮是否正确禁用 |
| 超长文案 | 是否正确处理（截断或缩小） |
| 快速切换模式 | 是否保持配置一致 |
| 频繁播放/返回 | 动画是否正确释放 |

### 9.3 兼容性测试

| 测试项 | 验证内容 |
|--------|----------|
| 不同屏幕尺寸 | 文字是否正常显示 |
| 不同字体 | 系统字体是否正确应用 |
| 深色/浅色模式 | 颜色是否正确显示 |

---

## 10. 实现顺序

1. **数据模型** - `danmaku_models.dart`
2. **预设文案网格** - `preset_text_grid.dart`
3. **设置面板组件** - `config_panel.dart`, `color_picker_button.dart`, `mode_switcher.dart`
4. **弹幕播放器** - `danmaku_player.dart`
5. **主页面** - `handscrollingtext_page.dart`
6. **全屏播放页** - `danmaku_player_page.dart`
7. **工具注册** - `handscrollingtext_tool.dart`
8. **集成测试**

---

## 11. 附录

### 11.1 参考文件

- 项目现有工具模式：`tools/calculator/calculator_tool.dart`
- 页面架构参考：`tools/coin/coin_page.dart`
- 动画实现参考：Flutter `AnimationController`

### 11.2 命名约定

- 文件名：snake_case（如 `handscrollingtext_page.dart`）
- 类名：PascalCase（如 `HandScrollingTextPage`）
- 方法/变量：camelCase（如 `danmakuConfig`）

### 11.3 设计决策记录

| 决策 | 原因 |
|------|------|
| 不保存历史记录 | 保护用户隐私，用完即走 |
| 使用系统内置字体 | 减少包体积，避免字体版权问题 |
| 强制横屏播放 | 保证最佳视觉效果，符合使用场景 |
| 纯前端实现 | 无需后端支持，离线可用 |
| 系统预设 + 自定义 | 兼顾便捷性和灵活性 |
