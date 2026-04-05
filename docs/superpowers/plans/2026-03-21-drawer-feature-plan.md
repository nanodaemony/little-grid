# 抽屉功能实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现左侧抽屉导航功能，包含用户信息头部、菜单项（设置、关于、反馈）

**Architecture:** 创建独立的 `AppDrawer` widget 组件，在 `GridPage` 的 Scaffold 中通过 `drawer` 参数引入。组件使用 StatefulWidget 管理昵称状态，点击菜单项关闭抽屉后跳转对应页面。

**Tech Stack:** Flutter, Dart, Material Design

---

## 文件结构

| 文件 | 操作 | 说明 |
|------|------|------|
| `lib/widgets/app_drawer.dart` | 创建 | 抽屉组件，包含 Header、菜单项、Footer |
| `lib/pages/grid_page.dart` | 修改 | 添加 drawer 参数，连接打开抽屉按钮 |
| `test/widgets/app_drawer_test.dart` | 创建 | 抽屉组件的单元测试 |

---

## Task 1: 创建 AppDrawer 组件骨架

**Files:**
- Create: `lib/widgets/app_drawer.dart`
- Test: `test/widgets/app_drawer_test.dart`

- [ ] **Step 1: 创建测试文件，测试 AppDrawer 渲染**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/widgets/app_drawer.dart';

