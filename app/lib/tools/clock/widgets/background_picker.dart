import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import '../models/clock_config.dart';
import '../models/clock_enums.dart';

class BackgroundPicker extends StatelessWidget {
  final ClockConfig config;
  final ValueChanged<ClockConfig> onConfigChanged;

  const BackgroundPicker({
    super.key,
    required this.config,
    required this.onConfigChanged,
  });

  static const List<Color> presetColors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('背景类型', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SegmentedButton<BackgroundType>(
          segments: const [
            ButtonSegment(
              value: BackgroundType.color,
              label: Text('纯色'),
            ),
            ButtonSegment(
              value: BackgroundType.gradient,
              label: Text('渐变'),
            ),
            ButtonSegment(
              value: BackgroundType.image,
              label: Text('图片'),
            ),
          ],
          selected: {config.backgroundType},
          onSelectionChanged: (value) {
            onConfigChanged(config.copyWith(backgroundType: value.first));
          },
        ),
        const SizedBox(height: 16),
        _buildBackgroundOptions(context),
      ],
    );
  }

  Widget _buildBackgroundOptions(BuildContext context) {
    switch (config.backgroundType) {
      case BackgroundType.color:
        return _buildColorPicker(context);
      case BackgroundType.gradient:
        return _buildGradientPicker(context);
      case BackgroundType.image:
        return _buildImagePicker(context);
    }
  }

  Widget _buildColorPicker(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presetColors.map((color) {
        final isSelected = config.backgroundColor == color;
        return GestureDetector(
          onTap: () {
            onConfigChanged(config.copyWith(backgroundColor: color));
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: Colors.blue, width: 3)
                  : Border.all(color: Colors.grey.shade300),
            ),
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGradientPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('渐变方向'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildDirectionButton('上下', GradientDirection.topToBottom),
            _buildDirectionButton('左右', GradientDirection.leftToRight),
            _buildDirectionButton('对角↘', GradientDirection.topLeftToBottomRight),
            _buildDirectionButton('对角↙', GradientDirection.topRightToBottomLeft),
          ],
        ),
        const SizedBox(height: 16),
        const Text('渐变颜色'),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGradientColorButton(context, 0),
            const SizedBox(width: 16),
            _buildGradientColorButton(context, 1),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionButton(String label, GradientDirection direction) {
    final isSelected = config.gradientDirection == direction;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        onConfigChanged(config.copyWith(gradientDirection: direction));
      },
    );
  }

  Widget _buildGradientColorButton(BuildContext context, int index) {
    final colors = config.gradientColors ?? [Colors.blue, Colors.purple];
    final color = colors[index];
    return GestureDetector(
      onTap: () => _showColorPicker(context, color, (newColor) {
        final newColors = List<Color>.from(colors);
        newColors[index] = newColor;
        onConfigChanged(config.copyWith(gradientColors: newColors));
      }),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    final hasImage = config.backgroundImagePath != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasImage)
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: FileImage(File(config.backgroundImagePath!)),
                fit: BoxFit.cover,
              ),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => _pickImage(context),
          icon: const Icon(Icons.image),
          label: Text(hasImage ? '更换图片' : '选择图片'),
        ),
        if (hasImage) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              onConfigChanged(config.copyWith(backgroundImagePath: null));
            },
            child: const Text('清除图片'),
          ),
        ],
      ],
    );
  }

  void _showColorPicker(BuildContext context, Color currentColor, ValueChanged<Color> onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择颜色'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      onConfigChanged(config.copyWith(backgroundImagePath: picked.path));
    }
  }
}
