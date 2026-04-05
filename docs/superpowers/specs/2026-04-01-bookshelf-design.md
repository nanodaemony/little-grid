# 书架功能设计文档

**日期**: 2026-04-01
**版本**: 1.0
**状态**: 待实现

---

## 1. 概述

书架功能允许用户记录和管理看过的各种内容，包括书、电影、电视剧、番剧、游戏等。用户可以创建分类，在每个分类下添加条目，条目以卡片形式展示。

### 1.1 核心特性

- 分类管理：默认5个分类，支持用户自定义
- 条目管理：卡片展示，支持增删改查
- 详情页：查看完整信息，支持编辑
- 图片上传：使用服务器存储
- 评分系统：1-10分评价
- 标签系统：支持多标签分类
- 观看进度：记录观看进度
- 推荐标记：标记为可推荐

### 1.2 技术选型

- **后端**: Spring Boot 3.2.5, JPA
- **前端**: Flutter, Provider
- **存储**: MySQL
- **集成位置**: `eladmin-tools` 模块

---

## 2. 数据模型设计

### 2.1 分类表 (bookshelf_category)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 主键 |
| name | VARCHAR(50) | NOT NULL | 分类名称 |
| sort | INT | DEFAULT 0 | 排序 |
| created_by | BIGINT | NOT NULL | 创建用户ID |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE | 更新时间 |

**默认分类数据**：
- 书 (sort=1)
- 电影 (sort=2)
- 电视剧 (sort=3)
- 番剧 (sort=4)
- 游戏 (sort=5)

### 2.2 条目表 (bookshelf_item)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 主键 |
| category_id | BIGINT | NOT NULL, FK → category.id | 分类ID |
| title | | VARCHAR(100) | NOT NULL | 标题 |
| cover_url | VARCHAR(500) | NOT NULL | 封面图片URL |
| summary | VARCHAR(200) | | 一句话简介 |
| start_date | DATE | | 开始观看日期 |
| end_date | DATE | | 结束观看日期 |
| finish_date | DATE | | 完成日期 |
| author | VARCHAR(100) | | 作者/导演 |
| rating | INT | CHECK (rating BETWEEN 1 AND 10) | 评分 1-10 |
| review | TEXT | | 详细评价 |
| progress | VARCHAR(50) | | 观看进度 |
| is_recommended | TINYINT | DEFAULT 0 | 是否推荐 (0/1) |
| created_by | BIGINT | NOT NULL | 创建用户ID |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| update_time | DATETIME | DEFAULT CURRENT_TIMESTAMP ON UPDATE | 更新时间 |

**索引**：
- idx_category_user: (category_id, created_by)
- idx_create_time: (create_time DESC)

### 2.3 标签表 (bookshelf_tag)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 主键 |
| name | VARCHAR(30) | NOT NULL, UNIQUE | 标签名称 |
| created_by | BIGINT | NOT NULL | 创建用户ID |
| create_time | DATETIME | DEFAULT CURRENT_TIMESTAMP | 创建时间 |

### 2.4 条目标签关联表 (bookshelf_item_tag)

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| item_id | BIGINT | FK → item.id | 条目ID |
| tag_id | BIGINT | FK → tag.id | 标签ID |

**唯一索引**: uk_item_tag (item_id, tag_id)

---

## 3. 后端 API 设计

### 3.1 基础路径

- **基础URL**: `/api/tools/bookshelf`
- **认证**: 所有接口需要登录认证
- **权限**: 用户只能访问自己创建的数据

### 3.2 分类管理接口

#### 获取分类列表
```
GET /api/tools/bookshelf/categories
```
**响应**:
```json
{
  "code": 200,
  "data": [
    {
      "id": 1,
      "name": "书",
      "sort": 1,
      "createTime": "2026-04-01T10:00:00"
    }
  ]
}
```

#### 创建分类
```
POST /api/tools/bookshelf/categories
Content-Type: application/json

{
  "name": "纪录片",
  "sort": 6
}
```

