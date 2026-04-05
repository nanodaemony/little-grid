import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../core/ui/app_colors.dart';

/// 头像选择器
/// 提供相册选择和默认头像选择
class AvatarPicker {
  /// 显示选择菜单
  static Future<String?> show(BuildContext context) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text(
              '更换头像',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('从相册选择'),
              onTap: () async {
                final selectedPath = await _pickFromGallery();
                if (context.mounted) {
                  Navigator.pop(context, selectedPath);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette, color: AppColors.primary),
              title: const Text('选择默认头像'),
              onTap: () async {
                final avatarPath = await _showDefaultAvatarSelector(context);
                if (context.mounted) {
                  Navigator.pop(context, avatarPath);
                }
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.close, color: Colors.grey),
              title: const Text('取消'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    return result;
  }

  /// 从相册选择图片
  static Future<String?> _pickFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile == null) return null;

    // 压缩图片
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      pickedFile.path,
      '${path.dirname(pickedFile.path)}/compressed_${path.basename(pickedFile.path)}',
      quality: 85,
      minWidth: 256,
      minHeight: 256,
    );

    final finalPath = compressedFile?.path ?? pickedFile.path;

    // 复制到应用目录
    return await _saveToAppDirectory(finalPath);
  }

  /// 保存图片到应用目录
  static Future<String> _saveToAppDirectory(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final avatarDir = Directory('${appDir.path}/avatars');

    if (!await avatarDir.exists()) {
      await avatarDir.create(recursive: true);
    }

    final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final targetPath = '${avatarDir.path}/$fileName';

    await File(sourcePath).copy(targetPath);

    return targetPath;
  }

  /// 显示默认头像选择器
  static Future<String?> _showDefaultAvatarSelector(BuildContext context) async {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
    ];

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择默认头像'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Navigator.pop(context, 'default:$index'),
                child: Container(
                  decoration: BoxDecoration(
                    color: colors[index],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors[index].withAlpha((0.3 * 255).round()),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 获取默认头像颜色
  static Color getDefaultAvatarColor(String? avatarPath) {
    if (avatarPath == null || !avatarPath.startsWith('default:')) {
      return Colors.grey;
    }

    final index = int.tryParse(avatarPath.split(':')[1]) ?? 0;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
    ];

    return colors[index % colors.length];
  }

  /// 判断是否为默认头像
  static bool isDefaultAvatar(String? avatarPath) {
    return avatarPath != null && avatarPath.startsWith('default:');
  }
}
