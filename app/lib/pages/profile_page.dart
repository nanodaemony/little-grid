import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/ui/app_colors.dart';
import '../models/user.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/avatar_picker.dart';
import 'login/login_page.dart';
import 'settings_page.dart';
import 'feedback/feedback_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: ListView(
        children: [
          // 用户信息卡片
          _buildUserCard(),

          const Divider(height: 32),

          // 功能列表
          _buildMenuItem(
            icon: Icons.settings,
            title: '设置',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.bar_chart,
            title: '使用统计',
            onTap: () {
              // TODO: 使用统计
            },
          ),
          _buildMenuItem(
            icon: Icons.feedback,
            title: '反馈建议',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FeedbackPage(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.info,
            title: '关于我们',
            onTap: () {
              _showAboutDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            final isLoggedIn = authProvider.isLoggedIn;
            final user = authProvider.currentUser;

            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha((0.3 * 255).round()),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 头像
                  _buildAvatar(appProvider.avatarPath),

                  const SizedBox(height: 16),

                  // 昵称或登录按钮
                  if (isLoggedIn && user != null)
                    _buildLoggedInUser(user)
                  else
                    _buildLoginButton(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoggedInUser(User user) {
    return Column(
      children: [
        Text(
          user.nickname ?? '用户',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: const Text(
        '登录 / 注册',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
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
}
