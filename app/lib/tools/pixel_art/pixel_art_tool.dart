import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'pixel_art_page.dart';

class PixelArtTool implements ToolModule {
  @override
  String get id => 'pixel_art';

  @override
  String get name => '像素画生成器';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.palette;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) => const PixelArtPage();

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
