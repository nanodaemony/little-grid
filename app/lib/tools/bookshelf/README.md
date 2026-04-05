# 书架工具 (Bookshelf)

## 概述

书架工具是一个用于追踪和管理个人阅读、观影、游戏等内容的工具。支持分类管理、评分、标签、观看进度记录等功能。

## 功能特性

### 分类管理
- 创建、编辑、删除分类
- 拖拽排序
- 默认分类：书籍、电影、电视剧、动漫、游戏

### 条目管理
- 添加/编辑/删除条目
- 支持封面图片（可上传）
- 记录评分（1-10星）
- 记录观看进度
- 添加标签
- 记录日期（开始、结束、完成）
- 写评论
- 标记推荐

### 快速操作
- 快速添加对话框
- 搜索功能
- 下拉刷新

## 数据模型

### Category (分类)
```dart
- id: int
- name: String
- sort: int
- createTime: DateTime?
- updateTime: DateTime?
```

### Item (条目)
```dart
- id: int
- categoryId: int
- title: String
- coverUrl: String
- summary: String?
- startDate: DateTime?
- endDate: DateTime?
- finishDate: DateTime?
- author: String?
- rating: int? (1-10)
- review: String?
- progress: String?
- isRecommended: bool?
- tags: List<String>?
- createTime: DateTime?
- updateTime: DateTime?
```

### Tag (标签)
```dart
- id: int
- name: String
- createTime: DateTime?
- updateTime: DateTime?
```

## API 端点

### 分类 API
- `GET /api/tools/bookshelf/categories` - 获取所有分类
- `POST /api/tools/bookshelf/categories` - 创建分类
- `PUT /api/tools/bookshelf/categories/{id}` - 更新分类
- `DELETE /api/tools/bookshelf/categories/{id}` - 删除分类

### 条目 API
- `GET /api/tools/bookshelf/items?categoryId={id}` - 获取条目列表
- `GET /api/tools/bookshelf/items/{id}` - 获取条目详情
- `POST /api/tools/bookshelf/items` - 创建条目
- `PUT /api/tools/bookshelf/items/{id}` - 更新条目
- `DELETE /api/tools/bookshelf/items/{id}` - 删除条目

### 标签 API
- `GET /api/tools/bookshelf/tags` - 获取所有标签
- `POST /api/tools/bookshelf/tags` - 创建标签

## 使用示例

### 添加新条目
```dart
final item = await BookshelfApi.createItem(
  categoryId: 1,
  title: '三体',
  coverUrl: 'https://example.com/cover.jpg',
  author: '刘慈欣',
  summary: '科幻小说',
  rating: 9,
);
```

### 获取分类的条目
```dart
final items = await BookshelfApi.getItems(categoryId: 1);
```

### 使用 Provider
```dart
// 在 Widget 中使用
final provider = context.watch<BookshelfProvider>();

// 获取当前选中的分类
final category = provider.selectedCategory;

// 获取当前分类的条目
final items = provider.items;

// 选择分类
provider.selectCategory(newCategory);

// 添加条目
provider.addItem(newItem);
```

## 文件结构

```
app/lib/tools/bookshelf/
├── bookshelf_page.dart          # 主页面
├── bookshelf_tool.dart          # 工具模块
├── models/                     # 数据模型
│   ├── category.dart
│   ├── item.dart
│   └── tag.dart
├── providers/
│   └── bookshelf_provider.dart   # 状态管理
├── services/
│   └── bookshelf_api.dart        # API 服务
├── widgets/                    # UI 组件
│   ├── category_tab.dart
│   ├── item_card.dart
│   ├── rating_widget.dart
│   ├── tag_selector.dart
│   └── date_picker_field.dart
└── pages/                      # 页面
    ├── category_page.dart
    ├── item_detail_page.dart
    └── add_item_dialog.dart
```

## 开发说明

### 依赖
- `http` - HTTP 请求
- `provider` - 状态管理
- `image_picker` - 图片选择和上传

### 状态管理
使用 `ChangeNotifier` 模式，`BookshelfProvider` 管理以下状态：
- 当前分类列表
- 当前选中的分类
- 当前分类的条目列表
- 标签列表
- 加载状态

### 后端
后端使用 Spring Boot + JPA 实现，位于：
`backend/eladmin-tools/src/main/java/com/littlegrid/modules/bookshelf/`

## 未来改进

- [ ] 集成豆瓣 API 智能搜索
- [ ] 导入/导出功能
- [ ] 统计图表（按月/年）
- [ ] 云端同步
- [ ] 分享功能
