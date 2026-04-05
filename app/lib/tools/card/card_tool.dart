import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'card_page.dart';

class CardTool implements ToolModule {
  @override
  String get id => 'card';

  @override
  String get name => '翻扑克牌';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.style;

  @override
  ToolCategory get category => ToolCategory.game;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const CardPage();
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
