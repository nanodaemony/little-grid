# 树洞匿名墙设计文档

**日期:** 2026-04-14
**作者:** Claude
**状态:** 待审核

## 概述

在小方格应用中新增"树洞匿名墙"功能格子,用户可以写下秘密/烦恼,随机看到别人的,也可以给别人温暖回复。采用半匿名机制,系统记录发帖人但前端匿名展示,必须登录才能使用。

## 需求背景

- 用户需要一个安全的地方倾诉心声
- 通过匿名方式降低心理负担
- 提供温暖互动,让用户感受到被理解和支持
- 丰富小方格应用的社交类功能

## 功能需求

### 核心功能

1. **发布树洞**
   - 输入内容(最多500字)
   - 选择标签(必选):烦恼、秘密、求助、分享、其他
   - 发布后保存到服务器

2. **随机浏览**
   - 卡片式展示,一次一条
   - 支持左滑/点击"换一个"切换
   - 不展示自己的帖子
   - 同一天不重复展示同一帖子
   - 支持按标签筛选

3. **回复互动**
   - 查看树洞详情及所有回复
   - 发表一级公开回复
   - 发表二级回复(回复别人的回复)
   - 给回复点赞/取消点赞

4. **我的树洞**
   - 查看自己发布过的所有帖子
   - 删除自己的帖子(级联删除回复和点赞)

### 非功能需求

- 安全性:必须登录才能使用,Token鉴权
- 匿名性:前端不展示用户信息,后端可查
- 性能:分页查询,避免加载大量数据
- 可用性:界面简洁,操作直观

## 技术方案

### 架构设计

**模块位置:**
- 后端: `backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/`
- 前端: `app/lib/tools/treehole/`

### 后端设计

#### 新增文件结构

```
backend/grid-app/src/main/java/com/naon/grid/modules/app/treehole/
├── domain/
│   ├── TreeholePost.java          # 树洞帖子实体
│   ├── TreeholeReply.java         # 树洞回复实体
│   ├── TreeholeReplyLike.java     # 回复点赞实体
│   └── TreeholeViewHistory.java   # 浏览历史实体
├── repository/
│   ├── TreeholePostRepository.java
│   ├── TreeholeReplyRepository.java
│   ├── TreeholeReplyLikeRepository.java
│   └── TreeholeViewHistoryRepository.java
├── service/
│   ├── TreeholeService.java
│   └── impl/
│       └── TreeholeServiceImpl.java
├── rest/
│   └── TreeholeController.java
└── service/dto/
    ├── CreatePostDTO.java
    ├── CreateReplyDTO.java
    ├── PostDetailDTO.java
    └── PostDTO.java
```

#### API 设计

| 方法 | 路径 | 描述 | 权限 |
|------|------|------|------|
| POST | `/api/app/treehole/posts` | 发布树洞 | 需要登录 |
| GET | `/api/app/treehole/posts/random` | 随机获取一条树洞 | 需要登录 |
| GET | `/api/app/treehole/posts/mine` | 获取我的树洞列表 | 需要登录 |
| GET | `/api/app/treehole/posts/{id}` | 获取树洞详情(含回复) | 需要登录 |
| DELETE | `/api/app/treehole/posts/{id}` | 删除我的树洞 | 需要登录 |
| POST | `/api/app/treehole/posts/{id}/replies` | 发表回复 | 需要登录 |
| POST | `/api/app/treehole/replies/{id}/like` | 点赞回复 | 需要登录 |
| DELETE | `/api/app/treehole/replies/{id}/like` | 取消点赞 | 需要登录 |

**API 详情:**

1. **发布树洞** `POST /api/app/treehole/posts`
   - 请求体: `{ content: string, tag: string }`
   - 响应: `{ id: number, content: string, tag: string, createdAt: number }`

2. **随机获取** `GET /api/app/treehole/posts/random?tag=xxx`
   - 参数: `tag`(可选) - 标签筛选
   - 响应: `PostDTO` 或 204 No Content

3. **我的树洞** `GET /api/app/treehole/posts/mine?page=0&size=20`
   - 参数: `page`, `size` - 分页
   - 响应: `PageResult<PostDTO>`

