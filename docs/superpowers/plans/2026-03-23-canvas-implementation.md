# 画板工具实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 LittleGrid 应用中新增画板工具，支持自由绘画、形状绘制、贴纸、导出导入等功能。

**Architecture:** 使用 perfect_freehand 作为核心绘图库，配合 CustomPaint 实现形状和贴纸，Provider 管理状态。

**Tech Stack:** Flutter, Dart, perfect_freehand, image_picker, image_gallery_saver

---

## File Structure

| 文件 | 职责 |
|------|------|
| `lib/tools/canvas/models/stroke.dart` | 笔画数据模型 |
| `lib/tools/canvas/models/shape.dart` | 形状数据模型 |
| `lib/tools/canvas/models/sticker.dart` | 贴纸数据模型 |
| `lib/tools/canvas/models/canvas_state.dart` | 画布状态模型 |
| `lib/tools/canvas/services/drawing_service.dart` | 绘图逻辑服务 |
| `lib/tools/canvas/services/export_service.dart` | 导出图片服务 |
| `lib/tools/canvas/widgets/canvas_widget.dart` | 画布组件 |
| `lib/tools/canvas/widgets/toolbar.dart` | 工具栏组件 |
| `lib/tools/canvas/widgets/color_picker.dart` | 颜色选择器 |
| `lib/tools/canvas/widgets/brush_selector.dart` | 画笔选择器 |
| `lib/tools/canvas/widgets/shape_selector.dart` | 形状选择器 |
| `lib/tools/canvas/widgets/sticker_panel.dart` | 贴纸面板 |
| `lib/tools/canvas/widgets/size_slider.dart` | 粗细调节滑块 |
| `lib/tools/canvas/canvas_page.dart` | 主页面 |
| `lib/tools/canvas/canvas_tool.dart` | ToolModule 实现 |
| `lib/main.dart` | 注册 CanvasTool |
| `pubspec.yaml` | 添加依赖 |

---

### Task 1: 添加依赖

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: 添加依赖到 pubspec.yaml**

```yaml
dependencies:
  perfect_freehand: ^1.0.0
  image_gallery_saver: ^2.0.0
```

注：`uuid` 和 `image_picker` 已存在于项目中，`permission_handler` 已存在。

- [ ] **Step 2: 提交**

```bash
git add pubspec.yaml
git commit -m "feat(canvas): add dependencies for drawing board"
```

---

### Task 2: 数据模型

**Files:**
- Create: `lib/tools/canvas/models/stroke.dart`
- Create: `lib/tools/canvas/models/shape.dart`
- Create: `lib/tools/canvas/models/sticker.dart`
- Create: `lib/tools/canvas/models/canvas_state.dart`

- [ ] **Step 1: 创建笔画模型 stroke.dart**

```dart
import 'package:flutter/material.dart';

enum BrushType {
  normal,      // 普通画笔
  marker,      // 马克笔（半透明）
  highlighter, // 荧光笔（高亮）
  pressure,    // 压感画笔
}

class Stroke {
  final String id;
  final List<Offset> points;
  final List<double>? pressures;
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

  Stroke copyWith({
    String? id,
    List<Offset>? points,
    List<double>? pressures,
    Color? color,
    double? size,
    BrushType? brushType,
    bool? isEraser,
  }) {
    return Stroke(
      id: id ?? this.id,
      points: points ?? this.points,
      pressures: pressures ?? this.pressures,
      color: color ?? this.color,
      size: size ?? this.size,
      brushType: brushType ?? this.brushType,
      isEraser: isEraser ?? this.isEraser,
    );
  }

  /// 获取笔画的边界
  Rect getBounds() {
    if (points.isEmpty) return Rect.zero;

    double minX = points.first.dx;
    double maxX = points.first.dx;
    double minY = points.first.dy;
    double maxY = points.first.dy;

    for (final point in points) {
      if (point.dx < minX) minX = point.dx;
      if (point.dx > maxX) maxX = point.dx;
      if (point.dy < minY) minY = point.dy;
      if (point.dy > maxY) maxY = point.dy;
    }

    return Rect.fromLTRB(minX - size, minY - size, maxX + size, maxY + size);
  }
}
```

