import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PixelPreview extends StatelessWidget {
  final ui.Image? image;
  final bool isLoading;
  final VoidCallback? onTap;
  final String placeholderText;

  const PixelPreview({
    super.key,
    this.image,
    this.isLoading = false,
    this.onTap,
    this.placeholderText = '请选择图片',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('处理中...'),
          ],
        ),
      );
    }

    if (image == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              placeholderText,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: RawImage(
        image: image,
        fit: BoxFit.contain,
      ),
    );
  }
}
