import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/ui/app_colors.dart';
import '../core/models/card_background.dart';
import '../core/constants/card_theme_constants.dart';
import '../widgets/card_background_container.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/avatar_picker.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  bool _isSaving = false;

  Widget _buildAvatar(String? avatarPath) {
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

  Widget _buildPreviewCard() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Consumer<AppProvider>(
          builder: (context, appProvider, child) {
            final isLoggedIn = authProvider.isLoggedIn;
            final user = authProvider.currentUser;
            final background = appProvider.previewBackground ?? appProvider.cardBackground;

            return CardBackgroundContainer(
              background: background,
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildAvatar(appProvider.avatarPath),
                    const SizedBox(height: 16),
                    if (isLoggedIn && user != null)
                      Text(
                        user.nickname ?? '用户',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      const Text(
                        '用户昵称',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSolidColorSection() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final currentBg = appProvider.previewBackground ?? appProvider.cardBackground;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                '纯色主题',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: CardThemeConstants.allSolidColors.length,
                itemBuilder: (context, index) {
                  final bg = CardThemeConstants.allSolidColors[index];
                  final isSelected = currentBg.type == bg.type && currentBg.colorKey == bg.colorKey;
                  final colors = CardThemeConstants.getColors(bg);

                  return GestureDetector(
                    onTap: () {
                      appProvider.setPreviewBackground(bg);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 3)
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBackgroundImageSection() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final currentBg = appProvider.previewBackground ?? appProvider.cardBackground;
        final allOptions = [
          ...CardThemeConstants.allGradients,
          ...CardThemeConstants.allImages,
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                '背景图片',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                ),
                itemCount: allOptions.length,
                itemBuilder: (context, index) {
                  final bg = allOptions[index];
                  final isSelected = _isBackgroundEqual(currentBg, bg);

                  return GestureDetector(
                    onTap: () {
                      appProvider.setPreviewBackground(bg);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: AppColors.primary, width: 3)
                            : null,
                      ),
                      child: _buildOptionPreview(bg),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  bool _isBackgroundEqual(CardBackground a, CardBackground b) {
    if (a.type != b.type) return false;
    if (a.type == CardBackgroundType.image) {
      return a.assetPath == b.assetPath;
    }
    return a.colorKey == b.colorKey;
  }

  Widget _buildOptionPreview(CardBackground bg) {
    if (bg.type == CardBackgroundType.image) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
          ),
          child: Center(
            child: Icon(
              Icons.image,
              color: Colors.grey[600],
              size: 32,
            ),
          ),
        ),
      );
    }

    final colors = CardThemeConstants.getColors(bg);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      final appProvider = context.read<AppProvider>();
      final selectedBg = appProvider.previewBackground;

      if (selectedBg != null) {
        // 清除临时颜色，只保存 key
        final bgToSave = selectedBg.copyWith(colors: null);
        await appProvider.saveCardBackground(bgToSave);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPreviewCard(),
                _buildSolidColorSection(),
                _buildBackgroundImageSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          '保存',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
