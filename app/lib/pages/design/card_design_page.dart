import 'package:flutter/material.dart';
import '../../core/ui/app_colors.dart';

class CardDesignPage extends StatelessWidget {
  const CardDesignPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('卡片设计'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Basic Cards
          _buildSectionTitle('基础卡片'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '纯文字卡片 - 这是一段简单的文本内容，展示在卡片内部。',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('无阴影卡片 - elevation: 0'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 8,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('大阴影卡片 - elevation: 8'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: AppColors.primaryLight.withOpacity(0.3),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('带背景色的卡片'),
            ),
          ),

          const SizedBox(height: 24),

          // Section 2: Title Cards
          _buildSectionTitle('标题卡片'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '大标题',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '这是卡片的内容描述文字，可以放置更多详细信息。',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '主标题',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '副标题文字',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '这里是卡片的主要内容区域，可以放置更多的信息。',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section 3: Icon Cards
          _buildSectionTitle('带 Icon 的卡片'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '通知',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '左侧图标 + 文字的卡片布局',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      Icons.star,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '顶部图标',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '圆形图标背景 + 文字',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.bookmark,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '收藏',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '方形图标背景',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section 4: Image Cards
          _buildSectionTitle('带图片的卡片'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 160,
                  color: AppColors.primaryLight,
                  child: Icon(
                    Icons.image,
                    size: 64,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '顶部图片',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('图片 + 内容的卡片布局'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  color: AppColors.primaryLight,
                  child: Icon(
                    Icons.photo,
                    size: 40,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '左侧图片',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('左右布局的卡片'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 5: Action Cards
          _buildSectionTitle('带操作的卡片'),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '卡片标题',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('这是卡片内容，底部有操作按钮。'),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ButtonBar(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('取消'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('确认'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.message, color: AppColors.primary),
              title: const Text('可点击卡片'),
              subtitle: const Text('点击右侧箭头进行跳转'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),

          const SizedBox(height: 24),

          // Section 6: Special Cards
          _buildSectionTitle('特殊样式卡片'),
          _buildSectionSubtitle('不同圆角'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const SizedBox(
                  width: 100,
                  height: 80,
                  child: Center(child: Text('小圆角')),
                ),
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const SizedBox(
                  width: 100,
                  height: 80,
                  child: Center(child: Text('大圆角')),
                ),
              ),
              const Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: SizedBox(
                  width: 100,
                  height: 80,
                  child: Center(child: Text('直角')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSectionSubtitle('边框卡片'),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColors.border, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('带边框的卡片 (elevation: 0)'),
            ),
          ),
          const SizedBox(height: 12),
          _buildSectionSubtitle('渐变背景'),
          Card(
            elevation: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20),
              child: const Text(
                '渐变背景卡片',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSectionSubtitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
