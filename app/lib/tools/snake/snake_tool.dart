import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'snake_page.dart';

class SnakeTool implements ToolModule {
  @override
  String get id => 'snake';

  @override
  String get name => '贪吃蛇';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.videogame_asset;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const SnakePage();
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