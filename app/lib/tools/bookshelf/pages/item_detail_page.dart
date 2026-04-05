// app/lib/tools/bookshelf/pages/item_detail_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:littlegrid/core/services/image_upload_service.dart';
import 'package:littlegrid/core/services/usage_service.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../models/tag.dart';
import '../services/bookshelf_api.dart';
import '../widgets/date_picker_field.dart';
import '../widgets/rating_widget.dart';
import '../widgets/tag_selector.dart';

class ItemDetailPage extends StatefulWidget {
  final Item? item;
  final Category? category;
  final List<Category> categories;
  final List<Tag> tags;
  final void Function(Item?) onItemSaved;

  const ItemDetailPage({
    super.key,
    this.item,
    required this.category,
    required this.categories,
    required this.tags,
    required this.onItemSaved,
  });

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _summaryController = TextEditingController();
  final _authorController = TextEditingController();
  final _reviewController = TextEditingController();
  final _progressController = TextEditingController();

  Category? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _finishDate;
  int? _rating;
  bool _isRecommended = false;
  List<String> _selectedTags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    UsageService.recordEnter('bookshelf_item_detail');
    _selectedCategory = widget.category;

    if (widget.item != null) {
      _initFromItem(widget.item!);
    }
  }

  void _initFromItem(Item item) {
    _titleController.text = item.title;
    _coverUrlController.text = item.coverUrl;
    _summaryController.text = item.summary ?? '';
    _authorController.text = item.author ?? '';
    _reviewController.text = item.review ?? '';
    _progressController.text = item.progress ?? '';
    _startDate = item.startDate;
    _endDate = item.endDate;
    _finishDate = item.finishDate;
    _rating = item.rating;
    _isRecommended = item.isRecommended ?? false;
    _selectedTags = item.tags ?? [];

    // 从categories中找到对应的category
    _selectedCategory = widget.categories.firstWhere(
      (c) => c.id == item.categoryId,
      orElse: () => widget.category!,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _coverUrlController.dispose();
    _summaryController.dispose();
    _authorController.dispose();
    _reviewController.dispose();
    _progressController.dispose();
    UsageService.recordExit('bookshelf_item_detail');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item != null ? '编辑条目' : '添加条目'),
        actions: [
          if (widget.item != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteItem,
              tooltip: '删除',
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveItem,
            tooltip: '保存',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCoverSection(),
                  const SizedBox(height: 16),
                  _buildBasicInfoSection(),
                  const SizedBox(height: 16),
                  _buildDateSection(),
                  const SizedBox(height: 16),
                  _buildMetaSection(),
                  const SizedBox(height: 16),
                  _buildReviewSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildCoverSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '封面图片',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _coverUrlController,
                decoration: const InputDecoration(
                  hintText: '封面图片 URL',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入封面图片 URL';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.photo_library),
              onPressed: _pickImage,
              tooltip: '选择图片',
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_coverUrlController.text.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _coverUrlController.text,
              height: 150,
              width: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 150,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.broken_image, size: 32),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 分类选择
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: '分类 *',
                border: OutlineInputBorder(),
              ),
              items: widget.categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
              validator: (value) {
                if (value == null) {
                  return '请选择分类';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // 标题
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '标题 *',
                hintText: '例如：三体、星际穿越',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入标题';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // 作者/导演
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: '作者/导演',
                hintText: '例如：刘慈欣、克里斯托弗·诺兰',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // 简介
            TextFormField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: '一句话简介',
                hintText: '简要描述内容',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            // 标签
            TagSelector(
              availableTags: widget.tags,
              selectedTags: _selectedTags,
              onSelectedTagsChanged: (tags) {
                setState(() => _selectedTags = tags);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DatePickerField(
              label: '开始日期',
              selectedDate: _startDate,
              onDateSelected: (date) {
                setState(() => _startDate = date);
              },
              hintText: '何时开始',
            ),
            const SizedBox(height: 16),
            DatePickerField(
              label: '结束日期',
              selectedDate: _endDate,
              onDateSelected: (date) {
                setState(() => _endDate = date);
              },
              hintText: '何时结束（未完成）',
            ),
            const SizedBox(height: 16),
            DatePickerField(
              label: '完成日期',
              selectedDate: _finishDate,
              onDateSelected: (date) {
                setState(() => _finishDate = date);
              },
              hintText: '何时完成',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 评分
            const Text(
              '评分',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            RatingWidget(
              rating: _rating,
              onRatingChanged: (value) {
                setState(() => _rating = value);
              },
            ),
            const SizedBox(height: 16),
            // 观看进度
            TextFormField(
              controller: _progressController,
              decoration: const InputDecoration(
                labelText: '观看进度',
                hintText: '例如：第 3 集、45 页、5 小时',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // 推荐
            SwitchListTile(
              title: const Text('推荐'),
              subtitle: const Text('标记为推荐内容'),
              value: _isRecommended,
              onChanged: (value) {
                setState(() => _isRecommended = value);
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '详细评价',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _reviewController,
              decoration: const InputDecoration(
                hintText: '写下你的想法和评价...',
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);

    if (result != null) {
      try {
        setState(() => _isLoading = true);
        final url = await ImageUploadService.uploadImage(
          result,
          'bookshelf',
        );
        setState(() {
          _coverUrlController.text = url;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('上传失败: $e')),
          );
        }
      }
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final itemData = {
        'categoryId': _selectedCategory!.id,
        'title': _titleController.text.trim(),
        'coverUrl': _coverUrlController.text.trim(),
        if (_summaryController.text.trim().isNotEmpty)
          'summary': _summaryController.text.trim(),
        if (_authorController.text.trim().isNotEmpty)
          'author': _authorController.text.trim(),
        if (_startDate != null) 'startDate': _startDate,
        if (_endDate != null) 'endDate': _endDate,
        if (_finishDate != null) 'finishDate': _finishDate,
        if (_rating != null) 'rating': _rating,
        if (_progressController.text.trim().isNotEmpty)
          'progress': _progressController.text.trim(),
        if (_reviewController.text.trim().isNotEmpty)
          'review': _reviewController.text.trim(),
        'isRecommended': _isRecommended,
        if (_selectedTags.isNotEmpty) 'tags': _selectedTags,
      };

      Item savedItem;

      if (widget.item != null) {
        // 更新
        savedItem = await BookshelfApi.updateItem(
          widget.item!.id,
          categoryId: itemData['categoryId'] as int,
          title: itemData['title'] as String,
          coverUrl: itemData['coverUrl'] as String,
          summary: itemData['summary'] as String?,
          startDate: itemData['startDate'] as DateTime?,
          endDate: itemData['endDate'] as DateTime?,
          finishDate: itemData['finishDate'] as DateTime?,
          author: itemData['author'] as String?,
          rating: itemData['rating'] as int?,
          review: itemData['review'] as String?,
          progress: itemData['progress'] as String?,
          isRecommended: itemData['isRecommended'] as bool?,
          tags: itemData['tags'] as List<String>?,
        );
      } else {
        // 创建
        savedItem = await BookshelfApi.createItem(
          categoryId: itemData['categoryId'] as int,
          title: itemData['title'] as String,
          coverUrl: itemData['coverUrl'] as String,
          summary: itemData['summary'] as String?,
          startDate: itemData['startDate'] as DateTime?,
          endDate: itemData['endDate'] as DateTime?,
          finishDate: itemData['finishDate'] as DateTime?,
          author: itemData['author'] as String?,
          rating: itemData['rating'] as int?,
          review: itemData['review'] as String?,
          progress: itemData['progress'] as String?,
          isRecommended: itemData['isRecommended'] as bool?,
          tags: itemData['tags'] as List<String>?,
        );
      }

      setState(() => _isLoading = false);
      widget.onItemSaved(savedItem);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存成功')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    }
  }

  Future<void> _deleteItem() async {
    if (widget.item == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个条目吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      await BookshelfApi.deleteItem(widget.item!.id);
      setState(() => _isLoading = false);
      widget.onItemSaved(null);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('删除成功')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('删除失败: $e')),
        );
      }
    }
  }
}
