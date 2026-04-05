import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'anniversary_page.dart';

class AnniversaryTool implements ToolModule {
  @override
  String get id => 'anniversary';

  @override
  String get name => '纪念日';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.favorite;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 2;

  @override
  Widget buildPage(BuildContext context) {
    return const AnniversaryPage();
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
