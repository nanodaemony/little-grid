# 反馈建议页面重新设计 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 重新设计反馈建议页面的 UI 风格，采用分组卡片式设计，与设置页风格保持一致，功能保持不变

**Architecture:** 单文件修改，仅重写 `feedback_page.dart` 的 UI 部分，保留所有现有功能逻辑

**Tech Stack:** Flutter, Provider (现有), ImagePicker (现有)

---

## 文件清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `app/lib/pages/feedback/feedback_page.dart` | 重写 UI | 保留所有状态管理和业务逻辑 |

---

## 实现步骤

### Task 1: 准备工作 - 创建新页面骨架

**Files:**
- Modify: `app/lib/pages/feedback/feedback_page.dart`

- [ ] **Step 1: 备份现有逻辑 (注释)**

在文件顶部添加注释，标记现有代码结构（不需要实际备份，git会处理）

- [ ] **Step 2: 重写 build 方法，创建基础骨架**

替换整个 `build` 方法为以下骨架：

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('反馈建议')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 卡片1: 反馈类型
          _buildTypeCard(),
          const SizedBox(height: 12),
          // 卡片2: 详细描述
          _buildDescriptionCard(),
          const SizedBox(height: 12),
          // 卡片3: 截图上传
          _buildImageCard(),
          const SizedBox(height: 24),
          // 提交按钮
          _buildSubmitButton(),
          const SizedBox(height: 32),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 3: 添加私有方法占位符**

在 `_submit` 方法之后添加以下占位符方法：

```dart
Widget _buildTypeCard() {
  return const SizedBox.shrink();
}

Widget _buildDescriptionCard() {
  return const SizedBox.shrink();
}

Widget _buildImageCard() {
  return const SizedBox.shrink();
}

Widget _buildSubmitButton() {
  return const SizedBox.shrink();
}
```

- [ ] **Step 4: 验证代码可以编译**

Run:
```bash
cd /Users/nano/claude/little-grid/app
flutter analyze lib/pages/feedback/feedback_page.dart
```
Expected: 无错误

---

### Task 2: 实现卡片容器组件

**Files:**
- Modify: `app/lib/pages/feedback/feedback_page.dart`

- [ ] **Step 1: 添加 `_buildSectionCard` 辅助方法**

在私有方法区域添加：

```dart
Widget _buildSectionCard({
  required String title,
  required Widget content,
  EdgeInsets? contentPadding,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
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
        Padding(
          padding: contentPadding ?? const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: content,
        ),
      ],
    ),
  );
}
```

- [ ] **Step 2: 确保导入 AppColors**

检查文件顶部导入，确保有：
```dart
import '../../core/ui/app_colors.dart';
```

- [ ] **Step 3: 验证编译**

Run:
```bash
cd /Users/nano/claude/little-grid/app
flutter analyze lib/pages/feedback/feedback_page.dart
```
Expected: 无错误

---

### Task 3: 实现反馈类型选择卡片

**Files:**
- Modify: `app/lib/pages/feedback/feedback_page.dart`

- [ ] **Step 1: 实现 `_TypeCard` 组件**

在 `_FeedbackPageState` 类中添加私有组件类：

```dart
Widget _buildTypeCard() {
  return _buildSectionCard(
    title: '反馈类型',
    content: Row(
      children: [
        _TypeCard(
          type: 'FEATURE',
          label: '功能反馈',
          icon: Icons.lightbulb_outline,
          isSelected: _selectedType == 'FEATURE',
          onTap: () => setState(() => _selectedType = 'FEATURE'),
        ),
        const SizedBox(width: 12),
        _TypeCard(
          type: 'ISSUE',
          label: '问题报告',
          icon: Icons.bug_report_outlined,
          isSelected: _selectedType == 'ISSUE',
          onTap: () => setState(() => _selectedType = 'ISSUE'),
        ),
        const SizedBox(width: 12),
        _TypeCard(
          type: 'SUGGESTION',
          label: '建议',
          icon: Icons.rate_review_outlined,
          isSelected: _selectedType == 'SUGGESTION',
          onTap: () => setState(() => _selectedType = 'SUGGESTION'),
        ),
      ],
    ),
  );
}
```

