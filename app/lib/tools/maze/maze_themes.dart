import 'package:flutter/material.dart';
import 'maze_models.dart';

/// 主题管理
class MazeThemes {
  /// 获取所有可用主题
  static List<(MazeTheme, String)> get allThemes => [
        (MazeTheme.defaultTheme, '默认'),
        (MazeTheme.classic, '经典'),
        (MazeTheme.dark, '深色'),
        (MazeTheme.fresh, '清新'),
      ];

  /// 主题选择器弹窗
  static void showThemeSelector(
    BuildContext context, {
    required MazeTheme currentTheme,
    required Function(MazeTheme) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 顶部指示器
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 标题
            Text(
              '选择主题',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // 主题列表
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: allThemes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final (theme, name) = allThemes[index];
                  final themeData = MazeThemeData.of(theme);
                  final isSelected = theme == currentTheme;

                  return _ThemeOption(
                    theme: theme,
                    name: name,
                    themeData: themeData,
                    isSelected: isSelected,
                    onTap: () {
                      onSelected(theme);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 主题选项
class _ThemeOption extends StatelessWidget {
  final MazeTheme theme;
  final String name;
  final MazeThemeData themeData;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.theme,
    required this.name,
    required this.themeData,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            // 主题预览
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: themeData.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: themeData.wallColor, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: themeData.playerColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 名称
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
              ),
            ),
            // 选中标记
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}
