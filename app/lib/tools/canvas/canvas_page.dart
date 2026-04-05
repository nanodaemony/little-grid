import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'services/drawing_service.dart';
import 'services/export_service.dart';
import 'widgets/canvas_widget.dart';
import 'widgets/color_picker.dart';
import 'widgets/brush_selector.dart';
import 'widgets/shape_selector.dart';
import 'widgets/sticker_panel.dart';
import 'widgets/size_slider.dart';
import 'models/stroke.dart';

class CanvasPage extends StatelessWidget {
  const CanvasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DrawingService(),
      child: const _CanvasPageContent(),
    );
  }
}

class _CanvasPageContent extends StatelessWidget {
  const _CanvasPageContent();

  @override
  Widget build(BuildContext context) {
    final service = context.watch<DrawingService>();
    final exportService = ExportService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('画板'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveImage(context, service, exportService),
          ),
        ],
      ),
      body: Column(
        children: [
          // 画布
          Expanded(
            child: CanvasWidget(
              service: service,
              repaintKey: exportService.repaintKey,
            ),
          ),
          // 工具栏
          _buildToolbar(context, service),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, DrawingService service) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 模式切换
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ModeButton(
                  icon: Icons.edit,
                  label: '画笔',
                  selected: service.mode == DrawMode.brush,
                  onTap: () => service.setMode(DrawMode.brush),
                ),
                _ModeButton(
                  icon: Icons.category,
                  label: '形状',
                  selected: service.mode == DrawMode.shape,
                  onTap: () => service.setMode(DrawMode.shape),
                ),
                _ModeButton(
                  icon: Icons.emoji_emotions,
                  label: '贴纸',
                  selected: service.mode == DrawMode.sticker,
                  onTap: () => _showStickerPanel(context, service),
                ),
                _ModeButton(
                  icon: Icons.cleaning_services,
                  label: '橡皮',
                  selected: service.mode == DrawMode.eraser,
                  onTap: () => service.setMode(DrawMode.eraser),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 属性调节
            if (service.mode == DrawMode.brush || service.mode == DrawMode.eraser) ...[
              ColorPicker(
                selectedColor: service.currentColor,
                onColorSelected: service.setColor,
              ),
              const SizedBox(height: 4),
              BrushSelector(
                selectedType: service.brushType,
                onTypeSelected: service.setBrushType,
              ),
              const SizedBox(height: 4),
              SizeSlider(
                value: service.currentSize,
                onChanged: service.setSize,
              ),
            ],
            if (service.mode == DrawMode.shape) ...[
              ColorPicker(
                selectedColor: service.currentColor,
                onColorSelected: service.setColor,
              ),
              const SizedBox(height: 4),
              ShapeSelector(
                selectedType: service.shapeType,
                filled: service.shapeFilled,
                onTypeSelected: service.setShapeType,
                onFilledChanged: service.setShapeFilled,
              ),
            ],
            const SizedBox(height: 8),
            // 操作按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: service.canUndo ? service.undo : null,
                ),
                IconButton(
                  icon: const Icon(Icons.redo),
                  onPressed: service.canRedo ? service.redo : null,
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () => _pickImage(context, service),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmClear(context, service),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStickerPanel(BuildContext context, DrawingService service) {
    showModalBottomSheet(
      context: context,
      builder: (context) => StickerPanel(
        onStickerSelected: (emoji) {
          Navigator.pop(context);
          // 在画布中心添加贴纸
          service.addSticker(emoji, const Offset(200, 300));
        },
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, DrawingService service) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      service.setBackgroundImage(image.path);
    }
  }

  Future<void> _saveImage(
    BuildContext context,
    DrawingService service,
    ExportService exportService,
  ) async {
    final data = await exportService.exportToImage(service.state);
    if (data != null) {
      final success = await exportService.saveToGallery(data);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '已保存到相册' : '保存失败'),
          ),
        );
      }
    }
  }

  Future<void> _confirmClear(BuildContext context, DrawingService service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空画布'),
        content: const Text('确定要清空画布吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      service.clear();
    }
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: selected ? Theme.of(context).colorScheme.primary : null),
          Text(label, style: TextStyle(
            fontSize: 10,
            color: selected ? Theme.of(context).colorScheme.primary : null,
          )),
        ],
      ),
    );
  }
}