// app/lib/tools/bookshelf/pages/add_item_dialog.dart

import 'package:flutter/material.dart';
import 'package:littlegrid/core/services/usage_service.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../services/bookshelf_api.dart';

// 快速添加对话框
class AddItemDialog extends StatefulWidget {
  final Category category;
  final void Function(Item) onItemAdded;

  const AddItemDialog({
    super.key,
    required this.category,
    required this.onItemAdded,
  });

  @override
  State<AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _summaryController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    UsageService.recordEnter('bookshelf_add_item');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _coverUrlController.dispose();
    _summaryController.dispose();
    UsageService.recordExit('bookshelf_add_item');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('快速添加条目'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '分类：${widget.category.name}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '标题 *',
                  hintText: '例如：三体、星际穿越',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入标题';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _coverUrlController,
                decoration: const InputDecoration(
                  labelText: '封面图片 URL',
                  hintText: '选择后可编辑封面',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _summaryController,
                decoration: const InputDecoration(
                  labelText: '一句话简介',
                  hintText: '简要描述内容',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: _isLoading ? null : _addItem,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('添加'),
        ),
      ],
    );
  }

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 如果没有封面URL，使用默认封面
      final coverUrl = _coverUrlController.text.trim().isEmpty
          ? 'https://via.placeholder.com/300x400?text=${Uri.encodeComponent(_titleController.text.trim())}'
          : _coverUrlController.text.trim();

      final newItem = await BookshelfApi.createItem(
        categoryId: widget.category.id,
        title: _titleController.text.trim(),
        coverUrl: coverUrl,
        summary: _summaryController.text.trim().isEmpty
            ? null
            : _summaryController.text.trim(),
      );

      setState(() => _isLoading = false);
      widget.onItemAdded(newItem);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('添加成功，可以继续编辑详情')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('添加失败: $e')),
        );
      }
    }
  }
}

// 搜索对话框（用于搜索豆瓣等）
class SearchItemDialog extends StatefulWidget {
  final String query;
  final Function(Map<String, dynamic> selectedResult) onResultSelected;

  const SearchItemDialog({
    super.key,
    required this.query,
    required this.onResultSelected,
  });

  @override
  State<SearchItemDialog> createState() => _SearchItemDialogState();
}

class _SearchItemDialogState extends State<SearchItemDialog> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _results = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _results = [];
    });

    try {
      // TODO: 集成豆瓣API搜索
      // 这里暂时返回示例数据
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isLoading = false;
        // 示例数据
        _results = [
          {
            'title': widget.query,
            'cover': 'https://via.placeholder.com/200x300?text=Cover',
            'author': '示例作者',
            'summary': '示例简介',
            'rating': 8.0,
          },
        ];
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '搜索失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('搜索"${widget.query}"'),
      content: SizedBox(
        width: 400,
        height: 400,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage, textAlign: TextAlign.center),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('未找到相关结果'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        return _buildResultItem(result);
      },
    );
  }

  Widget _buildResultItem(Map<String, dynamic> result) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          result['cover'] ?? '',
          width: 50,
          height: 70,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 50,
              height: 70,
              color: Colors.grey.shade300,
              child: const Icon(Icons.image_not_supported, size: 24),
            );
          },
        ),
      ),
      title: Text(result['title'] ?? '未知'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (result['author'] != null) Text(result['author']),
          if (result['summary'] != null)
            Text(
              result['summary'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
        ],
      ),
      trailing: result['rating'] != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                Text(
                  result['rating'].toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            )
          : null,
      onTap: () {
        widget.onResultSelected(result);
        Navigator.pop(context);
      },
    );
  }
}
