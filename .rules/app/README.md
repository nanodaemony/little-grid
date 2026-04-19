# Flutter 移动端应用规范

## 技术栈版本

- Flutter SDK: >=3.0.0 <4.0.0
- Dart SDK: >=3.0.0
- 状态管理: provider: ^6.1.1
- 数据库: sqflite: ^2.3.0

## 目录结构

```
app/lib/
├── main.dart                    # 应用入口
├── core/                        # 核心模块
│   ├── constants/               # 常量定义
│   ├── models/                  # 数据模型
│   ├── services/                # 服务层
│   │   ├── tool_registry.dart   # 工具注册中心
│   │   ├── database_service.dart
│   │   └── ...
│   └── ui/                      # UI组件
│       ├── app_colors.dart
│       └── theme.dart
├── pages/                       # 页面
├── providers/                   # 状态管理
└── tools/                       # 工具模块
    ├── coin/
    │   ├── coin_tool.dart       # 工具注册
    │   ├── coin_page.dart       # 主页面
    │   ├── coin_models.dart     # 数据模型
    │   └── coin_service.dart    # 业务逻辑
    └── ...
```

## 命名规范

### 文件命名
- 小写 + 下划线：`xxx_tool.dart`, `xxx_page.dart`
- 组件文件：`xxx_card.dart`, `xxx_dialog.dart`

### 类命名
- 大驼峰：`XxxTool`, `XxxPage`, `XxxItem`
- 私有组件：`_XxxCard`, `_XxxDialog`

### 变量命名
- 小驼峰：`_items`, `_isLoading`, `_selectedItem`
- 常量：`kDefaultValue` 或直接使用 `const`

### 方法命名
- 动词开头：`_loadData()`, `_deleteItem()`, `_showDialog()`
- 构建方法：`_buildBody()`, `_buildEmptyState()`

## 代码规范

### 工具模块实现

每个工具必须实现 `ToolModule` 接口，并在 `main.dart` 中注册。

详见 [patterns/new_tool.md](./patterns/new_tool.md)

### 消息通知接入

APP 支持两种通知方式：APP内横幅通知和系统下拉框通知。

详见 [patterns/notifications.md](./patterns/notifications.md)

### 颜色使用

使用 `AppColors` 中定义的颜色常量，**不要硬编码颜色值**：

```dart
import '../../core/ui/app_colors.dart';

// 主色调
AppColors.primary          // 主色 #5B9BD5
AppColors.primaryLight     // 浅主色
AppColors.primaryDark      // 深主色

// 文字颜色
AppColors.textPrimary      // 主文字 #333333
AppColors.textSecondary    // 次要文字 #666666
AppColors.textTertiary     // 辅助文字 #999999
```

### 数据库表升级

1. 升级数据库版本（`app_constants.dart`）：
```dart
static const int dbVersion = 2;  // 递增
```

2. 添加建表语句（`database_service.dart` 的 `_onCreate`）

3. 添加升级逻辑（`database_service.dart` 的 `_onUpgrade`）

## 常用命令

```bash
# 安装依赖
flutter pub get

# 运行应用
flutter run

# 分析代码
flutter analyze

# 运行测试
flutter test

# 构建 APK
flutter build apk --release
```

## 检查清单

新增工具时确认：
- [ ] 文件结构符合规范
- [ ] 实现了 `ToolModule` 接口
- [ ] 在 `main.dart` 中注册
- [ ] 使用 `AppColors` 颜色常量
- [ ] 空状态有友好提示
- [ ] 删除操作有确认弹窗
- [ ] 数据库表已正确创建和升级
- [ ] 界面文字使用中文