#### 更新分类
```
PUT /api/tools/bookshelf/categories/{id}
Content-Type: application/json

{
  "name": "纪录片",
  "sort": 6
}
```

#### 删除分类
```
DELETE /api/tools/bookshelf/categories/{id}
```
**错误响应** (有依赖):
```json
{
  "code": 400,
  "message": "该分类下有 3 个条目，无法删除"
}
```

### 3.3 条目管理接口

#### 获取分类下的条目列表
```
GET /api/tools/bookshelf/items?categoryId=1&page=0&size=20
```
**响应**:
```json
{
  "code": 200,
  "data": {
    "content": [
      {
        "id": 1,
        "categoryId": 1,
        "title": "三体",
        "coverUrl": "https://...",
        "summary": "地球往事",
        "rating": 9,
        "isRecommended": true,
        "tags": ["科幻", "经典"],
        "createTime": "2026-04-01T10:00:00"
      }
    ],
    "totalElements": 45,
    "totalPages": 3
  }
}
```

#### 获取条目详情
```
GET /api/tools/bookshelf/items/{id}
```
**响应**:
```json
{
  "code": 200,
  "data": {
    "id": 1,
    "categoryId": 1,
    "title": "三体",
    "coverUrl": "https://...",
    "summary": "地球往事",
    "startDate": "2026-03-01",
    "endDate": "2026-03-15",
    "finishDate": "2026-03-15",
    "author": "刘慈欣",
    "rating": 9,
    "review": "非常震撼的科幻作品...",
    "progress": "看完第一部",
    "isRecommended": true,
    "tags": ["科幻", "经典"],
    "createTime": "2026-04-01T10:00:00",
    "updateTime": "2026-04-01T11:00:00"
  }
}
```

#### 创建条目
```
POST /api/tools/bookshelf/items
Content-Type: application/json

{
  "categoryId": 1,
  "title": "三体",
  "coverUrl": "https://...",
  "summary": "地球往事",
  "startDate": "2026-03-01",
  "finishDate": "2026-03-15",
  "author": "刘慈欣",
  "rating": 9,
  "review": "非常震撼的科幻作品",
  "progress": "看完第一部",
  "isRecommended": true,
  "tags": ["科幻", "经典"]
}
```

#### 更新条目
```
PUT /api/tools/bookshelf/items/{id}
Content-Type: application/json

{
  "categoryId": 1,
  "title": "三体",
  "coverUrl": "https://...",
  "summary": "地球往事",
  "startDate": "2026-03-01",
  "finishDate": "2026-03-15",
  "author": "刘慈欣",
  "rating": 9,
  "review": "非常震撼的科幻作品",
  "progress": "看完第一部",
  "isRecommended": true,
  "tags": ["科幻", "经典"]
}
```

#### 删除条目
```
DELETE /api/tools/bookshelf/items/{id}
```

### 3.4 标签管理接口

#### 获取标签列表
```
GET /api/tools/bookshelf/tags
```

#### 创建标签
```
POST /api/tools/bookshelf/tags
Content-Type: application/json

{
  "name": "科幻"
}
```

### 3.5 图片上传接口

使用现有接口:
```
POST /api/app/upload/image
Content-Type: multipart/form-data

file: <文件>
businessType: bookshelf
```

---

## 4. 前端设计

### 4.1 页面结构

```
tools/bookshelf/
├── bookshelf_tool.dart          # 工具模块定义
├── pages/
│   ├── bookshelf_page.dart      # 主页面
│   ├── category_page.dart        # 分类管理页
│   ├── item_detail_page.dart     # 条目详情页
│   └── add_item_page.dart        # 添加/编辑条目弹窗
├── widgets/
│   ├── category_tab.dart         # 分类切换 Tab
│   ├── item_card.dart            # 条目卡片
│   ├── rating_widget.dart        # 评分组件 (1-10)
│   ├── tag_selector.dart         # 标签选择器
│   └── date_picker_field.dart    # 日期选择字段
├── models/
│   ├── category.dart             # 分类数据模型
│   ├── item.dart                 # 条目数据模型
│   └── tag.dart                  # 标签数据模型
├── services/
│   ├── bookshelf_api.dart        # API 服务
│   └── bookshelf_service.dart   # 业务逻辑服务
└── providers/
    └── bookshelf_provider.dart   # 状态管理
```

