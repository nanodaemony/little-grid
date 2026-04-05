import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'rmbconvertor_page.dart';

class RmbConvertorTool implements ToolModule {
  @override
  String get id => 'rmbconvertor';

  @override
  String get name => '人民币大写';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.currency_yen;

  @override
  ToolCategory get category => ToolCategory.calc;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const RmbConvertorPage();
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
