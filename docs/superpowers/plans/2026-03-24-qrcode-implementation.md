# 二维码生成器实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 构建一个二维码生成器工具，支持文本/网址内容，可自定义前景色、背景（纯色/预设/自定义）、Logo（无/Emoji/预设/自定义），并可保存到相册。

**Architecture:** 采用 Provider 模式管理状态，使用 qr_flutter 生成二维码，通过 RepaintBoundary 捕获 Widget 并保存为图片。

**Tech Stack:** Flutter, qr_flutter, provider, image_picker, gal, path_provider

---

## File Structure

```
app/lib/tools/qrcode/
├── qrcode_tool.dart           # 工具注册入口
├── qrcode_page.dart           # 主页面
├── qrcode_service.dart        # 二维码状态管理服务
└── models/
    └── qrcode_config.dart     # 配置模型

app/assets/
└── images/qrcode/             # 预设素材目录（开发者后续添加）
```

---

### Task 1: 添加依赖

**Files:**
- Modify: `app/pubspec.yaml`

- [ ] **Step 1: 添加 qr_flutter 依赖**

在 `pubspec.yaml` 的 `dependencies` 部分添加：

```yaml
  # 二维码生成
  qr_flutter: ^4.1.0
```

- [ ] **Step 2: 安装依赖**

Run: `cd app && flutter pub get`
Expected: 依赖安装成功，无错误

- [ ] **Step 3: 提交**

```bash
git add app/pubspec.yaml
git commit -m "chore(qrcode): add qr_flutter dependency"
```

---

### Task 2: 创建数据模型

**Files:**
- Create: `app/lib/tools/qrcode/models/qrcode_config.dart`

- [ ] **Step 1: 创建配置模型文件**

```dart
import 'package:flutter/material.dart';

/// 内容类型
enum ContentType { text, url }

/// 背景类型
enum BackgroundType { solid, preset, custom }

/// Logo类型
enum LogoType { none, emoji, preset, custom }

/// 二维码配置
class QRCodeConfig {
  String content;
  ContentType contentType;
  Color foregroundColor;

  // 背景配置
  BackgroundType backgroundType;
  Color solidBackgroundColor;
  String? presetBackgroundId;
  String? customBackgroundPath;

  // Logo配置
  LogoType logoType;
  String? emojiLogo;
  String? presetLogoId;
  String? customLogoPath;
  double logoSize;

  QRCodeConfig({
    this.content = '',
    this.contentType = ContentType.text,
    this.foregroundColor = Colors.black,
    this.backgroundType = BackgroundType.solid,
    this.solidBackgroundColor = Colors.white,
    this.presetBackgroundId,
    this.customBackgroundPath,
    this.logoType = LogoType.none,
    this.emojiLogo,
    this.presetLogoId,
    this.customLogoPath,
    this.logoSize = 0.2,
  });

  /// 是否有有效内容
  bool get hasContent => content.trim().isNotEmpty;

  /// 是否显示 Logo
  bool get showLogo => logoType != LogoType.none;

  QRCodeConfig copyWith({
    String? content,
    ContentType? contentType,
    Color? foregroundColor,
    BackgroundType? backgroundType,
    Color? solidBackgroundColor,
    String? presetBackgroundId,
    String? customBackgroundPath,
    LogoType? logoType,
    String? emojiLogo,
    String? presetLogoId,
    String? customLogoPath,
    double? logoSize,
  }) {
    return QRCodeConfig(
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundType: backgroundType ?? this.backgroundType,
      solidBackgroundColor: solidBackgroundColor ?? this.solidBackgroundColor,
      presetBackgroundId: presetBackgroundId ?? this.presetBackgroundId,
      customBackgroundPath: customBackgroundPath ?? this.customBackgroundPath,
      logoType: logoType ?? this.logoType,
      emojiLogo: emojiLogo ?? this.emojiLogo,
      presetLogoId: presetLogoId ?? this.presetLogoId,
      customLogoPath: customLogoPath ?? this.customLogoPath,
      logoSize: logoSize ?? this.logoSize,
    );
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/qrcode/models/qrcode_config.dart
git commit -m "feat(qrcode): add QRCodeConfig model"
```