### 4.2 主页面 (BookshelfPage)

**布局**:
- 顶部：分类切换 Tab (横向滚动)
- 中部：条目卡片网格 (2列布局)
- 右上角：分类管理图标按钮
- 右下角：添加条目 FAB

**交互**:
- 分类切换：点击 Tab 切换分类，刷新列表
- 查看详情：点击卡片 → 打开详情页
- 删除条目：左滑卡片 → 显示删除按钮 → 二次确认
- 添加条目：点击 FAB → 打开添加弹窗
- 管理分类：点击右上角按钮 → 进入分类管理页

### 4.3 分类管理页 (CategoryPage)

**布局**:
- 标题：分类管理
- 分类列表：可拖拽排序
- 底部：添加分类按钮

**交互**:
- 添加分类：点击按钮 → 输入分类名 → 创建
- 编辑分类：点击分类 → 修改名称/排序 → 保存
- 删除分类：长按/滑动 → 二次确认 → 删除 (检查依赖)
- 排序调整：拖拽分类项 → 保存排序

### 4.4 条目详情页 (ItemDetailPage)

**查看模式**:
- 封面大图 (顶部)
- 标题 (大字体)
- 分类标签
- 评分组件 (只读)
- 作者、时间信息 (存在才显示)
- 标签列表 (标签样式)
- 观看进度
- 推荐标记 (存在才显示)
- 详细评价
- 右上角：编辑按钮

**编辑模式**:
- 所有字段可编辑
- 封面：点击可重新上传
- 标题：文本输入
- 分类：下拉选择
- 评分：可点击选择 1-10
- 日期：灵活选择开始/结束/完成日期
- 标签：标签选择器 (多选)
- 底部：保存/取消按钮

**交互**:
- 点击编辑按钮 → 进入编辑模式
- 点击保存 → 提交更新 → 返回查看模式
- 点击取消 → 放弃修改 → 返回查看模式

### 4.5 添加条目弹窗 (AddItemDialog)

**必填字段**:
- 封面图片 (上传)
- 标题
- 分类 (默认为当前选中的分类)

**可选字段**:
- 一句话简介
- 开始/结束/完成日期
- 作者/导演
- 评分
- 标签
- 观看进度
- 推荐标记
- 详细评价

**交互**:
- 上传封面 → 调用图片上传 API
- 填写信息 → 提交 → 成功后关闭弹窗
- 校验必填字段未填 → 显示错误提示

### 4.6 组件设计

#### CategoryTab
- 横向滚动列表
- 当前分类高亮显示
- 点击切换分类

#### ItemCard
- 封面图片 (圆角)
- 标题 (2行截断)
- 评分 (显示在右上角)
- 左滑操作：删除按钮

#### RatingWidget
- 显示 10 颗星
- 每颗星代表 1 分
- 编辑模式：点击选择
- 查看模式：只读显示

#### TagSelector
- 显示用户所有标签
- 支持多选
- 可快速创建新标签

#### DatePickerField
- 三个独立日期选择器
- 标签：开始时间、结束时间、完成时间
- 可选，不填不显示

---

## 5. 交互流程

### 5.1 首次进入流程

1. 用户打开书架工具
2. 检查是否已登录
   - 未登录：重定向到登录页
   - 已登录：继续
3. 加载分类列表
   - 空列表：初始化默认分类
4. 加载第一个分类的条目列表
5. 显示主页面

### 5.2 添加新条目流程

1. 用户点击右下角 FAB
2. 打开添加弹窗，预选当前分类
3. 上传封面图片 → POST /api/app/upload/image
4. 填写其他信息
5. 点击提交 → 校验必填字段
6. POST /api/tools/bookshelf/items
7. 成功后关闭弹窗，刷新列表（新条目在前面）
8. 失败时显示错误提示

### 5.3 查看条目详情流程

