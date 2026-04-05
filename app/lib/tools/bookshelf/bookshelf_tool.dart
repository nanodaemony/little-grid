// app/lib/tools/bookshelf/bookshelf_tool.dart

import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'bookshelf_page.dart';

class BookshelfTool implements ToolModule {
  @override
  String get id => 'bookshelf';

  @override
  String get name => '书架';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.menu_book;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const BookshelfPage();
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