---

### Task 3: 创建状态管理服务

**Files:**
- Create: `app/lib/tools/qrcode/qrcode_service.dart`

- [ ] **Step 1: 创建服务文件**

```dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'models/qrcode_config.dart';

/// 二维码生成服务
class QRCodeService extends ChangeNotifier {
  QRCodeConfig _config = QRCodeConfig();
  final GlobalKey repaintKey = GlobalKey();

  QRCodeConfig get config => _config;

  /// 更新内容
  void setContent(String content) {
    _config = _config.copyWith(content: content);
    notifyListeners();
  }

  /// 更新内容类型
  void setContentType(ContentType type) {
    _config = _config.copyWith(contentType: type);
    notifyListeners();
  }

  /// 更新前景色
  void setForegroundColor(Color color) {
    _config = _config.copyWith(foregroundColor: color);
    notifyListeners();
  }

  /// 设置纯色背景
  void setSolidBackground(Color color) {
    _config = _config.copyWith(
      backgroundType: BackgroundType.solid,
      solidBackgroundColor: color,
    );
    notifyListeners();
  }

  /// 设置预设背景
  void setPresetBackground(String id) {
    _config = _config.copyWith(
      backgroundType: BackgroundType.preset,
      presetBackgroundId: id,
    );
    notifyListeners();
  }

  /// 设置自定义背景
  void setCustomBackground(String? path) {
    _config = _config.copyWith(
      backgroundType: path != null ? BackgroundType.custom : BackgroundType.solid,
      customBackgroundPath: path,
    );
    notifyListeners();
  }

  /// 设置 Logo 类型
  void setLogoType(LogoType type) {
    _config = _config.copyWith(logoType: type);
    notifyListeners();
  }

  /// 设置 Emoji Logo
  void setEmojiLogo(String emoji) {
    _config = _config.copyWith(
      logoType: LogoType.emoji,
      emojiLogo: emoji,
    );
    notifyListeners();
  }

  /// 设置预设 Logo
  void setPresetLogo(String id) {
    _config = _config.copyWith(
      logoType: LogoType.preset,
      presetLogoId: id,
    );
    notifyListeners();
  }

  /// 设置自定义 Logo
  void setCustomLogo(String? path) {
    _config = _config.copyWith(
      logoType: path != null ? LogoType.custom : LogoType.none,
      customLogoPath: path,
    );
    notifyListeners();
  }

  /// 重置配置
  void reset() {
    _config = QRCodeConfig();
    notifyListeners();
  }

  /// 导出为图片数据
  Future<Uint8List?> exportToImage() async {
    try {
      final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Export error: $e');
      return null;
    }
  }

  /// 保存到相册
  Future<bool> saveToGallery() async {
    final data = await exportToImage();
    if (data == null) return false;

    try {
      await Gal.putImageBytes(data);
      return true;
    } catch (e) {
      debugPrint('Save to gallery error: $e');
      return false;
    }
  }
}
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/qrcode/qrcode_service.dart
git commit -m "feat(qrcode): add QRCodeService for state management"
```

---

### Task 4: 创建主页面

**Files:**
- Create: `app/lib/tools/qrcode/qrcode_page.dart`

- [ ] **Step 1: 创建页面文件**

```dart
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: config.backgroundType == BackgroundType.solid
                ? config.solidBackgroundColor
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: config.hasContent
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    // 背景层
                    if (config.backgroundType != BackgroundType.solid)
                      _buildBackgroundImage(config),

                    // 二维码层
                    QrImageView(
                      data: config.content,
                      size: 200,
                      backgroundColor: Colors.transparent,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: config.foregroundColor,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: config.foregroundColor,
                      ),
                    ),

                    // Logo层
                    if (config.showLogo) _buildLogo(config),
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
        width: 232,
        height: 232,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade200, Colors.blue.shade200],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      );
    }
    // 自定义背景使用 Image.file 加载本地文件
    if (config.backgroundType == BackgroundType.custom &&
        config.customBackgroundPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(config.customBackgroundPath!),
          width: 232,
          height: 232,
          fit: BoxFit.cover,
        ),
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
```

