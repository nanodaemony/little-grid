import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'qrcode_page.dart';

class QRCodeTool implements ToolModule {
  @override
  String get id => 'qrcode';

  @override
  String get name => '二维码生成器';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.qr_code_2;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const QRCodePage();
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