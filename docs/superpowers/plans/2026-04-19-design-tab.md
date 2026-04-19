# 设计 TAB Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a "设计" TAB to the app's bottom navigation bar with six buttons, including two working pages (button design and card design) that showcase various UI component styles.

**Architecture:** Add a fourth TAB to MainPage. DesignPage shows a vertical list of 6 ListTiles. The first two navigate to ButtonDesignPage and CardDesignPage respectively, which showcase various button and card styles using the app's existing theme.

**Tech Stack:** Flutter, Dart, existing AppColors theme

---

## File Structure

| File | Responsibility |
|------|----------------|
| `lib/pages/design_page.dart` | NEW. Design TAB home page with 6 vertical ListTiles. |
| `lib/pages/design/button_design_page.dart` | NEW. Showcase various button styles, colors, and sizes. |
| `lib/pages/design/card_design_page.dart` | NEW. Showcase various card styles (text, title, icon, image, etc.). |
| `lib/main.dart` | MODIFY. Add DesignPage to `_pages`, add fourth `BottomNavigationBarItem`. |

---

### Task 1: Create DesignPage (设计主页)

**Files:**
- Create: `lib/pages/design_page.dart`

- [ ] **Step 1: Write the DesignPage class**

```dart
import 'package:flutter/material.dart';
import '../core/ui/app_colors.dart';
import 'design/button_design_page.dart';
import 'design/card_design_page.dart';

class DesignPage extends StatelessWidget {
  const DesignPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设计'),
      ),
      body: ListView(
        children: [
          _buildMenuItem(
            icon: Icons.smart_button,
            title: '按钮设计',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ButtonDesignPage(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.dashboard,
            title: '卡片设计',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CardDesignPage(),
                ),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.radio_button_unchecked,
            title: '按钮3',
            onTap: () {
              _showComingSoon(context);
            },
          ),
          _buildMenuItem(
            icon: Icons.radio_button_unchecked,
            title: '按钮4',
            onTap: () {
              _showComingSoon(context);
            },
          ),
          _buildMenuItem(
            icon: Icons.radio_button_unchecked,
            title: '按钮5',
            onTap: () {
              _showComingSoon(context);
            },
          ),
          _buildMenuItem(
            icon: Icons.radio_button_unchecked,
            title: '按钮6',
            onTap: () {
              _showComingSoon(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('功能开发中'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit the new file**

```bash
git add lib/pages/design_page.dart
git commit -m "feat: add DesignPage with 6 menu items

- Vertical ListView with 6 ListTiles
- First two navigate to ButtonDesignPage and CardDesignPage
- Last four show '功能开发中' SnackBar
- Uses AppColors.primary for icons"
```

---

### Task 2: Create ButtonDesignPage (按钮设计页)

**Files:**
- Create: `lib/pages/design/button_design_page.dart`

- [ ] **Step 1: Write the ButtonDesignPage class**

```dart
import 'package:flutter/material.dart';
import '../../core/ui/app_colors.dart';

