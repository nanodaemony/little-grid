import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'qrcode_service.dart';
import 'models/qrcode_config.dart';

class QRCodePage extends StatelessWidget {
  const QRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QRCodeService(),
      child: const _QRCodePageContent(),
    );
  }
}

class _QRCodePageContent extends StatelessWidget {
  const _QRCodePageContent();

  @override
  Widget build(BuildContext context) {
    final service = context.watch<QRCodeService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('二维码生成器'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: service.config.hasContent
                ? () => _saveToGallery(context, service)
                : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 输入区域
            _buildInputSection(context, service),
            const SizedBox(height: 16),

            // 二维码预览
            _buildQRCodePreview(context, service),
            const SizedBox(height: 16),

            // 背景设置
            _buildBackgroundSection(context, service),
            const SizedBox(height: 16),

            // Logo设置
            _buildLogoSection(context, service),
            const SizedBox(height: 16),

            // 前景色设置
            _buildForegroundSection(context, service),
            const SizedBox(height: 24),

            // 保存按钮
            _buildSaveButton(context, service),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(BuildContext context, QRCodeService service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('内容', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          onChanged: service.setContent,
          decoration: InputDecoration(
            hintText: '输入文本或网址...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: service.config.content.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      service.setContent('');
                    },
                  )
                : null,
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 8),
        SegmentedButton<ContentType>(
          segments: const [
            ButtonSegment(value: ContentType.text, label: Text('文本')),
            ButtonSegment(value: ContentType.url, label: Text('网址')),
          ],
          selected: {service.config.contentType},
          onSelectionChanged: (types) {
            service.setContentType(types.first);
          },
        ),
      ],
    );
  }

  Widget _buildQRCodePreview(BuildContext context, QRCodeService service) {
    final config = service.config;

    return Center(
      child: RepaintBoundary(
        key: service.repaintKey,
        child: Container(
          width: 232,
          height: 232,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: config.backgroundType == BackgroundType.solid
                ? config.solidBackgroundColor
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: config.hasContent
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    // 背景层（在二维码后面）
                    if (config.backgroundType != BackgroundType.solid)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildBackgroundImage(config),
                        ),
                      ),

                    // 二维码层 - 使用 embeddedImage 嵌入 Logo
                    QrImageView(
                      data: config.content,
                      size: 200,
                      backgroundColor: config.backgroundType == BackgroundType.solid
                          ? config.solidBackgroundColor
                          : Colors.white,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: config.foregroundColor,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: config.foregroundColor,
                      ),
                      embeddedImage: config.logoType == LogoType.custom && config.customLogoPath != null
                          ? FileImage(File(config.customLogoPath!))
                          : null,
                      embeddedImageStyle: const QrEmbeddedImageStyle(
                        size: Size(40, 40),
                      ),
                    ),

                    // Emoji Logo 层（尺寸小，不遮挡关键区域）
                    if (config.logoType == LogoType.emoji && config.emojiLogo != null)
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            config.emojiLogo!,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                  ],
                )
              : Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('输入内容生成二维码'),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage(QRCodeConfig config) {
    // 预设背景需要开发者添加素材后实现
    if (config.backgroundType == BackgroundType.preset &&
        config.presetBackgroundId != null) {
      // TODO: 预设背景待素材添加后实现
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade200, Colors.blue.shade200],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }
    // 自定义背景使用 Image.file 加载本地文件
    if (config.backgroundType == BackgroundType.custom &&
        config.customBackgroundPath != null) {
      return Image.file(
        File(config.customBackgroundPath!),
        fit: BoxFit.cover,
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildLogo(QRCodeConfig config) {
    final size = 200 * config.logoSize;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: _buildLogoContent(config, size),
      ),
    );
  }

  Widget _buildLogoContent(QRCodeConfig config, double size) {
    switch (config.logoType) {
      case LogoType.emoji:
        return Text(
          config.emojiLogo ?? '',
          style: TextStyle(fontSize: size * 0.6),
        );
      case LogoType.custom:
        if (config.customLogoPath != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.file(
              File(config.customLogoPath!),
              width: size - 8,
              height: size - 8,
              fit: BoxFit.cover,
            ),
          );
        }
        return const Icon(Icons.image, size: 24);
      case LogoType.preset:
        // TODO: 预设Logo待素材添加后实现
        if (config.presetLogoId != null) {
          return const Icon(Icons.qr_code_2, size: 32);
        }
        return const Icon(Icons.image, size: 24);
      case LogoType.none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBackgroundSection(BuildContext context, QRCodeService service) {
    final config = service.config;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('背景设置', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<BackgroundType>(
          segments: const [
            ButtonSegment(value: BackgroundType.solid, label: Text('纯色')),
            ButtonSegment(value: BackgroundType.preset, label: Text('预设')),
            ButtonSegment(value: BackgroundType.custom, label: Text('自定义')),
          ],
          selected: {config.backgroundType},
          onSelectionChanged: (types) async {
            final type = types.first;
            if (type == BackgroundType.custom) {
              final picker = ImagePicker();
              final image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                service.setCustomBackground(image.path);
              }
            } else if (type == BackgroundType.preset) {
              // 预设背景待素材添加后实现，目前使用默认预设
              service.setPresetBackground('default');
            } else {
              service.setSolidBackground(config.solidBackgroundColor);
            }
          },
        ),
        if (config.backgroundType == BackgroundType.solid) ...[
          const SizedBox(height: 8),
          _buildColorPicker(
            context: context,
            selectedColor: config.solidBackgroundColor,
            onColorSelected: service.setSolidBackground,
          ),
        ],
      ],
    );
  }

  Widget _buildLogoSection(BuildContext context, QRCodeService service) {
    final config = service.config;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Logo设置', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<LogoType>(
          segments: const [
            ButtonSegment(value: LogoType.none, label: Text('无')),
            ButtonSegment(value: LogoType.emoji, label: Text('Emoji')),
            ButtonSegment(value: LogoType.preset, label: Text('预设')),
            ButtonSegment(value: LogoType.custom, label: Text('自定义')),
          ],
          selected: {config.logoType},
          onSelectionChanged: (types) async {
            final type = types.first;
            if (type == LogoType.custom) {
              final picker = ImagePicker();
              final image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                service.setCustomLogo(image.path);
              }
            } else if (type == LogoType.emoji) {
              _showEmojiPicker(context, service);
            } else {
              service.setLogoType(type);
            }
          },
        ),
        if (config.logoType == LogoType.emoji && config.emojiLogo != null) ...[
          const SizedBox(height: 8),
          Text('当前: ${config.emojiLogo}'),
        ],
      ],
    );
  }

  void _showEmojiPicker(BuildContext context, QRCodeService service) {
    // 常用 Emoji 列表
    const emojis = ['😀', '😎', '❤️', '🌟', '🔥', '✨', '🎉', '👍', '🎯', '💡'];

    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 120,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          padding: const EdgeInsets.all(16),
          itemCount: emojis.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                service.setEmojiLogo(emojis[index]);
                Navigator.pop(context);
              },
              child: Center(
                child: Text(
                  emojis[index],
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForegroundSection(BuildContext context, QRCodeService service) {
    final config = service.config;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('前景色', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _buildColorPicker(
          context: context,
          selectedColor: config.foregroundColor,
          onColorSelected: service.setForegroundColor,
        ),
      ],
    );
  }

  Widget _buildColorPicker({
    required BuildContext context,
    required Color selectedColor,
    required ValueChanged<Color> onColorSelected,
  }) {
    final colors = [
      Colors.black,
      Colors.white,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: colors.map((color) {
        final isSelected = color.value == selectedColor.value;
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[300]!,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: color == Colors.white
                  ? [
                      BoxShadow(
                        color: Colors.grey[300]!,
                        blurRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    size: 20,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton(BuildContext context, QRCodeService service) {
    return FilledButton.icon(
      onPressed: service.config.hasContent
          ? () => _saveToGallery(context, service)
          : null,
      icon: const Icon(Icons.save),
      label: const Text('保存到相册'),
    );
  }

  Future<void> _saveToGallery(BuildContext context, QRCodeService service) async {
    final success = await service.saveToGallery();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? '已保存到相册' : '保存失败'),
        ),
      );
    }
  }
}