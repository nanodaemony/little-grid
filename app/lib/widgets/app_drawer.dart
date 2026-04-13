import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/ui/app_colors.dart';
import '../pages/settings_page.dart';
import '../providers/app_provider.dart';
import 'avatar_picker.dart';
import '../pages/feedback/feedback_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _nickname = '用户';

  Future<void> _onAvatarTap() async {
    final path = await AvatarPicker.show(context);
    if (path != null && mounted) {
      await context.read<AppProvider>().updateAvatar(path);
    }
  }

  Widget _buildAvatar(String? avatarPath) {
    // 默认头像
    if (avatarPath == null || AvatarPicker.isDefaultAvatar(avatarPath)) {
      final color = AvatarPicker.getDefaultAvatarColor(avatarPath);
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person,
            size: 48,
            color: Colors.white,
          ),
        ),
      );
    }

    // 自定义图片头像
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: ClipOval(
        child: Image.file(
          File(avatarPath),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.person,
              size: 48,
              color: AppColors.primary,
            );
          },
        ),
      ),
    );
  }

  Future<void> _editNickname() async {
    final controller = TextEditingController(text: _nickname);
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('修改昵称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '昵称',
            hintText: '输入新昵称',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() => _nickname = newName);
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: '小方格',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.grid_view,
          size: 40,
          color: Colors.white,
        ),
      ),
      applicationLegalese: '© 2025 LittleGrid',
      children: [
        const SizedBox(height: 16),
        const Text('实用小工具的集合应用'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          _buildHeader(),
          // Menu items
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('设置'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _showAboutDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('反馈'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedbackPage(),
                ),
              );
            },
          ),
          const Spacer(),
          // Footer
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Avatar
                _buildAvatar(provider.avatarPath),
                const SizedBox(height: 16),
                // Nickname
                Text(
                  _nickname,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '已使用 4 个工具',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withAlpha((0.7 * 255).round()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
