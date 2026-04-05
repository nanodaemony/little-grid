// app/lib/tools/big_wheel/pages/option_edit_page.dart

import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../models/wheel_collection.dart';
import '../models/wheel_option.dart';
import '../services/big_wheel_service.dart';

class OptionEditPage extends StatefulWidget {
  final int collectionId;
  final WheelOption? option;

  const OptionEditPage({
    super.key,
    required this.collectionId,
    this.option,
  });

  @override
  State<OptionEditPage> createState() => _OptionEditPageState();
}

class _OptionEditPageState extends State<OptionEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _iconController = TextEditingController();
  final _weightController = TextEditingController();

  IconType _iconType = IconType.emoji;
  bool _hasIcon = false;
  bool _isSaving = false;

  bool get _isEditing => widget.option != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameController.text = widget.option!.name;
      _iconController.text = widget.option!.icon ?? '';
      _weightController.text = widget.option!.weight.toString();
      _iconType = widget.option!.iconType;
      _hasIcon = widget.option!.icon != null && widget.option!.icon!.isNotEmpty;
    } else {
      _weightController.text = '1.0';
      _hasIcon = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _iconController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final weight = double.tryParse(_weightController.text) ?? 1.0;

    final option = WheelOption(
      id: widget.option?.id,
      collectionId: widget.collectionId,
      name: _nameController.text.trim(),
      iconType: _hasIcon ? _iconType : IconType.emoji,
      icon: _hasIcon ? _iconController.text.trim() : null,
      weight: weight,
      color: widget.option?.color,
      sortOrder: widget.option?.sortOrder ?? 0,
      createdAt: widget.option?.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      await BigWheelService.saveOption(option);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑选项' : '新建选项'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildNameField(),
            const SizedBox(height: 24),
            _buildIconSection(),
            const SizedBox(height: 24),
            _buildWeightField(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: '选项名称',
        hintText: '输入选项名称',
        prefixIcon: Icon(Icons.label_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入选项名称';
        }
        return null;
      },
    );
  }

  Widget _buildIconSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '图标（可选）',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: _hasIcon,
              onChanged: (value) {
                setState(() {
                  _hasIcon = value;
                  if (value && _iconController.text.isEmpty) {
                    _iconController.text = '';
                  }
                });
              },
            ),
          ],
        ),
        if (_hasIcon) ...[
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
                  if (_iconController.text.isEmpty ||
                      _iconController.text.length > 2) {
                    _iconController.text = 'star';
                  }
                } else {
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
              hintText: _iconType == IconType.emoji ? '例如: ' : '例如: star',
              prefixIcon: _iconType == IconType.material
                  ? const Icon(Icons.font_download_outlined)
                  : const Icon(Icons.emoji_emotions_outlined),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (_hasIcon && (value == null || value.trim().isEmpty)) {
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
              '提示: 输入Material Design图标名称，如 "star", "favorite", "home"',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildWeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _weightController,
          decoration: const InputDecoration(
            labelText: '权重',
            hintText: '1.0',
            prefixIcon: Icon(Icons.scale_outlined),
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请输入权重';
            }
            final weight = double.tryParse(value);
            if (weight == null || weight <= 0) {
              return '权重必须大于0';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '权重说明：默认值为1.0。权重越大，该选项在转盘中的占比越大。例如，权重为2.0的选项出现概率是权重为1.0的两倍。',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
