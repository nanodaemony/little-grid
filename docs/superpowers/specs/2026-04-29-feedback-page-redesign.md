# 反馈建议页面重新设计方案

**日期：** 2026-04-29
**状态：** 待实现
**功能不变：** 是，仅 UI 风格优化

---

## 1. 设计目标

参考已有的设置页、登录页、注册页风格，将反馈建议页面优化为**扁平淡色**风格，保持与应用整体设计语言的一致性。

---

## 2. 设计规范

### 2.1 颜色系统

使用已有的 `AppColors` 配色：

| 用途 | 颜色值 | 常量名 |
|------|--------|--------|
| 主色调 | #5B9BD5 | `AppColors.primary` |
| 主色调浅色 | #BDD7EE | `AppColors.primaryLight` |
| 页面背景 | #F5F5F5 | `AppColors.background` |
| 卡片背景 | #FFFFFF | `AppColors.surface` |
| 主要文字 | #333333 | `AppColors.textPrimary` |
| 次要文字 | #666666 | `AppColors.textSecondary` |
| 辅助文字 | #999999 | `AppColors.textTertiary` |
| 边框/分割线 | #E0E0E0 | `AppColors.border` / `AppColors.divider` |

### 2.2 圆角规范

使用 `ThemeConstants` 中定义的圆角：

| 元素 | 圆角值 |
|------|--------|
| 卡片 | 16px (`radiusXLarge`) |
| 输入框 | 8px (`radiusMedium`) |
| 按钮 | 8px (`radiusMedium`) |
| 图片项 | 8px (`radiusMedium`) |

### 2.3 间距规范

| 元素 | 间距值 |
|------|--------|
| 页面左右边距 | 16px (`spacingLarge`) |
| 卡片之间 | 12px |
| 卡片内边距 | 16px |
| 元素之间 | 8px / 12px / 16px |

---

## 3. 页面结构设计

### 3.1 整体布局

```
┌─────────────────────────────────┐
│  [<-]  反馈建议                  │ ← AppBar
├─────────────────────────────────┤
│                                 │
│  ┌───┐                          │ ← 可选顶部图标区域
│  │ 📝 │                          │
│  └───┘                          │
│                                 │
│  ┌───────────────────────────┐  │
│  │ 反馈类型                  │ ← 卡片 1
│  ├───────────────────────────┤  │
│  │  ┌─────┐ ┌─────┐ ┌─────┐ │  │
│  │  │ 💡  │ │ 🐛 │ │ 💭 │ │  │
│  │  │功能 │ │问题 │ │建议 │ │  │
│  │  └─────┘ └─────┘ └─────┘ │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ 详细描述                  │ ← 卡片 2
│  ├───────────────────────────┤  │
│  │ 请详细描述您遇到的问题...  │  │
│  │ ┌───────────────────────┐ │  │
│  │ │  [输入框...]         │ │  │
│  │ │                       │ │  │
│  │ └───────────────────────┘ │  │
│  │                     0/500 │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ 问题截图（可选）  0/10   │ ← 卡片 3
│  ├───────────────────────────┤  │
│  │ ┌───┐ ┌───┐ ┌───┐        │  │
│  │ │ 🖼│ │ 🖼│ │ ➕│        │  │
│  │ └───┘ └───┘ └───┘        │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │      提交反馈            │ ← 提交按钮
│  └───────────────────────────┘  │
│                                 │
└─────────────────────────────────┘
```

---

## 4. 详细组件设计

### 4.1 页面顶部区域

**可选的视觉引导区：**
- 居中显示一个大图标：`Icons.feedback_outlined` 或 `Icons.rate_review_outlined`
- 图标大小：48px
- 图标颜色：`AppColors.primary`
- 上下间距：24px

（可选，如果觉得太冗余可以省略）

---

### 4.2 卡片 1：反馈类型选择

