import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/ui/app_colors.dart';
import '../providers/auth_provider.dart';
import 'my_info_page.dart';
import 'theme_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 账号分组
          _buildSectionCard(
            title: '账号',
            children: [
              _buildMenuItem(
                icon: Icons.person_outline,
                title: '我的信息',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyInfoPage(),
                    ),
                  );
                },
              ),
            ],
          ),

          // 外观分组
          _buildSectionCard(
            title: '外观',
            children: [
              _buildMenuItem(
                icon: Icons.palette,
                title: '主题',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemePage(),
                    ),
                  );
                },
              ),
            ],
          ),

          // 通知分组
          _buildSectionCard(
            title: '通知',
            children: [
              _buildSwitchItem(
                icon: Icons.notifications,
                title: '推送通知',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
            ],
          ),

          // 数据分组
          _buildSectionCard(
            title: '数据',
            children: [
              _buildMenuItem(
                icon: Icons.download,
                title: '导出数据',
                onTap: () {
                  // TODO: 导出数据
                },
              ),
              _buildMenuItem(
                icon: Icons.delete_outline,
                title: '清除缓存',
                subtitle: '12.5 MB',
                onTap: () => _showClearCacheDialog(),
              ),
            ],
          ),

          // 其他分组
          _buildSectionCard(
            title: '其他',
            children: [
              _buildMenuItem(
                icon: Icons.update,
                title: '检查更新',
                onTap: () {
                  // TODO: 检查更新
                },
              ),
              _buildMenuItem(
                icon: Icons.privacy_tip,
                title: '隐私政策',
                onTap: () {
                  // TODO: 显示隐私政策
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 退出登录按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '退出登录',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          if (children.isNotEmpty)
            Container(height: 1, color: AppColors.divider),
          ...children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;
            final isLast = index == children.length - 1;
            return Column(
              children: [
                child,
                if (!isLast)
                  Container(height: 1, color: const Color(0xFFF0F0F0)),
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 清除缓存
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存已清除')),
              );
            },
            child: const Text('清除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
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

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
