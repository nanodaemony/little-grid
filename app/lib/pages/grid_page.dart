import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/tool_config.dart';
import '../core/services/tool_registry.dart';
import '../core/services/usage_service.dart';
import '../core/ui/app_colors.dart';
import '../providers/app_provider.dart';
import '../widgets/app_drawer.dart';

class GridPage extends StatelessWidget {
  const GridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text('小方格'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 搜索
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tools = provider.getSortedTools();

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 120,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final config = tools[index];
                      return _ToolGridItem(config: config);
                    },
                    childCount: tools.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ToolGridItem extends StatelessWidget {
  final ToolConfig config;

  const _ToolGridItem({required this.config});

  @override
  Widget build(BuildContext context) {
    final tool = ToolRegistry.get(config.id);
    if (tool == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _openTool(context, tool),
      onLongPress: () => _showOptions(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              tool.icon,
              size: 36,
              color: _getCategoryColor(tool.category),
            ),
            const SizedBox(height: 8),
            Text(
              tool.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (config.isPinned)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.push_pin,
                  size: 12,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openTool(BuildContext context, ToolModule tool) {
    UsageService.recordEnter(tool.id);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => tool.buildPage(context)),
    ).then((_) {
      UsageService.recordExit(tool.id);
      if (context.mounted) {
        context.read<AppProvider>().recordToolUse(tool.id);
      }
    });
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                config.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              ),
              title: Text(config.isPinned ? '取消置顶' : '置顶'),
              onTap: () {
                context.read<AppProvider>().togglePin(config.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(ToolCategory category) {
    switch (category) {
      case ToolCategory.life:
        return AppColors.categoryLife;
      case ToolCategory.game:
        return AppColors.categoryGame;
      case ToolCategory.calc:
        return AppColors.categoryCalc;
    }
  }
}
