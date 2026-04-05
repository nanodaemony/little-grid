# 手持弹幕功能实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现手持弹幕功能格子，支持滚动/常驻双模式，预设文案快速选择，文字大小、颜色、滚动速度可调。

**Architecture:** 采用 Flutter StatefulWidget 架构，主页面管理配置状态，全屏页面负责渲染。滚动动画使用 AnimationController + Tween 实现，屏幕方向通过 SystemChrome 控制。

**Tech Stack:** Flutter, Dart, Material Design, flutter/services (屏幕方向)

---

## 文件结构

```
app/lib/tools/handscrollingtext/
├── models/
│   └── danmaku_models.dart                    # 数据模型（DanmakuMode, DanmakuConfig, PresetText）
├── widgets/
│   ├── preset_text_grid.dart                  # 预设文案网格组件
│   ├── config_panel.dart                      # 设置面板（滑块、颜色选择等）
│   ├── color_picker_button.dart               # 颜色选择按钮
│   ├── mode_switcher.dart                     # 模式切换开关
│   └── danmaku_player.dart                    # 弹幕播放器（预览和全屏共用）
├── handscrollingtext_page.dart                # 主配置页面
├── danmaku_player_page.dart                   # 全屏播放页面
└── handscrollingtext_tool.dart                # ToolModule 实现
```

---

## Task 1: 创建数据模型

**Files:**
- Create: `app/lib/tools/handscrollingtext/models/danmaku_models.dart`

**设计参考:** @see docs/superpowers/specs/2026-03-26-handscrollingtext-design.md Section 2

- [ ] **Step 1: 创建目录结构**

```bash
mkdir -p app/lib/tools/handscrollingtext/models
mkdir -p app/lib/tools/handscrollingtext/widgets
```

- [ ] **Step 2: 编写数据模型代码**

创建 `app/lib/tools/handscrollingtext/models/danmaku_models.dart`:

```dart
import 'package:flutter/material.dart';

/// 弹幕显示模式
enum DanmakuMode {
  scroll,   // 滚动模式（从右向左）
  static,   // 常驻模式（居中静止）
}

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

/// 分类列表
final List<String> categories = ['全部', '应援', '表白', '搞笑', '通用'];

/// 系统字体选项
final Map<String, String> fontOptions = {
  'system': '系统默认',
  'serif': '衬线体',
  'sansSerif': '无衬线',
  'monospace': '等宽字体',
};
```

- [ ] **Step 3: 提交**

```bash
git add app/lib/tools/handscrollingtext/
git commit -m "feat(handscrollingtext): 添加数据模型

- DanmakuMode 枚举（scroll/static）
- DanmakuConfig 配置类
- PresetText 预设文案
- 分类和字体选项

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 2: 创建预设文案网格组件

**Files:**
- Create: `app/lib/tools/handscrollingtext/widgets/preset_text_grid.dart`

**设计参考:** @see docs/superpowers/specs/2026-03-26-handscrollingtext-design.md Section 3.2

- [ ] **Step 1: 编写预设文案网格组件**

创建 `app/lib/tools/handscrollingtext/widgets/preset_text_grid.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/danmaku_models.dart';

