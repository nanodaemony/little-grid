// app/lib/tools/big_wheel/pages/collection_edit_page.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/wheel_collection.dart';
import '../services/big_wheel_service.dart';
import 'option_list_page.dart';

class CollectionEditPage extends StatefulWidget {
  final WheelCollection? collection;

  const CollectionEditPage({super.key, this.collection});

  @override
  State<CollectionEditPage> createState() => _CollectionEditPageState();
}

class _CollectionEditPageState extends State<CollectionEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();

  IconType _iconType = IconType.emoji;
  bool _isSaving = false;

  bool get _isEditing => widget.collection != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.collection!.name;
      _iconController.text = widget.collection!.icon;
      _iconType = widget.collection!.iconType;
    } else {
      _iconController.text = '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final collection = WheelCollection(
      id: widget.collection?.id,
      name: _nameController.text.trim(),
      iconType: _iconType,
      icon: _iconController.text.trim(),
      isPreset: widget.collection?.isPreset ?? false,
      sortOrder: widget.collection?.sortOrder ?? 0,
      createdAt: widget.collection?.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      await BigWheelService.saveCollection(collection);

      setState(() => _isSaving = false);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    }
  }

  Future<void> _navigateToOptions() async {
    if (widget.collection?.id == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OptionListPage(collection: widget.collection!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑集合' : '新建集合'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPreview(),
            const SizedBox(height: 24),
            _buildIconSelector(),
            const SizedBox(height: 16),
            _buildNameField(),
            if (_isEditing) ...[
              const SizedBox(height: 24),
              _buildManageOptionsButton(),
            ],
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                _iconController.text.isEmpty ? '?' : _iconController.text,
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '预览',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '图标类型',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<IconType>(
          segments: const [
            ButtonSegment(
              value: IconType.emoji,
              label: Text('Emoji'),
              icon: Icon(Icons.emoji_emotions_outlined),
            ),
            ButtonSegment(
              value: IconType.material,
              label: Text('Material'),
              icon: Icon(Icons.font_download_outlined),
            ),
          ],
          selected: {_iconType},
          onSelectionChanged: (Set<IconType> newSelection) {
            setState(() {
              _iconType = newSelection.first;
              if (_iconType == IconType.material) {
                // Default material icon if empty
                if (_iconController.text.isEmpty ||
                    _iconController.text.length > 2) {
                  _iconController.text = 'casino';
                }
              } else {
                // Default emoji if empty or looks like material icon
                if (_iconController.text.isEmpty ||
                    _iconController.text.length <= 2) {
                  _iconController.text = '';
                }
              }
            });
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _iconController,
          decoration: InputDecoration(
            labelText: _iconType == IconType.emoji ? '图标 (Emoji)' : '图标名称',
            hintText: _iconType == IconType.emoji ? '例如: ' : '例如: casino',
            prefixIcon: _iconType == IconType.material
                ? const Icon(Icons.font_download_outlined)
                : const Icon(Icons.emoji_emotions_outlined),
            border: const OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return _iconType == IconType.emoji
                  ? '请输入Emoji图标'
                  : '请输入Material图标名称';
            }
            return null;
          },
        ),
        if (_iconType == IconType.material) ...[
          const SizedBox(height: 8),
          Text(
            '提示: 输入Material Design图标名称，如 "casino", "sports", "restaurant"',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: '集合名称',
        hintText: '输入集合名称',
        prefixIcon: Icon(Icons.folder_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入集合名称';
        }
        return null;
      },
    );
  }

  Widget _buildManageOptionsButton() {
    return OutlinedButton.icon(
      onPressed: _navigateToOptions,
      icon: const Icon(Icons.tune),
      label: const Text('管理选项'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _isSaving ? null : _save,
      icon: _isSaving
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save),
      label: Text(_isEditing ? '保存' : '创建'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
