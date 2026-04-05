# 画板工具设计文档

**日期**: 2026-03-23
**状态**: 待审核
**分类**: life

---

## 1. 功能概述

在 LittleGrid 应用中新增一个画板工具，支持自由绘画、手写、形状绘制、贴纸等功能。用户可以在手机上进行任意创作，支持多种画笔类型、颜色调整、保存导出等功能。

### 1.1 功能范围

**核心功能**:
- 自由绘画（支持触控笔压力感应）
- 多种画笔类型切换
- 颜色选择器
- 画笔粗细调整
- 橡皮擦
- 撤销/重做
- 清空画布

**形状绘制**:
- 直线、矩形、圆形、三角形、箭头
- 支持填充/描边切换

**贴纸功能**:
- 内置常用图标/表情贴纸
- 支持缩放、旋转、拖动

**保存与导入**:
- 导出为图片（智能裁剪到绘画范围）
- 从相册导入图片作为背景

---

## 2. 技术方案

### 2.1 核心依赖

使用 `perfect_freehand` 作为核心绘图库，配合自定义扩展：

```yaml
dependencies:
  perfect_freehand: ^1.0.0  # 专业手写绘图
```

**为什么选择 perfect_freehand**:
- 模拟真实手写笔触，线条平滑自然
- 支持压力感应（适配触控笔）
- 轻量级，专注绘图核心功能
- 易于扩展自定义形状和贴纸

### 2.2 架构设计

```
lib/tools/canvas/
├── canvas_tool.dart              # ToolModule 实现
├── canvas_page.dart              # 主页面
├── models/
│   ├── stroke.dart               # 笔画数据模型
│   ├── shape.dart                # 形状数据模型
│   ├── sticker.dart              # 贴纸数据模型
│   └── canvas_state.dart         # 画布状态
├── services/
│   ├── drawing_service.dart      # 绘图逻辑服务
│   ├── export_service.dart       # 导出图片服务
│   └── import_service.dart       # 导入图片服务
├── widgets/
│   ├── canvas_widget.dart        # 画布组件
│   ├── toolbar.dart              # 工具栏
│   ├── color_picker.dart         # 颜色选择器
│   ├── brush_selector.dart       # 画笔选择器
│   ├── shape_selector.dart       # 形状选择器
│   ├── sticker_panel.dart        # 贴纸面板
│   └── size_slider.dart          # 粗细调节滑块
└── utils/
    └── drawing_utils.dart        # 绘图工具函数
```

### 2.3 ToolModule 实现

```dart
class CanvasTool implements ToolModule {
  @override
  String get id => 'canvas';

  @override
  String get name => '画板';

  @override
  IconData get icon => Icons.brush;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 2;

  @override
  Widget buildPage(BuildContext context) => const CanvasPage();
}
```

---

## 3. 数据模型

### 3.1 Stroke（笔画）

```dart
class Stroke {
  final String id;
  final List<Offset> points;      // 点序列
  final List<double>? pressures;  // 压力值（可选）
  final Color color;
  final double size;
  final BrushType brushType;
  final bool isEraser;

  Stroke({
    required this.id,
    required this.points,
    this.pressures,
    required this.color,
    required this.size,
    this.brushType = BrushType.normal,
    this.isEraser = false,
  });
}

enum BrushType {
  normal,      // 普通画笔
  marker,      // 马克笔（半透明）
  highlighter, // 荧光笔（高亮）
  pressure,    // 压感画笔
}
```

### 3.2 Shape（形状）

```dart
class Shape {
  final String id;
  final ShapeType type;
  final Rect bounds;
  final Color color;
  final double strokeWidth;
  final bool filled;
  final double rotation;

  Shape({
    required this.id,
    required this.type,
    required this.bounds,
    required this.color,
    this.strokeWidth = 2.0,
    this.filled = false,
    this.rotation = 0.0,
  });
}

enum ShapeType {
  line,
  rectangle,
  circle,
  triangle,
  arrow,
}
```

### 3.3 Sticker（贴纸）

```dart
class Sticker {
  final String id;
  final String assetPath;    // 贴纸资源路径
  final Offset position;
  final double scale;
  final double rotation;

  Sticker({
    required this.id,
    required this.assetPath,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });
}
```

### 3.4 CanvasState（画布状态）

```dart
class CanvasState {
  final List<Stroke> strokes;
  final List<Shape> shapes;
  final List<Sticker> stickers;
  final String? backgroundImage;  // 背景图片路径

  // 撤销栈
  final List<CanvasState> undoStack;
  final List<CanvasState> redoStack;

  CanvasState({
    this.strokes = const [],
    this.shapes = const [],
    this.stickers = const [],
    this.backgroundImage,
    this.undoStack = const [],
    this.redoStack = const [],
  });

  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;
}
```

---

## 4. 界面设计

### 4.1 页面布局

```
┌─────────────────────────────────────┐
│  ←  画板                    [保存]  │  AppBar
├─────────────────────────────────────┤
│                                     │
│                                     │
│         画布区域                    │
│      (GestureDetector)              │
│                                     │
│                                     │
├─────────────────────────────────────┤
│  [画笔] [形状] [贴纸] [橡皮擦]      │  模式切换
├─────────────────────────────────────┤
│  ━━━━━━●━━━━━━  颜色: ●  粗细: ━━  │  属性调节
├─────────────────────────────────────┤
│  [撤销] [重做] [导入] [清空]        │  操作按钮
└─────────────────────────────────────┘
```