- [ ] **Step 2: 创建形状模型 shape.dart**

```dart
import 'package:flutter/material.dart';

enum ShapeType {
  line,
  rectangle,
  circle,
  triangle,
  arrow,
}

class CanvasShape {
  final String id;
  final ShapeType type;
  final Rect bounds;
  final Color color;
  final double strokeWidth;
  final bool filled;
  final double rotation;

  CanvasShape({
    required this.id,
    required this.type,
    required this.bounds,
    required this.color,
    this.strokeWidth = 2.0,
    this.filled = false,
    this.rotation = 0.0,
  });

  CanvasShape copyWith({
    String? id,
    ShapeType? type,
    Rect? bounds,
    Color? color,
    double? strokeWidth,
    bool? filled,
    double? rotation,
  }) {
    return CanvasShape(
      id: id ?? this.id,
      type: type ?? this.type,
      bounds: bounds ?? this.bounds,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      filled: filled ?? this.filled,
      rotation: rotation ?? this.rotation,
    );
  }

  /// 获取形状的边界
  Rect getBounds() {
    return bounds;
  }
}
```

- [ ] **Step 3: 创建贴纸模型 sticker.dart**

```dart
import 'package:flutter/material.dart';

class Sticker {
  final String id;
  final String emoji;  // 使用 emoji 作为贴纸
  final Offset position;
  final double scale;
  final double rotation;

  Sticker({
    required this.id,
    required this.emoji,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  Sticker copyWith({
    String? id,
    String? emoji,
    Offset? position,
    double? scale,
    double? rotation,
  }) {
    return Sticker(
      id: id ?? this.id,
      emoji: emoji ?? this.emoji,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }

  /// 获取贴纸的边界
  Rect getBounds() {
    const baseSize = 48.0;
    final size = baseSize * scale;
    return Rect.fromCenter(
      center: position,
      width: size,
      height: size,
    );
  }
}
```

- [ ] **Step 4: 创建画布状态模型 canvas_state.dart**

```dart
import 'stroke.dart';
import 'shape.dart';
import 'sticker.dart';

class CanvasState {
  final List<Stroke> strokes;
  final List<CanvasShape> shapes;
  final List<Sticker> stickers;
  final String? backgroundImage;

  CanvasState({
    this.strokes = const [],
    this.shapes = const [],
    this.stickers = const [],
    this.backgroundImage,
  });

  CanvasState copyWith({
    List<Stroke>? strokes,
    List<CanvasShape>? shapes,
    List<Sticker>? stickers,
    String? backgroundImage,
  }) {
    return CanvasState(
      strokes: strokes ?? this.strokes,
      shapes: shapes ?? this.shapes,
      stickers: stickers ?? this.stickers,
      backgroundImage: backgroundImage ?? this.backgroundImage,
    );
  }

  /// 检查画布是否为空
  bool get isEmpty =>
      strokes.isEmpty && shapes.isEmpty && stickers.isEmpty;

  /// 获取所有内容的边界
  Rect getContentBounds() {
    final allBounds = <Rect>[];

    for (final stroke in strokes) {
      allBounds.add(stroke.getBounds());
    }
    for (final shape in shapes) {
      allBounds.add(shape.getBounds());
    }
    for (final sticker in stickers) {
      allBounds.add(sticker.getBounds());
    }

    if (allBounds.isEmpty) return Rect.zero;

    double minX = allBounds.first.left;
    double maxX = allBounds.first.right;
    double minY = allBounds.first.top;
    double maxY = allBounds.first.bottom;

    for (final bounds in allBounds) {
      if (bounds.left < minX) minX = bounds.left;
      if (bounds.right > maxX) maxX = bounds.right;
      if (bounds.top < minY) minY = bounds.top;
      if (bounds.bottom > maxY) maxY = bounds.bottom;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}
```

- [ ] **Step 5: 提交**

