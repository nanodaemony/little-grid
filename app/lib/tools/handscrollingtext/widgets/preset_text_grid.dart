import 'package:flutter/material.dart';
import '../models/danmaku_models.dart';

class PresetTextGrid extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onTextSelected;

  const PresetTextGrid({
    super.key,
    required this.selectedCategory,
    required this.onTextSelected,
  });

  @override
  Widget build(BuildContext context) {
    final filteredTexts = selectedCategory == '全部'
        ? presetTexts
        : presetTexts.where((p) => p.category == selectedCategory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分类标签
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = category == selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) => onTextSelected('__category__$category'),
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        // 预设文案网格
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: filteredTexts.map((preset) {
            return ActionChip(
              label: Text(preset.text),
              onPressed: () => onTextSelected(preset.text),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            );
          }).toList(),
        ),
      ],
    );
  }
}
