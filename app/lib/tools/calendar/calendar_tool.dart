import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'calendar_page.dart';

class CalendarTool implements ToolModule {
  @override
  String get id => 'calendar';

  @override
  String get name => '日历';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.calendar_today;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 2;

  @override
  Widget buildPage(BuildContext context) {
    return const CalendarPage();
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