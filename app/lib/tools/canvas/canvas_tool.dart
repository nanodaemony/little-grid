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