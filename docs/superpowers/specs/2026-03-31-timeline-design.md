# 时间线功能设计文档

**创建日期：** 2026-03-31
**分支：** feature-timeline
**作者：** Claude Code + Happy

---

## 1. 概述

时间线功能允许用户创建和管理多个时间线集合，每个集合包含按时间顺序排列的事件节点。用户可以记录重要事件的时间、标题和详细内容，并支持自动排序和手动排序两种模式。

---

## 2. 技术方案

### 2.1 后端技术栈

- **框架：** Spring Boot 3.2.5
- **数据访问：** MyBatis
- **数据库：** MySQL
- **其他：** Knife4j (API 文档)

### 2.2 前端技术栈

- **框架：** Flutter 3.0+
- **状态管理：** Provider
- **网络请求：** http
- **JSON 解析：** 内置 jsonDecode/jsonEncode

---

## 3. 数据库设计

### 3.1 时间线集合表 (timeline_collection)

```sql
CREATE TABLE timeline_collection (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    title VARCHAR(100) NOT NULL COMMENT '集合标题',
    description VARCHAR(500) COMMENT '集合描述',
    sort_mode VARCHAR(10) DEFAULT 'AUTO' COMMENT '排序模式：AUTO-自动，MANUAL-手动',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_user_id (user_id)
) COMMENT='时间线集合表';
```

### 3.2 时间节点表 (timeline_node)

```sql
CREATE TABLE timeline_node (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    collection_id BIGINT NOT NULL COMMENT '所属时间线集合ID',
    user_id BIGINT NOT NULL COMMENT '用户ID',
    title VARCHAR(100) NOT NULL COMMENT '节点标题',
    content TEXT COMMENT '节点内容',
    event_time DATETIME COMMENT '事件时间',
    sort_order INT DEFAULT 0 COMMENT '手动排序顺序',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    INDEX idx_collection_id (collection_id),
    INDEX idx_user_id (user_id)
) COMMENT='时间节点表';
```

---

## 4. API 接口设计

### 4.1 时间线集合接口

| 方法 | 路径 | 描述 |
|:-----|:-----|:-----|
| POST | `/api/timeline/collections` | 创建时间线集合 |
| GET | `/api/timeline/collections` | 获取用户所有时间线集合 |
| GET | `/api/timeline/collections/{id}` | 获取单个集合详情 |
| PUT | `/api/timeline/collections/{id}` | 更新集合信息 |
| DELETE | `/api/timeline/collections/{id}` | 删除集合及其所有节点 |

### 4.2 时间节点接口

| 方法 | 路径 | 描述 |
|:-----|:-----|:-----|
| POST | `/api/timeline/collections/{id}/nodes` | 添加时间节点 |
| GET | `/api/timeline/collections/{id}/nodes` | 获取集合的所有节点 |
| GET | `/api/timeline/nodes/{id}` | 获取单个节点详情 |
| PUT | `/api/timeline/nodes/{id}` | 更新节点内容 |
| DELETE | `/api/timeline/nodes/{id}` | 删除节点 |
| PUT | `/api/timeline/nodes/{id}/reorder` | 调整节点顺序（MANUAL 模式）|

### 4.3 请求/响应示例

**创建时间线集合：**
```json
POST /api/timeline/collections
{
  "title": "装修时间线",
  "description": "记录房子装修全过程",
  "sortMode": "AUTO"
}

Response:
{
  "id": 1,
  "userId": 123,
  "title": "装修时间线",
  "description": "记录房子装修全过程",
  "sortMode": "AUTO",
  "createdAt": "2024-03-31T10:00:00",
  "updatedAt": "2024-03-31T10:00:00"
}
```

**添加时间节点：**
```json
POST /api/timeline/collections/1/nodes
{
  "title": "拆墙完成",
  "content": "客厅墙体已全部拆除，垃圾已清理完毕",
  "eventTime": "2024-03-31T14:30:00"
}

Response:
{
  "id": 1,
  "collectionId": 1,
  "userId": 123,
  "title": "拆墙完成",
  "content": "客厅墙体已全部拆除，垃圾已清理完毕",
  "eventTime": "2024-03-31T14:30:00",
  "sortOrder": 0,
  "createdAt": "2024-03-31T10:00:00",
  "updatedAt": "2024-03-31T10:00:00"
}
```

---

## 5. 前端架构

### 5.1 文件结构

```
app/lib/tools/timeline/
├── timeline_tool.dart          # 工具模块入口
├── models/
│   ├── timeline_collection.dart
│   └── timeline_node.dart
├── services/
│   └── timeline_service.dart  # API 服务
├── providers/
│   └── timeline_provider.dart  # 状态管理
└── pages/
    FirstTimeLinePage.dart       # 主页面
    NewCollectionDialog.dart     # 新建集合弹窗
    NewNodeDialog.dart          # 新建节点弹窗
```

