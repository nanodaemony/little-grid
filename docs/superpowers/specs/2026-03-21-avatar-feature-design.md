# 头像替换功能设计文档

**日期**: 2026-03-21
**功能**: 用户头像替换
**范围**: AppDrawer（抽屉页）+ ProfilePage（我的页面）

## 功能概述

支持用户在抽屉页和"我的"页面点击头像进行更换，提供相册选择和预设默认头像两种方式。

## 设计决策

### 头像选择来源
- **相册选择**: 从系统相册选择图片
- **预设默认头像**: 提供 4-6 个预设头像供选择
- **暂不实现相机拍照**: 保持功能简洁

### 图片存储方案
- 图片复制到应用私有目录 (`/avatars/`)
- 头像路径存储在 SQLite 数据库
- 避免依赖外部文件（相册图片可能被删除）

### 状态管理方案
- 扩展 `AppProvider` 全局管理头像状态
- 修改后自动通知所有监听页面同步更新
- 页面打开时从 Provider 读取当前状态

## 交互流程

```
点击头像
    ↓
弹出底部选择菜单 (相册 | 默认头像 | 取消)
    ↓
┌─────────────────┴─────────────────┐
↓                                   ↓
选择相册                          选择默认头像
    ↓                                   ↓
系统图片选择器                      弹窗展示预设头像网格
    ↓                                   ↓
裁剪/压缩                          选择后立即应用
    ↓
复制到应用目录
    ↓
更新 AppProvider 状态
    ↓
通知所有页面刷新
```

## 新增依赖

```yaml
image_cropper: ^5.0.0          # 图片裁剪
flutter_image_compress: ^2.0.0 # 图片压缩
path_provider: ^2.1.0          # 获取应用目录
```

## 组件设计

### AvatarPicker 组件

底部弹出菜单，提供操作选项：
- 从相册选择
- 选择默认头像
- 取消

### DefaultAvatarSelector 组件

弹窗展示预设头像网格，支持滚动选择。

## 存储设计

### 新增数据库表

```sql
CREATE TABLE user_avatar (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  avatar_path TEXT NOT NULL,
  updated_at TEXT NOT NULL
);
```

或使用现有 `user_settings` 表，添加 `avatar_path` 键值对。

**决策**: 使用现有 `user_settings` 表，key 为 `avatar_path`。

## API 设计

### StorageService 新增方法

```dart
static Future<void> saveAvatarPath(String path);
static Future<String?> getAvatarPath();
```

### AppProvider 新增属性

```dart
String? _avatarPath;
String? get avatarPath => _avatarPath;

Future<void> loadAvatar();
Future<void> updateAvatar(String path);
```

## 默认头像资源

放置在 `assets/avatars/` 目录：
- avatar_1.png (蓝色)
- avatar_2.png (绿色)
- avatar_3.png (紫色)
- avatar_4.png (橙色)

## 文件变更清单

1. `pubspec.yaml` - 添加依赖
2. `lib/core/services/storage_service.dart` - 添加头像存储方法
3. `lib/providers/app_provider.dart` - 添加头像状态管理
4. `lib/widgets/avatar_picker.dart` - 新增：头像选择器组件
5. `lib/widgets/default_avatar_selector.dart` - 新增：默认头像选择组件
6. `lib/widgets/app_drawer.dart` - 修改：集成头像显示和更换
7. `lib/pages/profile_page.dart` - 修改：集成头像显示和更换

## 测试策略

1. StorageService 单元测试 - 验证存储/读取头像路径
2. AppProvider 测试 - 验证状态更新和通知
3. Widget 测试 - 验证头像选择器交互
4. 集成测试 - 验证页面间同步
