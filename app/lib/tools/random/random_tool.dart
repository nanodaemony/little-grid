import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'random_page.dart';

class RandomTool implements ToolModule {
  @override
  String get id => 'random';

  @override
  String get name => '随机数';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.shuffle;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const RandomPage();
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
