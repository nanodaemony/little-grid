// app/lib/tools/bookshelf/widgets/tag_selector.dart

import 'package:flutter/material.dart';
import '../models/tag.dart';

class TagSelector extends StatelessWidget {
  final List<Tag> availableTags;
  final List<String> selectedTags;
  final ValueChanged<List<String>> onSelectedTagsChanged;
  final bool allowCreate;

  const TagSelector({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onSelectedTagsChanged,
    this.allowCreate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '标签',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (availableTags.isEmpty)
          _buildEmptyState()
        else
          _buildTagChips(context),
        if (allowCreate) ...[
          const SizedBox(height: 8),
          _buildAddTagButton(context),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Text(
        '暂无标签，可以添加新标签',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  Widget _buildTagChips(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primaryContainer;
    final checkColor = theme.colorScheme.primary;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableTags.map((tag) {
        final isSelected = selectedTags.contains(tag.name);
        return FilterChip(
          label: Text(tag.name),
          selected: isSelected,
          onSelected: (_) {
            final newSelection = List<String>.from(selectedTags);
            if (isSelected) {
              newSelection.remove(tag.name);
            } else {
              newSelection.add(tag.name);
            }
            onSelectedTagsChanged(newSelection);
          },
          selectedColor: primaryColor,
          checkmarkColor: checkColor,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        );
      }).toList(),
    );
  }

  Widget _buildAddTagButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showAddTagDialog(context),
      icon: const Icon(Icons.add, size: 18),
      label: const Text('添加标签'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _showAddTagDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('添加标签'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入标签名称',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.none,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(dialogContext);
                _handleTagCreated(name, context);
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _handleTagCreated(String tagName, BuildContext context) {
    // 检查标签是否已存在
    final exists = availableTags.any((tag) => tag.name.toLowerCase() == tagName.toLowerCase());
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('标签已存在')),
      );
      return;
    }

    // 添加到选中列表
    final newSelection = List<String>.from(selectedTags);
    newSelection.add(tagName);
    onSelectedTagsChanged(newSelection);
  }
}