**卡片结构：**
```dart
Container(
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Color(0x14000000),
        blurRadius: 12,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Column(
    children: [
      // 卡片标题
      Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Text(
          '反馈类型',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
      // 选项区域
      Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Row(
          children: [
            _TypeCard(type: 'feature', ...),
            SizedBox(width: 12),
            _TypeCard(type: 'bug', ...),
            SizedBox(width: 12),
            _TypeCard(type: 'suggestion', ...),
          ],
        ),
      ),
    ],
  ),
)
```

**类型卡片 `_TypeCard` 设计：**

| 状态 | 样式 |
|------|------|
| **未选中** | - 白色背景<br>- 1px 边框：`AppColors.border`<br>- 8px 圆角<br>- 图标 + 文字居中<br>- 图标颜色：`AppColors.textSecondary`<br>- 文字颜色：`AppColors.textSecondary` |
| **选中** | - 背景：`AppColors.primaryLight.withOpacity(0.3)`<br>- 2px 边框：`AppColors.primary`<br>- 8px 圆角<br>- 图标颜色：`AppColors.primary`<br>- 文字颜色：`AppColors.primary`<br>- 右上角小勾图标：`Icons.check_circle` (16px) |

**三个类型配置：**

| 类型 | 图标 | 文字 |
|------|------|------|
| 功能反馈 | `Icons.lightbulb_outline` | 功能反馈 |
| 问题报告 | `Icons.bug_report_outlined` | 问题报告 |
| 建议 | `Icons.rate_review_outlined` | 建议 |

---

### 4.3 卡片 2：详细描述

**卡片结构：**
```dart
Container(
  // ... 同样的卡片样式
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 卡片标题
      Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Text('反馈类型', ...),
      ),
      // 提示文字
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          '请详细描述您遇到的问题或建议，最多500字',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ),
      SizedBox(height: 8),
      // 输入框
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            // ...
          ),
        ),
      ),
      // 字数统计
      Padding(
        padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$_currentLength/500',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ),
      ),
    ],
  ),
)
```

**输入框样式：**
- 无边框（已在外层 Container 实现）
- 填充色：透明/白色
- 最小高度：120px (maxLines: 6)
- 内容边距：16px 水平，12px 垂直

---

### 4.4 卡片 3：截图上传

**卡片结构：**
```dart
Container(
  // ... 同样的卡片样式
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // 标题行
      Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('问题截图（可选）', ...),
            if (_selectedImages.isNotEmpty)
              Text(
                '${_selectedImages.length}/10',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
          ],
        ),
      ),
      // 图片网格
      Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: _buildImageGrid(),
      ),
    ],
  ),
)
```

**图片网格设计：**
- 3列布局
- 间距：8px (crossAxisSpacing, mainAxisSpacing)
- 图片项圆角：8px

**空状态（无图片时）：**
```dart
InkWell(
  onTap: _pickImages,
  borderRadius: BorderRadius.circular(8),
  child: Container(
    width: double.infinity,
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
        SizedBox(height: 8),
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
)
```

**有图片时：**
- 显示已选图片，右上角带删除按钮
- 删除按钮：半透明黑色背景 (Colors.black54) + 白色叉号
- 最后显示"添加更多"按钮（如果 <10 张）

---

### 4.5 提交按钮

**按钮样式：**
```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16),
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
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              '提交反馈',
              style: TextStyle(fontSize: 16),
            ),
    ),
  ),
)
```

**按钮位置：**
- 距最后一个卡片：24px
- 距页面底部：32px

---

## 5. 保持不变的功能

以下功能逻辑完全保留，无需修改：

1. 反馈类型选择（feature / bug / suggestion）
2. 描述输入与验证
3. 图片选择（最多 10 张）
4. 图片删除
5. 图片上传服务调用
6. 反馈提交服务调用
7. 成功/失败提示
8. 提交后返回上一页

---

## 6. 实现文件清单

| 文件 | 操作 |
|------|------|
| `app/lib/pages/feedback/feedback_page.dart` | 重写 UI 部分 |

