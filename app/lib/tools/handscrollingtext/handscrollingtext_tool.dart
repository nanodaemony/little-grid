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
  int get gridSize => 1;

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