4. **树洞详情** `GET /api/app/treehole/posts/{id}`
   - 响应: `PostDetailDTO`(包含回复列表)

5. **删除树洞** `DELETE /api/app/treehole/posts/{id}`
   - 响应: 200 OK

6. **发表回复** `POST /api/app/treehole/posts/{id}/replies`
   - 请求体: `{ content: string, parentId?: number }`
   - 响应: `ReplyDTO`

7. **点赞回复** `POST /api/app/treehole/replies/{id}/like`
   - 响应: `{ id: number, likeCount: number }`

8. **取消点赞** `DELETE /api/app/treehole/replies/{id}/like`
   - 响应: `{ id: number, likeCount: number }`

#### 数据库表设计

```sql
-- 树洞帖子表
CREATE TABLE treehole_post (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL COMMENT '发布者ID',
  content VARCHAR(500) NOT NULL COMMENT '内容',
  tag VARCHAR(20) NOT NULL COMMENT '标签',
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL,
  INDEX idx_user_id (user_id),
  INDEX idx_tag (tag),
  INDEX idx_created_at (created_at)
);

-- 树洞回复表
CREATE TABLE treehole_reply (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  post_id BIGINT NOT NULL COMMENT '帖子ID',
  user_id BIGINT NOT NULL COMMENT '回复者ID',
  parent_id BIGINT COMMENT '父回复ID(二级回复)',
  content VARCHAR(300) NOT NULL COMMENT '内容',
  like_count INT DEFAULT 0 COMMENT '点赞数',
  created_at BIGINT NOT NULL,
  updated_at BIGINT NOT NULL,
  INDEX idx_post_id (post_id),
  INDEX idx_parent_id (parent_id),
  INDEX idx_user_id (user_id)
);

-- 回复点赞表
CREATE TABLE treehole_reply_like (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  reply_id BIGINT NOT NULL COMMENT '回复ID',
  user_id BIGINT NOT NULL COMMENT '点赞者ID',
  created_at BIGINT NOT NULL,
  UNIQUE KEY uk_reply_user (reply_id, user_id),
  INDEX idx_reply_id (reply_id),
  INDEX idx_user_id (user_id)
);

-- 浏览历史表
CREATE TABLE treehole_view_history (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL COMMENT '用户ID',
  post_id BIGINT NOT NULL COMMENT '帖子ID',
  view_date DATE NOT NULL COMMENT '浏览日期',
  created_at BIGINT NOT NULL,
  UNIQUE KEY uk_user_post_date (user_id, post_id, view_date),
  INDEX idx_user_date (user_id, view_date)
);
```

#### 业务规则实现

1. **随机获取逻辑:**
   ```java
   // 1. 获取当前用户ID
   // 2. 获取今天已浏览的帖子ID列表
   // 3. 查询条件: user_id != 当前用户, id NOT IN 已浏览列表
   // 4. 如果有tag筛选,加上 tag = ? 条件
   // 5. 随机排序(RAND()),取第一条
   // 6. 如果查到,记录浏览历史
   ```

2. **删除帖子逻辑:**
   - 删除该帖子的所有回复点赞记录
   - 删除该帖子的所有回复记录
   - 删除该帖子的浏览历史
   - 删除帖子本身

3. **点赞逻辑:**
   - 检查是否已点赞(uk_reply_user)
   - 如果已点赞,返回当前状态
   - 如果未点赞,插入点赞记录,回复like_count+1

### 前端设计

#### 新增文件结构

```
app/lib/tools/treehole/
├── treehole_tool.dart          # 工具注册
├── treehole_page.dart          # 主页面(浏览页)
├── treehole_post_page.dart     # 发布页
├── treehole_detail_page.dart   # 详情页
├── treehole_mine_page.dart     # 我的树洞页
├── treehole_models.dart        # 数据模型
├── treehole_service.dart       # API调用服务
└── widgets/                     # 子组件
    ├── treehole_card.dart      # 树洞卡片
    └── reply_item.dart         # 回复项
```

#### 页面说明

**1. 浏览页 (treehole_page.dart)**
- AppBar: 标题"树洞",右侧"我的"按钮
- 标签筛选栏: 横向滚动(全部、烦恼、秘密、求助、分享、其他)
- 主体: 居中卡片,支持左滑/右滑手势
- 卡片内容: 内容文本、标签、发布时间(相对时间)、回复数
- 底部: "换一个"按钮
- 右下角: 悬浮"+"按钮,跳转发布页