void main() {
  group('AppDrawer', () {
    testWidgets('renders drawer with header and menu items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            drawer: const AppDrawer(),
            body: Container(),
          ),
        ),
      );

      // Open drawer
      final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
      scaffold.openDrawer();
      await tester.pumpAndSettle();

      // Verify header elements
      expect(find.text('用户'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);

      // Verify menu items
      expect(find.text('设置'), findsOneWidget);
      expect(find.text('关于'), findsOneWidget);
      expect(find.text('反馈'), findsOneWidget);

      // Verify version
      expect(find.text('v1.0.0'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `cd /Users/nano/claude/littlegrid/app && flutter test test/widgets/app_drawer_test.dart`

Expected: FAIL - "Target of URI doesn't exist: 'package:app/widgets/app_drawer.dart'"

- [ ] **Step 3: 创建 AppDrawer 组件骨架**

```dart
import 'package:flutter/material.dart';
import '../core/ui/app_colors.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _nickname = '用户';

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
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('反馈'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
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
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nickname
            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _nickname,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: 运行测试确认通过**

Run: `cd /Users/nano/claude/littlegrid/app && flutter test test/widgets/app_drawer_test.dart`

Expected: PASS - All tests passed

- [ ] **Step 5: Commit**

```bash
cd /Users/nano/claude/littlegrid && \
git add app/lib/widgets/app_drawer.dart app/test/widgets/app_drawer_test.dart && \
git commit -m "feat: add AppDrawer component skeleton"
```

---

## Task 2: 实现昵称编辑功能

**Files:**
- Modify: `lib/widgets/app_drawer.dart`
- Modify: `test/widgets/app_drawer_test.dart`

- [ ] **Step 1: 添加昵称编辑测试**

在 `test/widgets/app_drawer_test.dart` 中添加：

```dart
testWidgets('can edit nickname', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        drawer: const AppDrawer(),
        body: Container(),
      ),
    ),
  );

  // Open drawer
  final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
  scaffold.openDrawer();
  await tester.pumpAndSettle();

  // Tap nickname to edit
  await tester.tap(find.text('用户'));
  await tester.pumpAndSettle();

  // Verify dialog appears
  expect(find.text('修改昵称'), findsOneWidget);

  // Enter new nickname
  await tester.enterText(find.byType(TextField), '新昵称');

  // Tap save
  await tester.tap(find.text('保存'));
  await tester.pumpAndSettle();

  // Verify nickname updated
  expect(find.text('新昵称'), findsOneWidget);
});
```

- [ ] **Step 2: 运行测试确认失败**

Run: `cd /Users/nano/claude/littlegrid/app && flutter test test/widgets/app_drawer_test.dart`

Expected: FAIL - "Expected: exactly one matching node, found zero"

- [ ] **Step 3: 实现昵称编辑功能**

在 `lib/widgets/app_drawer.dart` 的 `_AppDrawerState` 中添加：

```dart
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
```

修改 `_buildHeader` 中昵称的 `GestureDetector`：

```dart
GestureDetector(
  onTap: _editNickname,
  // ... existing code
)
```

- [ ] **Step 4: 运行测试确认通过**

Run: `cd /Users/nano/claude/littlegrid/app && flutter test test/widgets/app_drawer_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd /Users/nano/claude/littlegrid && \
git add app/lib/widgets/app_drawer.dart app/test/widgets/app_drawer_test.dart && \
git commit -m "feat: add nickname editing in drawer"
```

---

## Task 3: 实现头像点击提示

**Files:**
- Modify: `lib/widgets/app_drawer.dart`
- Modify: `test/widgets/app_drawer_test.dart`

- [ ] **Step 1: 添加头像点击测试**

在 `test/widgets/app_drawer_test.dart` 中添加：

```dart
testWidgets('shows todo snackbar when tapping avatar', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        drawer: const AppDrawer(),
        body: Container(),
      ),
    ),
  );

  // Open drawer
  final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
  scaffold.openDrawer();
  await tester.pumpAndSettle();

  // Tap avatar
  await tester.tap(find.byIcon(Icons.person));
  await tester.pumpAndSettle();

  // Verify snackbar appears
  expect(find.text('头像功能即将上线'), findsOneWidget);
});
```

- [ ] **Step 2: 运行测试确认失败**

Run: `cd /Users/nano/claude/littlegrid/app && flutter test test/widgets/app_drawer_test.dart`

Expected: FAIL

- [ ] **Step 3: 实现头像点击提示**

在 `_AppDrawerState` 中添加：

```dart
void _onAvatarTap() {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('头像功能即将上线'),
      duration: Duration(seconds: 2),
    ),
  );
}
```

修改 `_buildHeader` 中头像的 `GestureDetector`：

```dart
GestureDetector(
  onTap: _onAvatarTap,
  // ... existing code
)
```

- [ ] **Step 4: 运行测试确认通过**

Run: `cd /Users/nano/claude/littlegrid/app && flutter test test/widgets/app_drawer_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd /Users/nano/claude/littlegrid && \
git add app/lib/widgets/app_drawer.dart app/test/widgets/app_drawer_test.dart && \
git commit -m "feat: add avatar tap todo message"
```

---

## Task 4: 添加使用统计展示

**Files:**
- Modify: `lib/widgets/app_drawer.dart`
- Modify: `test/widgets/app_drawer_test.dart`

- [ ] **Step 1: 添加统计测试**

在 `test/widgets/app_drawer_test.dart` 中添加：

```dart
testWidgets('displays usage stats', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        drawer: const AppDrawer(),
        body: Container(),
      ),
    ),
  );

  // Open drawer
  final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
  scaffold.openDrawer();
  await tester.pumpAndSettle();

  // Verify stats text (format: "已使用 X 个工具")
  expect(find.textContaining('已使用'), findsOneWidget);
  expect(find.textContaining('个工具'), findsOneWidget);
});
```

- [ ] **Step 2: 运行测试确认失败**

Run: `cd /Users/nano/claude/littlegrid/app && flutter test test/widgets/app_drawer_test.dart`

Expected: FAIL - 找不到包含"已使用"的文本

- [ ] **Step 3: 实现使用统计**

在 `_buildHeader` 的昵称下方添加统计文本（先使用静态数字）：

```dart
const SizedBox(height: 8),
Text(
  '已使用 4 个工具',
  style: TextStyle(
    fontSize: 14,
    color: Colors.white.withOpacity(0.7),
  ),
),
```

- [ ] **Step 4: 运行测试确认通过**

Run: `cd /Users/nano/claude/littlegrid/app && flutter test test/widgets/app_drawer_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd /Users/nano/claude/littlegrid && \
git add app/lib/widgets/app_drawer.dart app/test/widgets/app_drawer_test.dart && \
git commit -m "feat: add usage stats display in drawer header"
```

---

## Task 5: 实现菜单项导航

**Files:**
- Modify: `lib/widgets/app_drawer.dart`
- Create: `lib/pages/about_dialog.dart`（可选，如已存在则复用）
- Modify: `test/widgets/app_drawer_test.dart`

- [ ] **Step 1: 添加导航测试**

在 `test/widgets/app_drawer_test.dart` 中添加：

```dart
testWidgets('navigates to settings page', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        drawer: const AppDrawer(),
        body: Container(),
      ),
      routes: {
        '/settings': (context) => const Scaffold(body: Text('Settings Page')),
      },
    ),
  );

  // Open drawer
  final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold));
  scaffold.openDrawer();
  await tester.pumpAndSettle();

  // Tap settings
  await tester.tap(find.text('设置'));
  await tester.pumpAndSettle();

  // Verify drawer is closed and navigated
  expect(find.text('Settings Page'), findsOneWidget);
});
```

- [ ] **Step 2: 运行测试确认失败**

Run: `cd /Users/nano/claude/littlegrid/app && flutter test test/widgets/app_drawer_test.dart`

Expected: FAIL

- [ ] **Step 3: 实现菜单项导航**

修改 `lib/widgets/app_drawer.dart`，添加必要的 import：

```dart
import '../pages/settings_page.dart';
```

修改菜单项的 `onTap`：

```dart
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('反馈功能即将上线')),
    );
  },
),
```

添加关于对话框方法：

```dart
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
```

- [ ] **Step 4: 运行测试确认通过**

Run: `cd /Users/nano/claude/littlegrid/app && flutter test test/widgets/app_drawer_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd /Users/nano/claude/littlegrid && \
git add app/lib/widgets/app_drawer.dart app/test/widgets/app_drawer_test.dart && \
git commit -m "feat: add drawer menu navigation"
```

---

## Task 6: 在 GridPage 中集成抽屉

**Files:**
- Modify: `lib/pages/grid_page.dart`
- Modify: `test/pages/grid_page_test.dart`（如不存在则创建）

- [ ] **Step 1: 创建/修改 GridPage 测试**

在 `test/pages/grid_page_test.dart` 中添加/修改：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/pages/grid_page.dart';
import 'package:app/providers/app_provider.dart';
import 'package:provider/provider.dart';

void main() {
  group('GridPage', () {
    testWidgets('opens drawer when menu button is tapped', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AppProvider()),
          ],
          child: const MaterialApp(
            home: GridPage(),
          ),
        ),
      );

      // Wait for init
      await tester.pumpAndSettle();

      // Tap menu button
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify drawer is open (contains drawer content)
      expect(find.text('用户'), findsOneWidget);
      expect(find.text('设置'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 2: 运行测试确认失败**

Run: `cd /Users/nano/claude/littlegrid/app && flutter test test/pages/grid_page_test.dart`

Expected: FAIL - 找不到 '用户' 文本（抽屉未添加）

- [ ] **Step 3: 在 GridPage 中集成抽屉**

修改 `lib/pages/grid_page.dart`：

添加 import：

```dart
import '../widgets/app_drawer.dart';
```

修改 `build` 方法中的 `Scaffold`，添加 `drawer` 参数：

```dart
return Scaffold(
  appBar: AppBar(
    leading: IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    ),
    title: const Text('小方格'),
    actions: [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () {
          // TODO: 搜索
        },
      ),
    ],
  ),
  drawer: const AppDrawer(),  // <-- 添加这一行
  body: Consumer<AppProvider>(
    // ... existing code
  ),
);
```

- [ ] **Step 4: 运行测试确认通过**

Run: `cd /Users/nano/claude/littlegrid/app && flutter test test/pages/grid_page_test.dart`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd /Users/nano/claude/littlegrid && \
git add app/lib/pages/grid_page.dart app/test/pages/grid_page_test.dart && \
git commit -m "feat: integrate drawer into GridPage"
```

---

## Task 7: 最终验证

**Files:**
- All modified files

- [ ] **Step 1: 运行所有测试**

Run: `cd /Users/nano/claude/littlegrid/app && flutter test`

Expected: All tests pass

- [ ] **Step 2: 检查代码格式**

Run: `cd /Users/nano/claude/littlegrid/app && flutter analyze`

Expected: No issues found

- [ ] **Step 3: 最终提交**

```bash
cd /Users/nano/claude/littlegrid && \
git status && \
echo "Review changes above, then commit if all looks good"
```

---

## 实现完成检查清单

- [ ] `lib/widgets/app_drawer.dart` 组件完整实现
- [ ] 抽屉头部：渐变背景、头像、昵称、统计
- [ ] 点击昵称可编辑
- [ ] 点击头像显示 TODO 提示
- [ ] 菜单项：设置、关于、反馈
- [ ] 设置跳转 SettingsPage
- [ ] 关于弹出 AboutDialog
- [ ] 反馈显示 TODO SnackBar
- [ ] GridPage 集成抽屉，点击 menu 图标打开
- [ ] 所有测试通过
- [ ] 代码格式检查通过