### 4.2 画笔选择器

```
┌─────────────────────────────────────┐
│  选择画笔                           │
├─────────────────────────────────────┤
│  ┌───┐ ┌───┐ ┌───┐ ┌───┐          │
│  │ ✏️│ │ 🖍️│ │ 🖍️│ │ ✒️│          │
│  │普通│ │马克│ │荧光│ │压感│          │
│  └───┘ └───┘ └───┘ └───┘          │
└─────────────────────────────────────┘
```

### 4.3 形状选择器

```
┌─────────────────────────────────────┐
│  选择形状                           │
├─────────────────────────────────────┤
│  ──  ▢  ○  △  →                    │
│  直线 矩形 圆形 三角 箭头            │
├─────────────────────────────────────┤
│  [✓] 填充                          │
└─────────────────────────────────────┘
```

### 4.4 颜色选择器

```
┌─────────────────────────────────────┐
│  选择颜色                           │
├─────────────────────────────────────┤
│  ●  ●  ●  ●  ●  ●  ●  ●            │
│  黑  红  橙  黄  绿  蓝  紫  白      │
│                                     │
│  ━━━━━━●━━━━━━  自定义             │
└─────────────────────────────────────┘
```

### 4.5 贴纸面板

```
┌─────────────────────────────────────┐
│  贴纸                         [关闭]│
├─────────────────────────────────────┤
│  😀 😃 😄 😁 😆 😅 🤣 😊           │
│  👍 👎 👏 🙏 💪 ❤️ 💔 💡           │
│  ⭐ 🌟 ✨ 💫 🎉 🎊 🎈 🎁           │
└─────────────────────────────────────┘
```

---

## 5. 核心功能实现

### 5.1 绘图服务

```dart
class DrawingService extends ChangeNotifier {
  CanvasState _state = CanvasState();
  DrawMode _mode = DrawMode.brush;
  Color _currentColor = Colors.black;
  double _currentSize = 3.0;
  BrushType _brushType = BrushType.normal;

  // 当前绘制的笔画
  Stroke? _currentStroke;

  void startStroke(Offset point, {double? pressure}) {
    // 开始新笔画
  }

  void addPoint(Offset point, {double? pressure}) {
    // 添加点到当前笔画
  }

  void endStroke() {
    // 结束笔画，保存到状态
  }

  void undo() { /* 撤销 */ }
  void redo() { /* 重做 */ }
  void clear() { /* 清空 */ }
}

enum DrawMode {
  brush,    // 画笔模式
  shape,    // 形状模式
  sticker,  // 贴纸模式
  eraser,   // 橡皮擦模式
}
```

### 5.2 导出服务

```dart
class ExportService {
  /// 导出画布为图片
  /// 自动裁剪到绘画内容范围
  Future<Uint8List?> exportToImage(CanvasState state) async {
    // 1. 创建 RepaintBoundary
    // 2. 计算绘画内容的边界
    // 3. 裁剪并生成图片
    // 4. 返回 PNG 数据
  }

  /// 保存到相册
  Future<bool> saveToGallery(Uint8List imageData) async {
    // 使用 image_gallery_saver 包保存
  }

  /// 计算绘画边界
  Rect _calculateContentBounds(CanvasState state) {
    // 遍历所有笔画、形状、贴纸
    // 计算最小包围矩形
  }
}
```

### 5.3 导入服务

```dart
class ImportService {
  /// 从相册选择图片
  Future<String?> pickImage() async {
    // 使用 image_picker 包
  }

  /// 设置为背景
  void setBackgroundImage(String path) {
    // 更新画布状态
  }
}
```

---

## 6. 依赖项

```yaml
dependencies:
  perfect_freehand: ^1.0.0    # 核心绘图
  uuid: ^4.0.0                # ID 生成
  image_picker: ^1.0.7        # 图片选择
  image_gallery_saver: ^2.0.0 # 保存到相册
  permission_handler: ^11.0.0 # 权限处理
```

---

## 7. 内置贴纸列表

**表情类**: 😀 😃 😄 😁 😆 😅 🤣 😊 😍 🥰 😘

**手势类**: 👍 👎 👏 🙏 💪 ✌️ 🤞 👆 👇 👈 👉

**符号类**: ❤️ 💔 💡 ⭐ 🌟 ✨ 💫 🔥 💯 🎉 🎊 🎈 🎁 🏆

---

## 8. 验收标准

- [ ] 自由绘画流畅，支持多种画笔
- [ ] 颜色选择器正常工作
- [ ] 画笔粗细可调节
- [ ] 橡皮擦功能正常
- [ ] 撤销/重做功能正常
- [ ] 形状绘制正常（直线、矩形、圆形、三角形、箭头）
- [ ] 形状支持填充/描边切换
- [ ] 贴纸可添加、拖动、缩放、旋转
- [ ] 导出图片功能正常，自动裁剪到绘画范围
- [ ] 导入背景图功能正常
- [ ] 清空画布功能正常
- [ ] 视觉风格与现有应用一致