class ButtonDesignPage extends StatelessWidget {
  const ButtonDesignPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('按钮设计'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section 1: Filled Buttons
          _buildSectionTitle('填充按钮 (ElevatedButton)'),
          _buildButtonRow([
            ElevatedButton(
              onPressed: () {},
              child: const Text('默认'),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text('Success'),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
              child: const Text('Warning'),
            ),
          ]),
          _buildButtonRow([
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text('Error'),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
              ),
              child: const Text('Info'),
            ),
          ]),
          _buildSectionSubtitle('不同大小'),
          _buildButtonRow([
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(100, 56),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('大号'),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(80, 40),
                textStyle: const TextStyle(fontSize: 14),
              ),
              child: const Text('中号'),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(60, 32),
                textStyle: const TextStyle(fontSize: 12),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('小号'),
            ),
          ]),
          _buildSectionSubtitle('带图标'),
          _buildButtonRow([
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('添加'),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save),
              label: const Text('保存'),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.delete),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              label: const Text('删除'),
            ),
          ]),
          _buildSectionSubtitle('状态'),
          _buildButtonRow([
            const ElevatedButton(
              onPressed: null,
              child: Text('禁用'),
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('加载中'),
                ],
              ),
            ),
          ]),

          const SizedBox(height: 24),

          // Section 2: Outlined Buttons
          _buildSectionTitle('轮廓按钮 (OutlinedButton)'),
          _buildButtonRow([
            OutlinedButton(
              onPressed: () {},
              child: const Text('默认'),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.success,
                side: const BorderSide(color: AppColors.success),
              ),
              child: const Text('Success'),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.warning,
                side: const BorderSide(color: AppColors.warning),
              ),
              child: const Text('Warning'),
            ),
          ]),
          _buildSectionSubtitle('边框粗细'),
          _buildButtonRow([
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(width: 1),
              ),
              child: const Text('细边框'),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(width: 2),
              ),
              child: const Text('中边框'),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(width: 3),
              ),
              child: const Text('粗边框'),
            ),
          ]),
          _buildSectionSubtitle('带图标'),
          _buildButtonRow([
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit),
              label: const Text('编辑'),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share),
              label: const Text('分享'),
            ),
            const OutlinedButton(
              onPressed: null,
              child: Text('禁用'),
            ),
          ]),

          const SizedBox(height: 24),

          // Section 3: Text Buttons
          _buildSectionTitle('文字按钮 (TextButton)'),
          _buildButtonRow([
            TextButton(
              onPressed: () {},
              child: const Text('默认'),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.success,
              ),
              child: const Text('Success'),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: const Text('Error'),
            ),
          ]),
          _buildSectionSubtitle('带图标'),
          _buildButtonRow([
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.link),
              label: const Text('链接'),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.info_outline),
              label: const Text('详情'),
            ),
            const TextButton(
              onPressed: null,
              child: Text('禁用'),
            ),
          ]),

          const SizedBox(height: 24),

          // Section 4: Icon Buttons
          _buildSectionTitle('图标按钮 (IconButton)'),
          _buildButtonRow([
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border),
              tooltip: '喜欢',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.bookmark_border),
              color: AppColors.primary,
              tooltip: '收藏',
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.share),
              color: AppColors.success,
              tooltip: '分享',
            ),
          ]),
          _buildSectionSubtitle('不同大小'),
          _buildButtonRow([
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.star),
              iconSize: 32,
              color: AppColors.warning,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.star),
              iconSize: 24,
              color: AppColors.warning,
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.star),
              iconSize: 16,
              color: AppColors.warning,
            ),
          ]),
          _buildSectionSubtitle('填充样式'),
          _buildButtonRow([
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.home),
                color: AppColors.primary,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.home),
                color: Colors.white,
              ),
            ),
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16),
              ),
              child: const Icon(Icons.add),
            ),
          ]),

          const SizedBox(height: 24),

          // Section 5: Floating Action Buttons
          _buildSectionTitle('浮动操作按钮 (FAB)'),
          _buildButtonRow([
            FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            FloatingActionButton.small(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('添加'),
            ),
          ]),
          _buildSectionSubtitle('不同颜色'),
          _buildButtonRow([
            FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppColors.success,
              child: const Icon(Icons.check),
            ),
            FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppColors.warning,
              child: const Icon(Icons.edit),
            ),
            FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppColors.error,
              child: const Icon(Icons.delete),
            ),
          ]),

          const SizedBox(height: 24),

          // Section 6: Other Buttons
          _buildSectionTitle('其他按钮'),
          _buildSectionSubtitle('SegmentedButton'),
          Center(
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('选项1')),
                ButtonSegment(value: 2, label: Text('选项2')),
                ButtonSegment(value: 3, label: Text('选项3')),
              ],
              selected: const {1},
              onSelectionChanged: (Set<int> newSelection) {},
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionSubtitle('ToggleButtons'),
          Center(
            child: ToggleButtons(
              isSelected: const [true, false, false],
              onPressed: (int index) {},
              children: const [
                Icon(Icons.format_bold),
                Icon(Icons.format_italic),
                Icon(Icons.format_underlined),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionSubtitle('DropdownButton'),
          Center(
            child: DropdownButton<String>(
              value: '选项1',
              items: const [
                DropdownMenuItem(value: '选项1', child: Text('选项1')),
                DropdownMenuItem(value: '选项2', child: Text('选项2')),
                DropdownMenuItem(value: '选项3', child: Text('选项3')),
              ],
              onChanged: (String? value) {},
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

  Widget _buildButtonRow(List<Widget> buttons) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: buttons,
    );
  }
}
```

- [ ] **Step 2: Commit the new file**

```bash
git add lib/pages/design/button_design_page.dart
git commit -m "feat: add ButtonDesignPage with various button styles

- Filled buttons (different colors, sizes, states)
- Outlined buttons (different borders, colors)
- Text buttons
- Icon buttons (different sizes, filled styles)
- Floating Action Buttons
- SegmentedButton, ToggleButtons, DropdownButton
- All styles use AppColors theme"
```

---

### Task 3: Create CardDesignPage (卡片设计页)

**Files:**
- Create: `lib/pages/design/card_design_page.dart`

- [ ] **Step 1: Write the CardDesignPage class**

```dart
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
```

- [ ] **Step 2: Commit the new file**

```bash
git add lib/pages/design/card_design_page.dart
git commit -m "feat: add CardDesignPage with various card styles

- Basic cards (different shadows, background colors)
- Title cards (large title, dual title)
- Icon cards (left icon, top icon, square/round background)
- Image cards (top image, left image)
- Action cards (bottom buttons, tappable list tile)
- Special cards (different border radius, border, gradient)
- All styles use AppColors theme"
```

---

### Task 4: Update main.dart to add design TAB

**Files:**
- Modify: `lib/main.dart`

- [ ] **Step 1: Add import for DesignPage**

Add at the top of main.dart with other page imports:

```dart
import 'pages/design_page.dart';
```

- [ ] **Step 2: Update MainPage to add fourth TAB**

In `_MainPageState`:

Update `_pages`:

```dart
final _pages = const [
  GridPage(),
  ProfilePage(),
  DebugPage(),
  DesignPage(),  // ADD THIS LINE
];
```

Update `BottomNavigationBar.items`:

```dart
BottomNavigationBar(
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });
  },
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.grid_view),
      label: '格子',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: '我的',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.construction),
      label: 'debug',
    ),
    BottomNavigationBarItem(  // ADD THIS ITEM
      icon: Icon(Icons.palette),
      label: '设计',
    ),
  ],
)
```

- [ ] **Step 3: Test the implementation**

Run the app and verify:
1. Four TABs are visible (格子, 我的, debug, 设计)
2. Switching to 设计 TAB shows the page with 6 list items
3. Tapping "按钮设计" navigates to button design page
4. Tapping "卡片设计" navigates to card design page
5. Tapping buttons 3-6 shows "功能开发中" SnackBar
6. All components use correct AppColors theme colors

- [ ] **Step 4: Commit the changes**

```bash
git add lib/main.dart
git commit -m "feat: integrate design TAB into main navigation

- Add DesignPage as fourth TAB in MainPage
- Add palette icon for design TAB
- Import DesignPage in main.dart"
```

---

## Summary

This plan creates a complete design TAB feature with:

1. **DesignPage** - Home page with 6 vertical ListTiles, first two navigate to detail pages, last four show "coming soon"
2. **ButtonDesignPage** - Comprehensive showcase of button styles:
   - Filled buttons (colors, sizes, icons, states)
   - Outlined buttons (colors, border widths, icons)
   - Text buttons, icon buttons, FABs
   - SegmentedButton, ToggleButtons, DropdownButton
3. **CardDesignPage** - Comprehensive showcase of card styles:
   - Basic cards (shadows, colors)
   - Title cards, icon cards
   - Image cards, action cards
   - Special styles (borders, gradients, rounded corners)
4. **MainPage integration** - Fourth TAB added to navigation

All components use the existing AppColors theme for consistency with the app.
