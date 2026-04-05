import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
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
      await Gal.putImageBytes(imageData);
      return true;
    } catch (e) {
      debugPrint('Save to gallery error: $e');
      return false;
    }
  }
}