1. 用户点击卡片
2. GET /api/tools/bookshelf/items/{id}
3. 打开详情页，查看模式
4. 显示所有字段（有值才显示）
5. 点击编辑按钮 → 进入编辑模式
6. 修改信息 → 点击保存
7. PUT /api/tools/bookshelf/items/{id}
8. 成功后返回查看模式，刷新数据
9. 失败时显示错误提示

### 5.4 删除条目流程

1. 用户左滑卡片
2. 显示删除按钮
3. 点击删除 → 弹出确认对话框
4. 用户确认 → DELETE /api/tools/bookshelf/items/{id}
5. 成功后从列表中移除该卡片
6. 失败时显示错误提示

### 5.5 分类管理流程

#### 添加分类
1. 点击添加按钮
2. 输入分类名 → POST /api/tools/bookshelf/categories
3. 成功后添加到列表

#### 编辑分类
1. 点击分类 → 输入新的名称/排序
2. PUT /api/tools/bookshelf/categories/{id}
3. 成功后更新列表

#### 删除分类
1. 长按分类 → 弹出删除确认对话框
2. 用户确认 → DELETE /api/tools/bookshelf/categories/{id}
3. 如果有依赖，返回错误提示
4. 成功后从列表移除

---

## 6. 错误处理

### 6.1 网络错误

- 所有 API 调用失败时显示提示
- 提供重试按钮
- 超时设置：10秒

### 6.2 业务错误

| 错误场景 | 错误提示 | 处理方式 |
|----------|----------|----------|
| 封面未上传 | "请上传封面图片" | 阻止提交 |
| 标题为空 | "请输入标题" | 阻止提交 |
| 标签名称重复 | "该标签已存在" | 阻止创建 |
| 删除分类有依赖 | "该分类下有 N 个条目，无法删除" | 阻止删除 |
| 图片上传失败 | "图片上传失败，请重试" | 允许重新上传 |
| 未登录 | 未处理 | 重定向到登录页 |

### 6.3 加载状态

- 列表加载中显示骨架屏
- 图片加载中显示占位符
- 操作中显示加载指示器

---

## 7. 安全性

### 7.1 认证与授权

- 所有 API 需要有效的登录令牌
- 使用 Spring Security 进行认证
- 用户只能访问 created_by 等于自己 ID 的数据
- 后端进行权限校验，防止越权访问

### 7.2 输入校验

- 前端和后端双重校验
- 标题长度限制：1-100 字符
- 分类名称长度限制：1-50 字符
- 标签名称长度限制：1-30 字符
- 评分范围：1-10

### 7.3 SQL 注入防护

- 使用 JPA 参数化查询
- 不拼接 SQL 字符串

### 7.4 文件上传安全

- 图片大小限制：5MB
- 支持格式：jpg, jpeg, png, webp
- 文件名随机化，防止路径遍历

---

## 8. 数据初始化

### 8.1 默认分类

用户首次使用时，自动创建 5 个默认分类：

| ID | 名称 | 排序 |
|----|------|------|
| 1 | 书 | 1 |
| 2 | 电影 | 2 |
| 3 | 电视剧 | 3 |
| 4 | 番剧 | 4 |
| 5 | 游戏 | 5 |

### 8.2 初始化逻辑

1. 用户首次打开书架功能
2. 检查该用户是否有分类数据
3. 如果没有，创建默认分类
4. 加载分类列表和条目列表

---

## 9. 实施计划

### 9.1 后端实施

1. 创建数据库表和索引
2. 创建 Entity、DTO、Repository、Service、Controller
3. 实现 CRUD 接口
4. 实现权限校验
5. 编写单元测试

### 9.2 前端实施

1. 创建工具模块结构
2. 实现数据模型
3. 实现 API 服务
4. 实现页面和组件
5. 实现状态管理
6. 集成工具注册

### 9.3 测试计划

- 单元测试
- 集成测试
- UI 测试
- 性能测试

---

## 10. 后续扩展

- 导出/导入功能
- 数据统计和可视化
- 社交分享
- 书签同步
- 搜索功能
- 批量操作
