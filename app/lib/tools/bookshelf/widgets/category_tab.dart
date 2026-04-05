// app/lib/tools/bookshelf/widgets/category_tab.dart

import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryTab extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category> onCategorySelected;
  final VoidCallback onManageCategories;
  final bool isLoading;

  const CategoryTab({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onManageCategories,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('加载中...', style: TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    if (categories.isEmpty) {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text(
              '暂无分类',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onManageCategories,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('添加', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == categories.length) {
            // 添加按钮
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  onPressed: onManageCategories,
                  icon: const Icon(Icons.add, size: 20),
                  tooltip: '管理分类',
                ),
              ),
            );
          }

          final category = categories[index];
          final isSelected = selectedCategory?.id == category.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _CategoryChip(
              category: category,
              isSelected: isSelected,
              onTap: () => onCategorySelected(category),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        category.name,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}