```bash
git add lib/tools/canvas/models/
git commit -m "feat(canvas): add data models (Stroke, Shape, Sticker, CanvasState)"
```

---

### Task 3: 绘图服务

**Files:**
- Create: `lib/tools/canvas/services/drawing_service.dart`

- [ ] **Step 1: 创建绘图服务**

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/stroke.dart';
import '../models/shape.dart';
import '../models/sticker.dart';
import '../models/canvas_state.dart';

enum DrawMode {
  brush,
  shape,
  sticker,
  eraser,
}

class DrawingService extends ChangeNotifier {
  CanvasState _state = CanvasState();
  List<CanvasState> _undoStack = [];
  List<CanvasState> _redoStack = [];

  DrawMode _mode = DrawMode.brush;
  Color _currentColor = Colors.black;
  double _currentSize = 3.0;
  BrushType _brushType = BrushType.normal;
  ShapeType _shapeType = ShapeType.line;
  bool _shapeFilled = false;

  // 当前绘制的笔画
  Stroke? _currentStroke;
  Offset? _shapeStart;
  Rect? _currentShapeRect;

  // Getters
  CanvasState get state => _state;
  DrawMode get mode => _mode;
  Color get currentColor => _currentColor;
  double get currentSize => _currentSize;
  BrushType get brushType => _brushType;
  ShapeType get shapeType => _shapeType;
  bool get shapeFilled => _shapeFilled;
  Stroke? get currentStroke => _currentStroke;
  Rect? get currentShapeRect => _currentShapeRect;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  // 设置方法
  void setMode(DrawMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void setColor(Color color) {
    _currentColor = color;
    notifyListeners();
  }

  void setSize(double size) {
    _currentSize = size;
    notifyListeners();
  }

  void setBrushType(BrushType type) {
    _brushType = type;
    notifyListeners();
  }

  void setShapeType(ShapeType type) {
    _shapeType = type;
    notifyListeners();
  }

  void setShapeFilled(bool filled) {
    _shapeFilled = filled;
    notifyListeners();
  }

  // 保存当前状态到撤销栈
  void _saveState() {
    _undoStack.add(_state);
    _redoStack.clear();
    if (_undoStack.length > 50) {
      _undoStack.removeAt(0);
    }
  }

  // 笔画绘制
  void startStroke(Offset point, {double? pressure}) {
    if (_mode != DrawMode.brush && _mode != DrawMode.eraser) return;

    _currentStroke = Stroke(
      id: const Uuid().v4(),
      points: [point],
      pressures: pressure != null ? [pressure] : null,
      color: _mode == DrawMode.eraser ? Colors.white : _currentColor,
      size: _currentSize,
      brushType: _brushType,
      isEraser: _mode == DrawMode.eraser,
    );
    notifyListeners();
  }

  void addPoint(Offset point, {double? pressure}) {
    if (_currentStroke == null) return;

    _currentStroke = _currentStroke!.copyWith(
      points: [..._currentStroke!.points, point],
      pressures: _currentStroke!.pressures != null && pressure != null
          ? [..._currentStroke!.pressures!, pressure]
          : _currentStroke!.pressures,
    );
    notifyListeners();
  }

  void endStroke() {
    if (_currentStroke == null) return;

    _saveState();
    _state = _state.copyWith(
      strokes: [..._state.strokes, _currentStroke!],
    );
    _currentStroke = null;
    notifyListeners();
  }

  // 形状绘制
  void startShape(Offset point) {
    if (_mode != DrawMode.shape) return;
    _shapeStart = point;
    _currentShapeRect = Rect.fromPoints(point, point);
    notifyListeners();
  }

  void updateShape(Offset point) {
    if (_shapeStart == null) return;
    _currentShapeRect = Rect.fromPoints(_shapeStart!, point);
    notifyListeners();
  }

  void endShape() {
    if (_currentShapeRect == null || _shapeStart == null) return;

    _saveState();
    final shape = CanvasShape(
      id: const Uuid().v4(),
      type: _shapeType,
      bounds: _currentShapeRect!,
      color: _currentColor,
      strokeWidth: _currentSize,
      filled: _shapeFilled,
    );
    _state = _state.copyWith(
      shapes: [..._state.shapes, shape],
    );
    _shapeStart = null;
    _currentShapeRect = null;
    notifyListeners();
  }

  // 贴纸
  void addSticker(String emoji, Offset position) {
    _saveState();
    final sticker = Sticker(
      id: const Uuid().v4(),
      emoji: emoji,
      position: position,
    );
    _state = _state.copyWith(
      stickers: [..._state.stickers, sticker],
    );
    notifyListeners();
  }

  void updateSticker(String id, {Offset? position, double? scale, double? rotation}) {
    final index = _state.stickers.indexWhere((s) => s.id == id);
    if (index == -1) return;

    _saveState();
    final updated = _state.stickers[index].copyWith(
      position: position,
      scale: scale,
      rotation: rotation,
    );
    final newStickers = List<Sticker>.from(_state.stickers);
    newStickers[index] = updated;
    _state = _state.copyWith(stickers: newStickers);
    notifyListeners();
  }

  // 操作
  void undo() {
    if (!canUndo) return;
    _redoStack.add(_state);
    _state = _undoStack.removeLast();
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _undoStack.add(_state);
    _state = _redoStack.removeLast();
    notifyListeners();
  }

  void clear() {
    if (_state.isEmpty) return;
    _saveState();
    _state = CanvasState();
    notifyListeners();
  }

  void setBackgroundImage(String? path) {
    _saveState();
    _state = _state.copyWith(backgroundImage: path);
    notifyListeners();
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add lib/tools/canvas/services/drawing_service.dart
git commit -m "feat(canvas): add drawing service"
```

---

### Task 4: 导出服务

**Files:**
- Create: `lib/tools/canvas/services/export_service.dart`

- [ ] **Step 1: 创建导出服务**

```dart
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../models/canvas_state.dart';

class ExportService {
  final GlobalKey repaintKey = GlobalKey();

  /// 导出画布为图片数据
  Future<Uint8List?> exportToImage(CanvasState state) async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Export error: $e');
      return null;
    }
  }

  /// 保存到相册
  Future<bool> saveToGallery(Uint8List imageData) async {
    try {
      final result = await ImageGallerySaver.saveImage(imageData);
      return result['isSuccess'] == true;
    } catch (e) {
      debugPrint('Save to gallery error: $e');
      return false;
    }
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add lib/tools/canvas/services/export_service.dart
git commit -m "feat(canvas): add export service"
```

---

### Task 5: UI 组件

**Files:**
- Create: `lib/tools/canvas/widgets/color_picker.dart`
- Create: `lib/tools/canvas/widgets/brush_selector.dart`
- Create: `lib/tools/canvas/widgets/shape_selector.dart`
- Create: `lib/tools/canvas/widgets/sticker_panel.dart`
- Create: `lib/tools/canvas/widgets/size_slider.dart`

- [ ] **Step 1: 创建颜色选择器 color_picker.dart**

```dart
import 'package:flutter/material.dart';

class ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final void Function(Color) onColorSelected;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  static const _colors = [
    Colors.black,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _colors.map((color) {
        final isSelected = color.value == selectedColor.value;
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                width: isSelected ? 3 : 1,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
```

- [ ] **Step 2: 创建画笔选择器 brush_selector.dart**

```dart
import 'package:flutter/material.dart';
import '../models/stroke.dart';

class BrushSelector extends StatelessWidget {
  final BrushType selectedType;
  final void Function(BrushType) onTypeSelected;

  const BrushSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  static const _types = [
    (BrushType.normal, '普通', Icons.edit),
    (BrushType.marker, '马克', Icons.brush),
    (BrushType.highlighter, '荧光', Icons.highlight),
    (BrushType.pressure, '压感', Icons.gesture),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _types.map((item) {
        final (type, label, icon) = item;
        final isSelected = type == selectedType;
        return GestureDetector(
          onTap: () => onTypeSelected(type),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                Text(label, style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
```

- [ ] **Step 3: 创建形状选择器 shape_selector.dart**

```dart
import 'package:flutter/material.dart';
import '../models/shape.dart';

class ShapeSelector extends StatelessWidget {
  final ShapeType selectedType;
  final bool filled;
  final void Function(ShapeType) onTypeSelected;
  final void Function(bool) onFilledChanged;

  const ShapeSelector({
    super.key,
    required this.selectedType,
    required this.filled,
    required this.onTypeSelected,
    required this.onFilledChanged,
  });

  static const _types = [
    (ShapeType.line, '直线', Icons.show_chart),
    (ShapeType.rectangle, '矩形', Icons.rectangle_outlined),
    (ShapeType.circle, '圆形', Icons.circle_outlined),
    (ShapeType.triangle, '三角', Icons.change_history),
    (ShapeType.arrow, '箭头', Icons.arrow_forward),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ..._types.map((item) {
          final (type, _, icon) = item;
          final isSelected = type == selectedType;
          return IconButton(
            icon: Icon(icon),
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
            onPressed: () => onTypeSelected(type),
          );
        }),
        const SizedBox(width: 8),
        Row(
          children: [
            Checkbox(
              value: filled,
              onChanged: (v) => onFilledChanged(v ?? false),
            ),
            const Text('填充'),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: 创建贴纸面板 sticker_panel.dart**

```dart
import 'package:flutter/material.dart';

class StickerPanel extends StatelessWidget {
  final void Function(String) onStickerSelected;

  const StickerPanel({
    super.key,
    required this.onStickerSelected,
  });

  static const _stickers = [
    // 表情
    '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😊', '😍', '🥰',
    // 手势
    '👍', '👎', '👏', '🙏', '💪', '✌️', '🤞', '👆', '👇', '👈', '👉',
    // 符号
    '❤️', '💔', '💡', '⭐', '🌟', '✨', '💫', '🔥', '💯', '🎉', '🎊', '🎈', '🎁', '🏆',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(8),
      child: GridView.count(
        crossAxisCount: 10,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: _stickers.map((emoji) {
          return GestureDetector(
            onTap: () => onStickerSelected(emoji),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

- [ ] **Step 5: 创建粗细滑块 size_slider.dart**

```dart
import 'package:flutter/material.dart';

class SizeSlider extends StatelessWidget {
  final double value;
  final void Function(double) onChanged;

  const SizeSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('粗细'),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Slider(
            value: value,
            min: 1,
            max: 20,
            onChanged: onChanged,
          ),
        ),
        Text(value.toStringAsFixed(1)),
      ],
    );
  }
}
```

- [ ] **Step 6: 提交**

```bash
git add lib/tools/canvas/widgets/
git commit -m "feat(canvas): add UI components"
```

---

### Task 6: 画布组件

**Files:**
- Create: `lib/tools/canvas/widgets/canvas_widget.dart`

- [ ] **Step 1: 创建画布组件**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfect_freehand/perfect_freehand.dart' as freehand;
import '../models/stroke.dart';
import '../models/shape.dart';
import '../models/sticker.dart';
import '../models/canvas_state.dart';
import '../services/drawing_service.dart';

class CanvasWidget extends StatelessWidget {
  final DrawingService service;
  final GlobalKey repaintKey;

  const CanvasWidget({
    super.key,
    required this.service,
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: GestureDetector(
        onPanStart: (details) {
          if (service.mode == DrawMode.brush || service.mode == DrawMode.eraser) {
            // 尝试获取压力
            final pressure = _getPressure(details);
            service.startStroke(details.localPosition, pressure: pressure);
          } else if (service.mode == DrawMode.shape) {
            service.startShape(details.localPosition);
          }
        },
        onPanUpdate: (details) {
          if (service.mode == DrawMode.brush || service.mode == DrawMode.eraser) {
            final pressure = _getPressure(details);
            service.addPoint(details.localPosition, pressure: pressure);
          } else if (service.mode == DrawMode.shape) {
            service.updateShape(details.localPosition);
          }
        },
        onPanEnd: (_) {
          if (service.mode == DrawMode.brush || service.mode == DrawMode.eraser) {
            service.endStroke();
          } else if (service.mode == DrawMode.shape) {
            service.endShape();
          }
        },
        child: Container(
          color: Colors.white,
          child: CustomPaint(
            painter: _CanvasPainter(
              state: service.state,
              currentStroke: service.currentStroke,
              currentShapeRect: service.currentShapeRect,
              shapeType: service.shapeType,
              shapeFilled: service.shapeFilled,
              currentColor: service.currentColor,
              currentSize: service.currentSize,
            ),
          ),
        ),
      ),
    );
  }

  double? _getPressure(DragUpdateDetails details) {
    // 尝试获取触控笔压力
    // Flutter 不直接支持，需要使用平台通道
    return null;
  }
}

class _CanvasPainter extends CustomPainter {
  final CanvasState state;
  final Stroke? currentStroke;
  final Rect? currentShapeRect;
  final ShapeType shapeType;
  final bool shapeFilled;
  final Color currentColor;
  final double currentSize;

  _CanvasPainter({
    required this.state,
    this.currentStroke,
    this.currentShapeRect,
    required this.shapeType,
    required this.shapeFilled,
    required this.currentColor,
    required this.currentSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景图
    if (state.backgroundImage != null) {
      // TODO: 绘制背景图
    }

    // 绘制已保存的笔画
    for (final stroke in state.strokes) {
      _drawStroke(canvas, stroke);
    }

    // 绘制当前笔画
    if (currentStroke != null) {
      _drawStroke(canvas, currentStroke!);
    }

    // 绘制已保存的形状
    for (final shape in state.shapes) {
      _drawShape(canvas, shape);
    }

    // 绘制当前形状预览
    if (currentShapeRect != null) {
      _drawShapePreview(canvas, currentShapeRect!);
    }

    // 绘制贴纸
    for (final sticker in state.stickers) {
      _drawSticker(canvas, sticker);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.isEmpty) return;

    final points = stroke.points.map((p) => freehand.PointVector(p.dx, p.dy)).toList();

    final strokeOptions = freehand.StrokeOptions(
      size: stroke.size * 2,
      smoothing: 0.5,
      thinning: stroke.brushType == BrushType.pressure ? 0.7 : 0.0,
    );

    final outline = freehand.getStroke(points, options: strokeOptions);

    if (outline.isEmpty) return;

    final path = Path()..moveTo(outline[0].dx, outline[0].dy);
    for (int i = 1; i < outline.length; i++) {
      path.lineTo(outline[i].dx, outline[i].dy);
    }
    path.close();

    final paint = Paint()
      ..color = stroke.isEraser
          ? Colors.white
          : _getBrushColor(stroke.color, stroke.brushType)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  Color _getBrushColor(Color baseColor, BrushType type) {
    switch (type) {
      case BrushType.marker:
        return baseColor.withOpacity(0.5);
      case BrushType.highlighter:
        return baseColor.withOpacity(0.3);
      default:
        return baseColor;
    }
  }

  void _drawShape(Canvas canvas, CanvasShape shape) {
    final paint = Paint()
      ..color = shape.color
      ..style = shape.filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = shape.strokeWidth;

    canvas.save();
    canvas.translate(shape.bounds.center.dx, shape.bounds.center.dy);
    canvas.rotate(shape.rotation);
    canvas.translate(-shape.bounds.center.dx, -shape.bounds.center.dy);

    switch (shape.type) {
      case ShapeType.line:
        canvas.drawLine(
          Offset(shape.bounds.left, shape.bounds.top),
          Offset(shape.bounds.right, shape.bounds.bottom),
          paint,
        );
      case ShapeType.rectangle:
        canvas.drawRect(shape.bounds, paint);
      case ShapeType.circle:
        canvas.drawOval(shape.bounds, paint);
      case ShapeType.triangle:
        final path = Path()
          ..moveTo(shape.bounds.center.dx, shape.bounds.top)
          ..lineTo(shape.bounds.right, shape.bounds.bottom)
          ..lineTo(shape.bounds.left, shape.bounds.bottom)
          ..close();
        canvas.drawPath(path, paint);
      case ShapeType.arrow:
        _drawArrow(canvas, shape.bounds, paint);
    }

    canvas.restore();
  }

  void _drawShapePreview(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = currentColor
      ..style = shapeFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = currentSize;

    switch (shapeType) {
      case ShapeType.line:
        canvas.drawLine(rect.topLeft, rect.bottomRight, paint);
      case ShapeType.rectangle:
        canvas.drawRect(rect, paint);
      case ShapeType.circle:
        canvas.drawOval(rect, paint);
      case ShapeType.triangle:
        final path = Path()
          ..moveTo(rect.center.dx, rect.top)
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.left, rect.bottom)
          ..close();
        canvas.drawPath(path, paint);
      case ShapeType.arrow:
        _drawArrow(canvas, rect, paint);
    }
  }

  void _drawArrow(Canvas canvas, Rect rect, Paint paint) {
    final start = rect.centerLeft;
    final end = rect.centerRight;

    canvas.drawLine(start, end, paint);

    final arrowSize = 15.0;
    final angle = atan2(0, 1);

    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowSize * cos(angle - pi / 6),
        end.dy - arrowSize * sin(angle - pi / 6),
      )
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - arrowSize * cos(angle + pi / 6),
        end.dy - arrowSize * sin(angle + pi / 6),
      );

    canvas.drawPath(path, paint..style = PaintingStyle.stroke);
  }

  void _drawSticker(Canvas canvas, Sticker sticker) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: sticker.emoji,
        style: TextStyle(fontSize: 48 * sticker.scale),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(sticker.position.dx, sticker.position.dy);
    canvas.rotate(sticker.rotation);
    canvas.translate(
      -textPainter.width / 2,
      -textPainter.height / 2,
    );

    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CanvasPainter oldDelegate) {
    return state != oldDelegate.state ||
        currentStroke != oldDelegate.currentStroke ||
        currentShapeRect != oldDelegate.currentShapeRect;
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add lib/tools/canvas/widgets/canvas_widget.dart
git commit -m "feat(canvas): add canvas widget with drawing support"
```

---

### Task 7: 主页面

**Files:**
- Create: `lib/tools/canvas/canvas_page.dart`

- [ ] **Step 1: 创建主页面**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'services/drawing_service.dart';
import 'services/export_service.dart';
import 'widgets/canvas_widget.dart';
import 'widgets/color_picker.dart';
import 'widgets/brush_selector.dart';
import 'widgets/shape_selector.dart';
import 'widgets/sticker_panel.dart';
import 'widgets/size_slider.dart';
import 'models/stroke.dart';

class CanvasPage extends StatelessWidget {
  const CanvasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrawingService(),
      child: const _CanvasPageContent(),
    );
  }
}

class _CanvasPageContent extends StatelessWidget {
  const _CanvasPageContent();

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DrawingService>();
    final exportService = ExportService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('画板'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveImage(context, service, exportService),
          ),
        ],
      ),
      body: Column(
        children: [
          // 画布
          Expanded(
            child: CanvasWidget(
              service: service,
              repaintKey: exportService.repaintKey,
            ),
          ),
          // 工具栏
          _buildToolbar(context, service),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, DrawingService service) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 模式切换
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ModeButton(
                  icon: Icons.edit,
                  label: '画笔',
                  selected: service.mode == DrawMode.brush,
                  onTap: () => service.setMode(DrawMode.brush),
                ),
                _ModeButton(
                  icon: Icons.category,
                  label: '形状',
                  selected: service.mode == DrawMode.shape,
                  onTap: () => service.setMode(DrawMode.shape),
                ),
                _ModeButton(
                  icon: Icons.emoji_emotions,
                  label: '贴纸',
                  selected: service.mode == DrawMode.sticker,
                  onTap: () => _showStickerPanel(context, service),
                ),
                _ModeButton(
                  icon: Icons.cleaning_services,
                  label: '橡皮',
                  selected: service.mode == DrawMode.eraser,
                  onTap: () => service.setMode(DrawMode.eraser),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 属性调节
            if (service.mode == DrawMode.brush || service.mode == DrawMode.eraser) ...[
              ColorPicker(
                selectedColor: service.currentColor,
                onColorSelected: service.setColor,
              ),
              const SizedBox(height: 4),
              BrushSelector(
                selectedType: service.brushType,
                onTypeSelected: service.setBrushType,
              ),
              const SizedBox(height: 4),
              SizeSlider(
                value: service.currentSize,
                onChanged: service.setSize,
              ),
            ],
            if (service.mode == DrawMode.shape) ...[
              ColorPicker(
                selectedColor: service.currentColor,
                onColorSelected: service.setColor,
              ),
              const SizedBox(height: 4),
              ShapeSelector(
                selectedType: service.shapeType,
                filled: service.shapeFilled,
                onTypeSelected: service.setShapeType,
                onFilledChanged: service.setShapeFilled,
              ),
            ],
            const SizedBox(height: 8),
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: service.canUndo ? service.undo : null,
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: service.canRedo ? service.redo : null,
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () => _pickImage(context, service),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmClear(context, service),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStickerPanel(BuildContext context, DrawingService service) {
    showModalBottomSheet(
      context: context,
      builder: (context) => StickerPanel(
        onStickerSelected: (emoji) {
          Navigator.pop(context);
          // 在画布中心添加贴纸
          service.addSticker(emoji, Offset(200, 300));
        },
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, DrawingService service) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      service.setBackgroundImage(image.path);
    }
  }

  Future<void> _saveImage(
    BuildContext context,
    DrawingService service,
    ExportService exportService,
  ) async {
    final data = await exportService.exportToImage(service.state);
    if (data != null) {
      final success = await exportService.saveToGallery(data);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '已保存到相册' : '保存失败'),
          ),
        );
      }
    }
  }

  Future<void> _confirmClear(BuildContext context, DrawingService service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空画布'),
        content: const Text('确定要清空画布吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      service.clear();
    }
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? Theme.of(context).colorScheme.primary : null),
          Text(label, style: TextStyle(
            fontSize: 10,
            color: selected ? Theme.of(context).colorScheme.primary : null,
          )),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add lib/tools/canvas/canvas_page.dart
git commit -m "feat(canvas): add main page with toolbar"
```

---

### Task 8: ToolModule 和注册

**Files:**
- Create: `lib/tools/canvas/canvas_tool.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: 创建 ToolModule 实现**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'canvas_page.dart';

class CanvasTool implements ToolModule {
  @override
  String get id => 'canvas';

  @override
  String get name => '画板';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.brush;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 2;

  @override
  Widget buildPage(BuildContext context) {
    return const CanvasPage();
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

- [ ] **Step 2: 在 main.dart 中注册**

添加导入：
```dart
import 'tools/canvas/canvas_tool.dart';
```

添加注册：
```dart
ToolRegistry.register(CanvasTool());
```

- [ ] **Step 3: 提交**

```bash
git add lib/tools/canvas/canvas_tool.dart lib/main.dart
git commit -m "feat(canvas): register CanvasTool"
```

---

### Task 9: 验证运行

- [ ] **Step 1: 运行应用验证功能**

Run: `cd /home/nano/littlegrid/app && flutter run`

验证项：
1. 主页格子中显示"画板"图标
2. 点击进入画板页面
3. 自由绘画功能正常
4. 颜色选择器工作正常
5. 画笔类型切换正常
6. 画笔粗细调节正常
7. 橡皮擦功能正常
8. 形状绘制正常
9. 贴纸添加正常
10. 撤销/重做功能正常
11. 导入背景图功能正常
12. 保存到相册功能正常

- [ ] **Step 2: 最终提交**

```bash
git add -A
git commit -m "feat(canvas): complete drawing board feature"
```