class PresetTextGrid extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onTextSelected;

  const PresetTextGrid({
    super.key,
    required this.selectedCategory,
    required this.onTextSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filteredTexts = selectedCategory == '全部'
        ? presetTexts
        : presetTexts.where((p) => p.category == selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分类标签
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = category == selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => onTextSelected('__category__$category'),
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // 预设文案网格
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filteredTexts.map((preset) {
            return ActionChip(
              label: Text(preset.text),
              onPressed: () => onTextSelected(preset.text),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            );
          }).toList(),
        ),
      ],
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/handscrollingtext/widgets/preset_text_grid.dart
git commit -m "feat(handscrollingtext): 添加预设文案网格组件

- 分类筛选标签
- 网格展示预设文案
- 点击回调

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 3: 创建颜色选择按钮

**Files:**
- Create: `app/lib/tools/handscrollingtext/widgets/color_picker_button.dart`

- [ ] **Step 1: 编写颜色选择按钮组件**

创建 `app/lib/tools/handscrollingtext/widgets/color_picker_button.dart`:

```dart
import 'package:flutter/material.dart';

class ColorPickerButton extends StatelessWidget {
  final Color color;
  final String label;
  final Function(Color) onColorChanged;

  const ColorPickerButton({
    super.key,
    required this.color,
    required this.label,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showColorPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final List<Color> presetColors = [
      Colors.white,
      Colors.black,
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('选择$label'),
          content: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presetColors.map((c) {
              return InkWell(
                onTap: () {
                  onColorChanged(c);
                  Navigator.pop(context);
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color == c ? Colors.black : Colors.grey.shade300,
                      width: color == c ? 3 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/handscrollingtext/widgets/color_picker_button.dart
git commit -m "feat(handscrollingtext): 添加颜色选择按钮

- 圆形颜色预览
- 21种预设颜色选择
- 选中高亮显示

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 4: 创建模式切换器

**Files:**
- Create: `app/lib/tools/handscrollingtext/widgets/mode_switcher.dart`

- [ ] **Step 1: 编写模式切换器组件**

创建 `app/lib/tools/handscrollingtext/widgets/mode_switcher.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/danmaku_models.dart';

class ModeSwitcher extends StatelessWidget {
  final DanmakuMode mode;
  final Function(DanmakuMode) onModeChanged;

  const ModeSwitcher({
    super.key,
    required this.mode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DanmakuMode>(
      segments: const [
        ButtonSegment(
          value: DanmakuMode.scroll,
          label: Text('滚动'),
          icon: Icon(Icons.arrow_back),
        ),
        ButtonSegment(
          value: DanmakuMode.static,
          label: Text('常驻'),
          icon: Icon(Icons.pause),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (newSelection) {
        if (newSelection.isNotEmpty) {
          onModeChanged(newSelection.first);
        }
      },
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/handscrollingtext/widgets/mode_switcher.dart
git commit -m "feat(handscrollingtext): 添加模式切换器

- 滚动/常驻双模式切换
- SegmentedButton 样式

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 5: 创建弹幕播放器组件

**Files:**
- Create: `app/lib/tools/handscrollingtext/widgets/danmaku_player.dart`

**设计参考:** @see docs/superpowers/specs/2026-03-26-handscrollingtext-design.md Section 4

- [ ] **Step 1: 编写弹幕播放器组件**

创建 `app/lib/tools/handscrollingtext/widgets/danmaku_player.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/danmaku_models.dart';

class DanmakuPlayer extends StatefulWidget {
  final DanmakuConfig config;
  final bool isPreview; // 是否是预览模式

  const DanmakuPlayer({
    super.key,
    required this.config,
    this.isPreview = false,
  });

  @override
  State<DanmakuPlayer> createState() => _DanmakuPlayerState();
}

class _DanmakuPlayerState extends State<DanmakuPlayer>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;
  double _textWidth = 0;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  @override
  void didUpdateWidget(DanmakuPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 配置变化时重新初始化动画
    if (oldWidget.config.mode != widget.config.mode ||
        oldWidget.config.speed != widget.config.speed ||
        oldWidget.config.text != widget.config.text) {
      _initAnimation();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _initAnimation() {
    _controller?.dispose();

    if (widget.config.mode != DanmakuMode.scroll) {
      _controller = null;
      _animation = null;
      return;
    }

    // 延迟初始化以获取正确的文本宽度
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final screenWidth = MediaQuery.of(context).size.width;
      // 估算文本宽度（实际宽度会在布局后获取）
      final estimatedWidth = widget.config.text.length * widget.config.fontSize * 0.8;

      final distance = screenWidth + estimatedWidth;
      // 速度越大，时间越短
      final durationMs = (distance / widget.config.speed * 20).toInt();

      _controller = AnimationController(
        duration: Duration(milliseconds: durationMs.clamp(2000, 20000)),
        vsync: this,
      );

      _animation = Tween<double>(
        begin: screenWidth,
        end: -estimatedWidth,
      ).animate(_controller!);

      _controller!.repeat();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.config.backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 根据字体选项选择字体
          TextStyle textStyle = TextStyle(
            fontSize: widget.isPreview
                ? widget.config.fontSize * 0.3  // 预览时缩小
                : widget.config.fontSize,
            color: widget.config.textColor,
            fontWeight: FontWeight.bold,
          );

          // 应用字体
          switch (widget.config.fontFamily) {
            case 'serif':
              textStyle = textStyle.copyWith(fontFamily: 'serif');
              break;
            case 'sansSerif':
              textStyle = textStyle.copyWith(fontFamily: 'sans-serif');
              break;
            case 'monospace':
              textStyle = textStyle.copyWith(fontFamily: 'monospace');
              break;
            default:
              break;
          }

          if (widget.config.mode == DanmakuMode.scroll && _animation != null) {
            // 滚动模式
            return AnimatedBuilder(
              animation: _animation!,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      left: _animation!.value,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Text(
                          widget.config.text,
                          style: textStyle,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            // 常驻模式或动画未初始化
            return Center(
              child: Text(
                widget.config.text,
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            );
          }
        },
      ),
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/handscrollingtext/widgets/danmaku_player.dart
git commit -m "feat(handscrollingtext): 添加弹幕播放器组件

- 支持滚动/常驻双模式
- 滚动模式使用 AnimationController + Tween
- 预览模式自动缩小字体
- 响应配置变化

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 6: 创建配置面板组件

**Files:**
- Create: `app/lib/tools/handscrollingtext/widgets/config_panel.dart`

- [ ] **Step 1: 编写配置面板组件**

创建 `app/lib/tools/handscrollingtext/widgets/config_panel.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/danmaku_models.dart';
import 'color_picker_button.dart';
import 'mode_switcher.dart';

class ConfigPanel extends StatelessWidget {
  final DanmakuConfig config;
  final Function(DanmakuConfig) onConfigChanged;

  const ConfigPanel({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 模式切换
        ModeSwitcher(
          mode: config.mode,
          onModeChanged: (mode) => onConfigChanged(config.copyWith(mode: mode)),
        ),
        const SizedBox(height: 16),

        // 字体选择
        DropdownButtonFormField<String>(
          value: config.fontFamily,
          decoration: const InputDecoration(
            labelText: '字体',
            border: OutlineInputBorder(),
          ),
          items: fontOptions.entries.map((entry) {
            return DropdownMenuItem(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onConfigChanged(config.copyWith(fontFamily: value));
            }
          },
        ),
        const SizedBox(height: 16),

        // 颜色选择
        Row(
          children: [
            ColorPickerButton(
              color: config.textColor,
              label: '文字颜色',
              onColorChanged: (color) => onConfigChanged(config.copyWith(textColor: color)),
            ),
            const SizedBox(width: 16),
            ColorPickerButton(
              color: config.backgroundColor,
              label: '背景颜色',
              onColorChanged: (color) => onConfigChanged(config.copyWith(backgroundColor: color)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 字体大小滑块
        Row(
          children: [
            const Text('字体大小'),
            Expanded(
              child: Slider(
                value: config.fontSize,
                min: 50,
                max: 300,
                divisions: 25,
                label: config.fontSize.toInt().toString(),
                onChanged: (value) => onConfigChanged(config.copyWith(fontSize: value)),
              ),
            ),
            Text('${config.fontSize.toInt()}'),
          ],
        ),

        // 滚动速度滑块（仅滚动模式显示）
        if (config.mode == DanmakuMode.scroll)
          Row(
            children: [
              const Text('滚动速度'),
              Expanded(
                child: Slider(
                  value: config.speed,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: config.speed.toInt().toString(),
                  onChanged: (value) => onConfigChanged(config.copyWith(speed: value)),
                ),
              ),
              Text('${config.speed.toInt()}'),
            ],
          ),
      ],
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/handscrollingtext/widgets/config_panel.dart
git commit -m "feat(handscrollingtext): 添加配置面板组件

- 模式切换
- 字体下拉选择
- 颜色选择按钮
- 字体大小滑块
- 滚动速度滑块（条件显示）

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 7: 创建主配置页面

**Files:**
- Create: `app/lib/tools/handscrollingtext/handscrollingtext_page.dart`

**设计参考:** @see docs/superpowers/specs/2026-03-26-handscrollingtext-design.md Section 3.2

- [ ] **Step 1: 编写主配置页面**

创建 `app/lib/tools/handscrollingtext/handscrollingtext_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'models/danmaku_models.dart';
import 'widgets/config_panel.dart';
import 'widgets/danmaku_player.dart';
import 'widgets/preset_text_grid.dart';
import 'danmaku_player_page.dart';

class HandScrollingTextPage extends StatefulWidget {
  const HandScrollingTextPage({super.key});

  @override
  State<HandScrollingTextPage> createState() => _HandScrollingTextPageState();
}

class _HandScrollingTextPageState extends State<HandScrollingTextPage> {
  late DanmakuConfig _config;
  final TextEditingController _textController = TextEditingController();
  String _selectedCategory = '全部';

  @override
  void initState() {
    super.initState();
    _config = DanmakuConfig(text: '');
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _config = _config.copyWith(text: _textController.text);
    });
  }

  void _onPresetSelected(String text) {
    if (text.startsWith('__category__')) {
      // 切换分类
      setState(() {
        _selectedCategory = text.replaceFirst('__category__', '');
      });
    } else {
      // 选择文案
      _textController.text = text;
    }
  }

  void _onConfigChanged(DanmakuConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
  }

  bool _canPlay() {
    return _config.text.trim().isNotEmpty;
  }

  void _startDanmaku() {
    if (!_canPlay()) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DanmakuPlayerPage(config: _config),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('手持弹幕'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: _canPlay() ? _startDanmaku : null,
            tooltip: '播放',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 预览区域
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.hardEdge,
              child: _config.text.isEmpty
                  ? Center(
                      child: Text(
                        '输入文字预览效果',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    )
                  : DanmakuPlayer(
                      config: _config,
                      isPreview: true,
                    ),
            ),
            const SizedBox(height: 24),

            // 文案输入
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: '文案',
                hintText: '输入要显示的文字',
                border: const OutlineInputBorder(),
                suffixIcon: _config.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _textController.clear(),
                      )
                    : null,
              ),
              maxLength: 100,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),

            // 预设文案
            Text(
              '预设文案',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            PresetTextGrid(
              selectedCategory: _selectedCategory,
              onTextSelected: _onPresetSelected,
            ),
            const SizedBox(height: 24),

            // 设置面板
            Text(
              '设置',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ConfigPanel(
              config: _config,
              onConfigChanged: _onConfigChanged,
            ),
            const SizedBox(height: 32),

            // 播放按钮
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _canPlay() ? _startDanmaku : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('开始播放'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/handscrollingtext/handscrollingtext_page.dart
git commit -m "feat(handscrollingtext): 添加主配置页面

- 预览区域
- 文案输入框
- 预设文案网格
- 设置面板
- 播放按钮

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 8: 创建全屏播放页面

**Files:**
- Create: `app/lib/tools/handscrollingtext/danmaku_player_page.dart`

**设计参考:** @see docs/superpowers/specs/2026-03-26-handscrollingtext-design.md Section 3.3

- [ ] **Step 1: 编写全屏播放页面**

创建 `app/lib/tools/handscrollingtext/danmaku_player_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/danmaku_models.dart';
import 'widgets/danmaku_player.dart';

class DanmakuPlayerPage extends StatefulWidget {
  final DanmakuConfig config;

  const DanmakuPlayerPage({
    super.key,
    required this.config,
  });

  @override
  State<DanmakuPlayerPage> createState() => _DanmakuPlayerPageState();
}

class _DanmakuPlayerPageState extends State<DanmakuPlayerPage> {
  @override
  void initState() {
    super.initState();
    // 强制横屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // 隐藏系统 UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // 恢复竖屏
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // 恢复系统 UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: widget.config.backgroundColor,
        body: DanmakuPlayer(
          config: widget.config,
          isPreview: false,
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/handscrollingtext/danmaku_player_page.dart
git commit -m "feat(handscrollingtext): 添加全屏播放页面

- 强制横屏显示
- 沉浸模式（隐藏系统 UI）
- 点击屏幕返回
- 恢复屏幕方向

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 9: 创建 ToolModule 实现

**Files:**
- Create: `app/lib/tools/handscrollingtext/handscrollingtext_tool.dart`

**参考:** @see app/lib/tools/calculator/calculator_tool.dart

- [ ] **Step 1: 编写 ToolModule 实现**

创建 `app/lib/tools/handscrollingtext/handscrollingtext_tool.dart`:

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'handscrollingtext_page.dart';

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
  Widget buildPage(BuildContext context) {
    return const HandScrollingTextPage();
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

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/handscrollingtext/handscrollingtext_tool.dart
git commit -m "feat(handscrollingtext): 添加 ToolModule 实现

- 实现 ToolModule 接口
- 配置工具属性（id, name, icon, category）
- 小格子展示

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 10: 注册到主程序

**Files:**
- Modify: `app/lib/main.dart`

- [ ] **Step 1: 添加导入和注册**

在 `app/lib/main.dart` 中添加：

**在 imports 区域添加（约第 30 行后）：**
```dart
import 'tools/handscrollingtext/handscrollingtext_tool.dart';
```

**在 ToolRegistry.register 区域添加（约第 58 行后）：**
```dart
ToolRegistry.register(HandScrollingTextTool());
```

- [ ] **Step 2: 验证修改**

检查修改后的 `main.dart` 包含：
1. 新的 import 语句
2. ToolRegistry.register(HandScrollingTextTool()) 调用

- [ ] **Step 3: 提交**

```bash
git add app/lib/main.dart
git commit -m "feat(handscrollingtext): 注册工具到主程序

- 添加 HandScrollingTextTool 导入
- 在 ToolRegistry 中注册

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 11: 构建和基础测试

**Files:**
- Test: 运行 Flutter 构建验证

- [ ] **Step 1: 验证代码语法**

```bash
cd app && flutter analyze lib/tools/handscrollingtext/
```

Expected: 无错误

- [ ] **Step 2: 尝试构建**

```bash
cd app && flutter build apk --debug
```

Expected: 构建成功

- [ ] **Step 3: 提交完成标记**

```bash
git commit --allow-empty -m "feat(handscrollingtext): 功能开发完成

- 手持弹幕功能完整实现
- 支持滚动/常驻双模式
- 预设文案快速选择
- 文字大小、颜色、滚动速度可调
- 全屏横屏播放

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## 测试清单

### 功能测试
- [ ] 预设文案点击正确填入输入框
- [ ] 模式切换（滚动/常驻）正常工作
- [ ] 颜色选择器正确应用颜色
- [ ] 字体大小滑块实时生效
- [ ] 滚动速度滑块调整生效
- [ ] 全屏播放正确锁定横屏
- [ ] 点击屏幕/返回键正确返回

### 边界测试
- [ ] 空文案时播放按钮禁用
- [ ] 超长文案（>100字）提示
- [ ] 频繁播放/返回不崩溃
- [ ] 快速切换模式配置保持

### 视觉测试
- [ ] 不同屏幕尺寸文字正常显示
- [ ] 深色/浅色模式颜色正确
- [ ] 预览区域与全屏效果一致

---

## 参考资料

1. **设计文档**: `docs/superpowers/specs/2026-03-26-handscrollingtext-design.md`
2. **现有工具参考**: `app/lib/tools/calculator/calculator_tool.dart`
3. **主程序**: `app/lib/main.dart`
4. **AnimationController**: https://api.flutter.dev/flutter/animation/AnimationController-class.html
5. **SystemChrome**: https://api.flutter.dev/flutter/services/SystemChrome-class.html