**2. 发布页 (treehole_post_page.dart)**
- AppBar: 标题"说点什么",右侧"发布"按钮
- 主体: 多行文本输入框(占位符"写下你的秘密或烦恼...")
- 标签选择: 单选按钮组(烦恼、秘密、求助、分享、其他)
- 字数统计: 右下角显示"当前字数/500"

**3. 详情页 (treehole_detail_page.dart)**
- AppBar: 标题"树洞详情"
- 上部: 树洞卡片
- 下部: 回复列表
  - 一级回复: 左对齐,显示内容、点赞数、点赞按钮、回复按钮
  - 二级回复: 缩进显示,带"回复@xxx"前缀
- 底部: 固定输入框 + "发送"按钮

**4. 我的树洞页 (treehole_mine_page.dart)**
- AppBar: 标题"我的树洞"
- 主体: 列表视图
  - 每个项: 内容预览(最多2行)、标签、回复数、发布时间
  - 右侧: 删除按钮
- 空状态: "还没有发过树洞,去说点什么吧~"

#### 数据模型 (treehole_models.dart)

```dart
class TreeholePost {
  final int id;
  final String content;
  final String tag;
  final int createdAt;
  final int? replyCount;

  TreeholePost({...});

  factory TreeholePost.fromJson(Map<String, dynamic> json) => ...;
  Map<String, dynamic> toJson() => ...;
}

class TreeholeReply {
  final int id;
  final int postId;
  final String content;
  final int? parentId;
  final int likeCount;
  final bool isLiked;
  final int createdAt;
  final List<TreeholeReply>? children;

  TreeholeReply({...});

  factory TreeholeReply.fromJson(Map<String, dynamic> json) => ...;
}

class PostDetail {
  final TreeholePost post;
  final List<TreeholeReply> replies;

  PostDetail({...});
}
```

#### API 服务 (treehole_service.dart)

```dart
class TreeholeService {
  static Future<TreeholePost?> getRandomPost({String? tag}) async => ...;
  static Future<TreeholePost> createPost(String content, String tag) async => ...;
  static Future<List<TreeholePost>> getMyPosts({int page = 0}) async => ...;
  static Future<PostDetail> getPostDetail(int id) async => ...;
  static Future<void> deletePost(int id) async => ...;
  static Future<TreeholeReply> createReply(int postId, String content, {int? parentId}) async => ...;
  static Future<Map<String, dynamic>> likeReply(int id) async => ...;
  static Future<Map<String, dynamic>> unlikeReply(int id) async => ...;
}
```

#### 工具注册 (treehole_tool.dart)

- id: `treehole`
- name: `树洞`
- icon: `Icons.psychology`
- category: `ToolCategory.life`
- gridSize: 1

## 安全考虑

1. **鉴权控制**
   - 所有接口必须携带有效Token
   - 使用现有的AppTokenProvider验证

2. **数据权限**
   - 只能删除自己的帖子
   - 浏览时过滤掉自己的帖子

3. **内容限制**
   - 帖子最多500字,回复最多300字
   - 不能为空

4. **匿名性保护**
   - DTO中不包含用户信息
   - 前端不展示任何用户标识

5. **防重复操作**
   - 使用唯一索引防止重复点赞
   - 使用唯一索引防止重复记录浏览历史

## 实施计划

1. 后端数据库表创建(Flyway迁移)
2. 后端实体、Repository、DTO创建
3. 后端Service业务逻辑实现
4. 后端Controller API实现
5. 前端数据模型和Service创建
6. 前端浏览页实现
7. 前端发布页实现
8. 前端详情页实现
9. 前端我的树洞页实现
10. 工具注册和集成测试

## 风险评估

| 风险 | 影响 | 概率 | 应对措施 |
|------|------|------|----------|
| 恶意内容发布 | 中 | 中 | 后续增加敏感词过滤和举报功能 |
| 大量刷帖 | 中 | 低 | 后续增加发布频率限制 |
| 浏览历史表膨胀 | 低 | 中 | 定期清理30天前的历史数据 |
