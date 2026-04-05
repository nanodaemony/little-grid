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