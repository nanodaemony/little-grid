# 设计 TAB 功能设计文档

**Date:** 2026-04-19
**Status:** Draft
**Base Commit:** 8dd24c8

## 概述

在 APP 底部导航栏新增一个 "设计" TAB，用于展示和沉淀 UI 组件设计。该页面包含 6 个功能入口按钮，其中前两个按钮分别跳转到按钮设计页和卡片设计页，用于展示各种通用的按钮和卡片组件样式。

## 需求

1. **新增 TAB**: 在现有底部导航栏最后（第四个）添加 "设计" TAB
2. **六个按钮**: 设计主页垂直列表显示 6 个按钮：
   - 按钮设计 → 跳转到按钮设计页
   - 卡片设计 → 跳转到卡片设计页
   - 按钮3 → 显示"功能开发中"提示
   - 按钮4 → 显示"功能开发中"提示
   - 按钮5 → 显示"功能开发中"提示
   - 按钮6 → 显示"功能开发中"提示
3. **按钮设计页**: 展示多种按钮样式、风格、颜色供选择
4. **卡片设计页**: 展示多种卡片样式（纯文字、标题卡片、带icon、带图等）

## 架构设计

### 1. 底部导航栏修改 (MainPage)

**修改内容:**

```dart
// main.dart 中的 MainPage 类

final _pages = const [
  GridPage(),
  ProfilePage(),
  DebugPage(),
  DesignPage(),  // 新增
];

// ...

BottomNavigationBar(
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
    BottomNavigationBarItem(  // 新增
      icon: Icon(Icons.palette),
      label: '设计',
    ),
  ],
)
```

### 2. 设计主页 (DesignPage)

**文件路径:** `lib/pages/design_page.dart`

**布局:** 垂直 ListView 布局

```
┌─────────────────────────┐
│   [按钮设计] >          │  <- ListTile
├─────────────────────────┤
│   [卡片设计] >          │  <- ListTile
├─────────────────────────┤
│   [按钮3] >             │  <- ListTile (点击提示)
├─────────────────────────┤
│   [按钮4] >             │  <- ListTile (点击提示)
├─────────────────────────┤
│   [按钮5] >             │  <- ListTile (点击提示)
├─────────────────────────┤
│   [按钮6] >             │  <- ListTile (点击提示)
└─────────────────────────┘
```

**组件:**
- 使用 `Scaffold` 带 AppBar（标题"设计"）
- `ListView` 包含 6 个 `ListTile`
- 前两个 `ListTile` 有 `onTap` 跳转功能
- 后四个 `ListTile` 点击显示 `SnackBar` 提示"功能开发中"

**样式:**
- 遵循现有 APP 设计风格
- 使用 `AppColors.primary` 作为图标颜色
- 与 `ProfilePage` 的菜单项保持一致

### 3. 按钮设计页 (ButtonDesignPage)

**文件路径:** `lib/pages/design/button_design_page.dart`

**布局:** 可滚动的 `ListView`，分多个 Section 展示

**展示内容:**

#### Section 1: 填充按钮 (ElevatedButton)
- 默认样式
- 不同颜色（primary、success、warning、error、info）
- 不同大小（大、中、小）
- 带图标
- 禁用状态
- 加载中状态

#### Section 2: 轮廓按钮 (OutlinedButton)
- 默认样式
- 不同颜色
- 不同边框粗细
- 带图标
- 禁用状态

#### Section 3: 文字按钮 (TextButton)
- 默认样式
- 不同颜色
- 带图标
- 禁用状态

#### Section 4: 图标按钮 (IconButton)
- 默认样式
- 不同颜色
- 不同大小
- 填充样式 (FilledButton.icon / IconButton + Container)

#### Section 5: 浮动操作按钮 (FloatingActionButton)
- 标准 FAB
- 小型 FAB
- 扩展 FAB
- 不同颜色

#### Section 6: 其他按钮
- SegmentedButton
- ToggleButtons
- DropdownButton

**样式:**
- 使用 `AppColors` 主题色
- 每个 Section 带标题
- 适当的间距分隔
- 代码中添加注释说明每个样式的用途

### 4. 卡片设计页 (CardDesignPage)

**文件路径:** `lib/pages/design/card_design_page.dart`

**布局:** 可滚动的 `ListView`，分多个 Section 展示

**展示内容:**

#### Section 1: 基础卡片
- 纯文字卡片
- 带内边距的文字卡片
- 带阴影的卡片
- 无阴影的卡片

#### Section 2: 标题卡片
- 大标题 + 内容卡片
- 小标题 + 内容卡片
- 双标题卡片（主标题 + 副标题）

#### Section 3: 带 Icon 的卡片
- 左侧 Icon + 文字
- 顶部 Icon + 文字
- 圆形 Icon 背景
- 方形 Icon 背景

#### Section 4: 带图片的卡片
- 顶部图片 + 内容
- 背景图片 + 文字覆盖
- 左侧图片 + 右侧内容
- 圆角图片卡片

#### Section 5: 带操作的卡片
- 底部操作按钮卡片
- 右侧箭头卡片（可点击）
- 滑动操作卡片
- 长按菜单卡片

#### Section 6: 特殊样式卡片
- 圆角大小变化
- 边框卡片
- 渐变背景卡片
- 玻璃拟态风格（可选）

**样式:**
- 使用 `AppColors` 主题色
- 每个 Section 带标题
- 适当的间距分隔
- 代码中添加注释说明每个样式的用途

## 文件变更

| 文件 | 变更类型 | 说明 |
|------|----------|------|
| `lib/main.dart` | 修改 | 添加设计 TAB |
| `lib/pages/design_page.dart` | 新增 | 设计主页 |
| `lib/pages/design/button_design_page.dart` | 新增 | 按钮设计页 |
| `lib/pages/design/card_design_page.dart` | 新增 | 卡片设计页 |

## 依赖

- 使用现有 `provider` 包（如需要）
- 无需新增依赖

## 测试考虑

1. 验证底部 TAB 切换正常
2. 验证设计主页 6 个按钮显示正常
3. 验证前两个按钮跳转功能正常
4. 验证后四个按钮提示功能正常
5. 验证按钮设计页滚动正常
6. 验证卡片设计页滚动正常
7. 验证所有组件使用正确的主题色

## 后续扩展

- 实现按钮3-6对应的具体设计页
- 从设计页中提取通用组件到 `lib/widgets/` 目录
- 添加组件代码复制功能
- 添加组件收藏功能