### 5.2 数据模型

```dart
class TimelineCollection {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final SortMode sortMode;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class TimelineNode {
  final int id;
  final int collectionId;
  final int userId;
  final String title;
  final String content;
  final DateTime? eventTime;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
}

enum SortMode { auto, manual }
```

### 5.3 状态管理

TimelineProvider 负责：
- 管理当前选择的时间线集合
- 管理集合列表
- 管理节点列表
- 处理 CRUD 操作
- 处理排序逻辑

---

## 6. UI 界面设计

### 6.1 主页面布局

```
┌─────────────────────────────┐
│  [标题栏：时间线]           │
├─────────────────────────────┤
│  [标签页切换区域]           │
│  ┌──┐ ┌──┐ ┌──┐            │
│  │装修││旅行││项目│ ...     │
│  └──┘ └──┘ └──┘            │
├─────────────────────────────┤
│  [+ 新增时间节点] 大按钮     │
├─────────────────────────────┤
│  ╭─────────────────────╮    │
│  │ 📅 2024-03-31 14:30 │    │
│  │ 拆墙完成            │    │
│  │ 客厅墙体已全部拆除  │    │
│  ╰─────────────────────╯    │
│          ║                  │
│          ║ 垂直连接线       │
│          ║                  │
│  ╭─────────────────────╮    │
│  │ 📅 2024-03-25 09:00 │    │
│  │ 设计方案确认        │    │
│  ╰与设计师敲定最终方案│    │
│  ╰─────────────────────╯    │
│          ║                  │
│          ...                │
└─────────────────────────────┘
```

### 6.2 交互设计

- **标签页切换：** 点击切换时间线集合
- **新增节点：** 点击按钮弹出表单
- **拖拽排序：** MANUAL 模式下支持拖拽
- **编辑/删除：** 长按卡片显示菜单
- **查看详情：** 点击卡片展开完整内容

---

## 7. 排序逻辑

### 7.1 自动排序模式（AUTO）

- 节点按 `eventTime` 升序排列
- 用户修改 eventTime 后自动重新排序
- 拖拽排序功能禁用

### 7.2 手动排序模式（MANUAL）

- 节点按 `sortOrder` 升序排列
- 用户拖拽调整时更新 sortOrder
- eventTime 仅作为记录，不参与排序

### 7.3 模式切换

- **AUTO → MANUAL：** 根据当前 eventTime 排序自动生成 sortOrder
- **MANUAL → AUTO：** sortOrder 被忽略，按 eventTime 排序显示

---

## 8. 认证与权限

### 8.1 认证要求

- 所有 API 接口需要登录
- 使用现有的 AuthProvider 获取用户信息
- 未登录用户：弹出登录提示，引导用户登录

### 8.2 权限控制

- 用户只能操作自己的时间线数据
- 后端验证 userId 匹配
- 前端不依赖后端验证，但仍需做基本检查

---

## 9. 错误处理

| 错误码 | 描述 | 处理方式 |
|:------|:-----|:---------|
| 401 | 未登录或 token 过期 | 跳转登录页 |
| 403 | 无权限操作 | 显示权限错误提示 |
| 404 | 资源不存在 | 显示"资源已删除"提示 |
| 400 | 请求参数无效 | 显示具体错误信息 |
| 500 | 服务器内部错误 | 显示"系统错误，请稍后重试" |

---

## 10. 实现步骤

### 后端实现

1. 创建数据库表
2. 创建实体类 (TimelineCollection, TimelineNode)
3. 创建 MyBatis Mapper
4. 创建 Service 层
5. 创建 Controller 层
6. 添加 Knife4j 文档注解

### 前端实现

1. 创建工具模块并注册
2. 创建数据模型
3. 创建 API 服务
4. 创建状态管理 Provider
5. 实现主页面 UI
6. 实现新建/编辑/删除功能
7. 实现排序逻辑
8. 添加动画效果

---

## 11. 测试计划

- [ ] 创建集合 CRUD 测试
- [ ] 创建节点 CRUD 测试
- [ ] 排序逻辑测试（AUTO/MANUAL）
- [ ] 权限控制测试
- [ ] 边界情况测试（空集合、空节点等）
- [ ] UI 交互测试

---

## 12. 后续优化

- 支持节点图片附件
- 支持节点富文本编辑
- 支持节点标签/分类
- 支持时间线模板
- 支持导出时间线为图片/PDF