- [ ] **Step 2: 提交**

```bash
git add app/lib/tools/qrcode/qrcode_page.dart
git commit -m "feat(qrcode): add QRCodePage with UI components"
```

---

### Task 5: 创建工具入口并注册

**Files:**
- Create: `app/lib/tools/qrcode/qrcode_tool.dart`
- Modify: `app/lib/main.dart`

- [ ] **Step 1: 创建工具入口文件**

```dart
import 'package:flutter/material.dart';
import '../../core/services/tool_registry.dart';
import 'qrcode_page.dart';

class QRCodeTool implements ToolModule {
  @override
  String get id => 'qrcode';

  @override
  String get name => '二维码生成器';

  @override
  String get version => '1.0.0';

  @override
  IconData get icon => Icons.qr_code_2;

  @override
  ToolCategory get category => ToolCategory.life;

  @override
  int get gridSize => 1;

  @override
  Widget buildPage(BuildContext context) {
    return const QRCodePage();
  }

  @override
  ToolSettings? get settings => null;

  @override
  Future<void> onInit() async {}

  @override
  Future<void> onDispose() async {}

  @override
  void onEnter() {}

  @override
  void onExit() {}
}
```

- [ ] **Step 2: 在 main.dart 中导入并注册工具**

在 `app/lib/main.dart` 添加导入：

```dart
import 'tools/qrcode/qrcode_tool.dart';
```

在 `main()` 函数中注册：

```dart
ToolRegistry.register(QRCodeTool());
```

- [ ] **Step 3: 验证编译通过**

Run: `cd app && flutter analyze`
Expected: 无错误

- [ ] **Step 4: 提交**

```bash
git add app/lib/tools/qrcode/qrcode_tool.dart app/lib/main.dart
git commit -m "feat(qrcode): register QRCodeTool in main app"
```

---

### Task 6: 创建资源目录

**Files:**
- Create: `app/assets/images/qrcode/.gitkeep`

- [ ] **Step 1: 创建资源目录**

Run: `mkdir -p app/assets/images/qrcode`

- [ ] **Step 2: 创建 .gitkeep 文件**

Run: `touch app/assets/images/qrcode/.gitkeep`

- [ ] **Step 3: 提交**

```bash
git add app/assets/images/qrcode/.gitkeep
git commit -m "chore(qrcode): add assets directory for preset images"
```

---

### Task 7: 验证功能

**Files:**
- 无文件修改，手动测试

- [ ] **Step 1: 运行应用**

Run: `cd app && flutter run`
Expected: 应用正常启动

- [ ] **Step 2: 测试基本功能**

手动测试：
1. 在格子页面找到"二维码生成器"
2. 输入文本内容，验证二维码生成
3. 切换前景色，验证颜色变化
4. 切换背景色，验证背景变化
5. 选择 Emoji Logo，验证显示
6. 点击保存按钮，验证保存成功

- [ ] **Step 3: 最终提交**

```bash
git add -A
git commit -m "feat(qrcode): complete QR code generator implementation

- Support text and URL content types
- Custom foreground and background colors
- Emoji logo support
- Save to gallery functionality"
```

---

## 测试清单

- [ ] 文本内容生成二维码
- [ ] 网址内容生成二维码
- [ ] 前景色自定义
- [ ] 纯色背景切换
- [ ] 预设背景图切换（待素材）
- [ ] 自定义背景图选择
- [ ] Emoji Logo 选择
- [ ] 预设 Logo 选择（待素材）
- [ ] 自定义 Logo 上传
- [ ] 保存到相册功能

---

**文档版本**：1.0
**创建日期**：2026-03-24