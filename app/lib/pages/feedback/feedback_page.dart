import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'feedback_service.dart';
import '../../core/ui/app_colors.dart';
import '../../core/services/image_upload_service.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String _selectedType = 'SUGGESTION';
  List<File> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      setState(() {}); // 触发重绘以更新字数
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages
            .addAll(images.map((xFile) => File(xFile.path)).toList());
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 先上传所有图片
      List<String>? screenshotUrls;
      if (_selectedImages.isNotEmpty) {
        screenshotUrls = await ImageUploadService.uploadImages(
          _selectedImages,
          'feedback',
        );
      }

      // 再提交反馈
      await FeedbackService.submitFeedback(
        type: _selectedType,
        description: _descriptionController.text.trim(),
        screenshots: screenshotUrls,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('反馈提交成功，感谢您的建议！'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('提交失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('反馈建议')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 卡片1: 反馈类型
            _buildTypeCard(),
            const SizedBox(height: 12),
            // 卡片2: 详细描述
            _buildDescriptionCard(),
            const SizedBox(height: 12),
            // 卡片3: 截图上传
            _buildImageCard(),
            const SizedBox(height: 24),
            // 提交按钮
            _buildSubmitButton(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget content,
    EdgeInsets? contentPadding,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          Padding(
            padding: contentPadding ?? const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard() {
    return _buildSectionCard(
      title: '反馈类型',
      content: Row(
        children: [
          _typeCard(
            type: 'SUGGESTION',
            label: '功能建议',
            icon: Icons.lightbulb_outline,
            isSelected: _selectedType == 'SUGGESTION',
            onTap: () => setState(() => _selectedType = 'SUGGESTION'),
          ),
          const SizedBox(width: 12),
          _typeCard(
            type: 'ISSUE',
            label: '问题反馈',
            icon: Icons.bug_report_outlined,
            isSelected: _selectedType == 'ISSUE',
            onTap: () => setState(() => _selectedType = 'ISSUE'),
          ),
        ],
      ),
    );
  }

  Widget _typeCard({
    required String type,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryLight.withValues(alpha: 0.3)
                : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return _buildSectionCard(
      title: '详细描述',
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '请详细描述您遇到的问题或建议，最多500字',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextFormField(
              controller: _descriptionController,
              maxLines: 6,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: '请输入反馈内容...',
                border: InputBorder.none,
                counterText: '', // 隐藏默认计数器
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintStyle:
                    TextStyle(color: AppColors.textTertiary, fontSize: 14),
              ),
              style:
                  const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入反馈内容';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_descriptionController.text.length}/500',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '问题截图（可选）',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                if (_selectedImages.isNotEmpty)
                  Text(
                    '${_selectedImages.length}/10',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_selectedImages.isEmpty)
                  _buildEmptyImagePicker()
                else
                  _buildImageGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyImagePicker() {
    return InkWell(
      onTap: _pickImages,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 40,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 8),
            Text(
              '点击添加截图',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    final itemCount =
        _selectedImages.length + (_selectedImages.length < 10 ? 1 : 0);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < _selectedImages.length) {
          return _buildImageItem(index);
        } else {
          return _buildAddMoreButton();
        }
      },
    );
  }

  Widget _buildImageItem(int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            _selectedImages[index],
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMoreButton() {
    return InkWell(
      onTap: _pickImages,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 28,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 4),
            Text(
              '添加',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '提交反馈',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }
}
