import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'clock_page.dart';

class ClockTool implements ToolModule {
  @override
  String get id => 'clock';

  @override
  String get name => '全屏时钟';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.access_time;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const ClockPage();
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