然后添加 `_TypeCard` 组件：

```dart
Widget _TypeCard({
  required String type,
  required String label,
  required IconData icon,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryLight.withOpacity(0.3)
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 4, top: 4),
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
```

- [ ] **Step 2: 验证编译**

Run:
```bash
cd /Users/nano/claude/little-grid/app
flutter analyze lib/pages/feedback/feedback_page.dart
```
Expected: 无错误

---

### Task 4: 实现详细描述卡片

**Files:**
- Modify: `app/lib/pages/feedback/feedback_page.dart`

- [ ] **Step 1: 添加字数监听**

在 `initState` 中添加对 `_descriptionController` 的监听：

```dart
@override
void initState() {
  super.initState();
  _descriptionController.addListener(() {
    setState(() {}); // 触发重绘以更新字数
  });
}
```

- [ ] **Step 2: 实现 `_buildDescriptionCard` 方法**

```dart
Widget _buildDescriptionCard() {
  return _buildSectionCard(
    title: '详细描述',
    contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '请详细描述您遇到的问题或建议，最多500字',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 6,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: '请输入反馈内容...',
              border: InputBorder.none,
              counterText: '', // 隐藏默认计数器
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
            ),
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入反馈内容';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${_descriptionController.text.length}/500',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 3: 清理 dispose 方法**

确保 dispose 中依然有 controller 的清理：
```dart
@override
void dispose() {
  _descriptionController.dispose();
  super.dispose();
}
```

- [ ] **Step 4: 验证编译**

Run:
```bash
cd /Users/nano/claude/little-grid/app
flutter analyze lib/pages/feedback/feedback_page.dart
```
Expected: 无错误

---

### Task 5: 实现截图上传卡片

**Files:**
- Modify: `app/lib/pages/feedback/feedback_page.dart`

- [ ] **Step 1: 实现 `_buildImageCard` 方法**

```dart
Widget _buildImageCard() {
  return _buildSectionCard(
    title: '问题截图（可选）',
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_selectedImages.isEmpty)
          _buildEmptyImagePicker()
        else
          _buildImageGrid(),
      ],
    ),
  );
}
```

- [ ] **Step 2: 实现 `_buildEmptyImagePicker` 方法**

```dart
Widget _buildEmptyImagePicker() {
  return InkWell(
    onTap: _pickImages,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 40,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            '点击添加截图',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 3: 实现 `_buildImageGrid` 方法**

```dart
Widget _buildImageGrid() {
  final itemCount = _selectedImages.length + (_selectedImages.length < 10 ? 1 : 0);
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 1,
    ),
    itemCount: itemCount,
    itemBuilder: (context, index) {
      if (index < _selectedImages.length) {
        return _buildImageItem(index);
      } else {
        return _buildAddMoreButton();
      }
    },
  );
}
```

- [ ] **Step 4: 实现 `_buildImageItem` 方法**

```dart
Widget _buildImageItem(int index) {
  return Stack(
    fit: StackFit.expand,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          _selectedImages[index],
          fit: BoxFit.cover,
        ),
      ),
      Positioned(
        top: 4,
        right: 4,
        child: GestureDetector(
          onTap: () => _removeImage(index),
          child: Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ),
    ],
  );
}
```

- [ ] **Step 5: 实现 `_buildAddMoreButton` 方法**

```dart
Widget _buildAddMoreButton() {
  return InkWell(
    onTap: _pickImages,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 28,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 4),
          Text(
            '添加',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 6: 修改卡片标题区域显示数量**

更新 `_buildImageCard` 方法，将数量显示在卡片标题中：

```dart
Widget _buildImageCard() {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
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
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '问题截图（可选）',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              if (_selectedImages.isNotEmpty)
                Text(
                  '${_selectedImages.length}/10',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_selectedImages.isEmpty)
                _buildEmptyImagePicker()
              else
                _buildImageGrid(),
            ],
          ),
        ),
      ],
    ),
  );
}
```

- [ ] **Step 7: 验证编译**

Run:
```bash
cd /Users/nano/claude/little-grid/app
flutter analyze lib/pages/feedback/feedback_page.dart
```
Expected: 无错误

---

### Task 6: 实现提交按钮

**Files:**
- Modify: `app/lib/pages/feedback/feedback_page.dart`

- [ ] **Step 1: 实现 `_buildSubmitButton` 方法**

```dart
Widget _buildSubmitButton() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Form(
      key: _formKey,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  '提交反馈',
                  style: TextStyle(fontSize: 16),
                ),
        ),
      ),
    ),
  );
}
```

注意：`Form` widget 现在放在这里了，需要从 body 中移除原来的 Form。

- [ ] **Step 2: 更新 body - 移除外层 Form**

更新 `build` 方法，移除外层的 `Form` widget：

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('反馈建议')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTypeCard(),
          const SizedBox(height: 12),
          _buildDescriptionCard(),
          const SizedBox(height: 12),
          _buildImageCard(),
          const SizedBox(height: 24),
          _buildSubmitButton(),
          const SizedBox(height: 32),
        ],
      ),
    ),
  );
}
```

- [ ] **Step 3: 验证编译**

Run:
```bash
cd /Users/nano/claude/little-grid/app
flutter analyze lib/pages/feedback/feedback_page.dart
```
Expected: 无错误

---

### Task 7: 完整测试与验证

**Files:**
- Test: Manual testing in app

- [ ] **Step 1: 运行应用并导航到反馈页面**

Run:
```bash
cd /Users/nano/claude/little-grid/app
flutter run
```
然后导航到反馈建议页面

- [ ] **Step 2: 测试反馈类型选择**
  - 点击三个不同的类型，确认选中状态正确
  - 确认选中时有蓝色边框和背景，有对勾图标

- [ ] **Step 3: 测试描述输入**
  - 输入文字，确认右下角字数统计正确更新
  - 确认最多500字限制

- [ ] **Step 4: 测试图片选择**
  - 点击添加截图，选择图片
  - 确认图片正确显示
  - 点击删除按钮，确认图片删除
  - 确认最多10张限制

- [ ] **Step 5: 测试提交流程**
  - 不填内容点击提交，验证验证提示
  - 填写内容后提交，验证加载状态
  - 验证成功/失败提示

- [ ] **Step 6: 确认功能完全保留**
  - 所有原有功能正常工作
  - 没有引入新的 bug

---

### Task 8: 最终清理与提交

**Files:**
- Modify: `app/lib/pages/feedback/feedback_page.dart`

- [ ] **Step 1: 移除所有旧代码**

确认文件中不再有旧的 build 实现（已被完全替换）

- [ ] **Step 2: 格式化代码**

Run:
```bash
cd /Users/nano/claude/little-grid/app
flutter format lib/pages/feedback/feedback_page.dart
```

- [ ] **Step 3: 最终分析检查**

Run:
```bash
cd /Users/nano/claude/little-grid/app
flutter analyze lib/pages/feedback/feedback_page.dart
```
Expected: 无错误，无警告

- [ ] **Step 4: 提交代码**

```bash
cd /Users/nano/claude/little-grid
git add app/lib/pages/feedback/feedback_page.dart
git add docs/superpowers/specs/2026-04-29-feedback-page-redesign.md
git add docs/superpowers/plans/2026-04-29-feedback-page-redesign.md
git commit -m "feat: redesign feedback page with card-based UI

- Adopt settings page style card design
- Implement card-based type selection
- Minimal border input fields
- Keep all existing functionality intact"
```

---

## 计划完成！

