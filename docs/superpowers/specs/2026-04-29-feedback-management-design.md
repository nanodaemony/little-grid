# 反馈管理功能完整设计方案

**日期：** 2026-04-29
**状态：** 待实现
**范围：** APP后端 + Admin后端 + AdminWeb前端

---

## 1. 概述

### 1.1 功能目标
为Little Grid项目实现完整的反馈管理功能：
- APP用户可以提交反馈和建议
- 管理员可以查看和管理反馈

### 1.2 涉及模块
- **grid-app**：APP端后端API
- **grid-admin**：Admin端后端API
- **admin**：AdminWeb前端页面

---

## 2. 数据库设计

### 2.1 表结构

#### 表名：`feedback`

| 字段名 | 类型 | 约束 | 说明 |
|--------|------|------|------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | 主键 |
| user_id | BIGINT | NOT NULL | 提交反馈的用户ID |
| type | VARCHAR(20) | NOT NULL | 反馈类型：SUGGESTION（功能建议）/ ISSUE（问题反馈） |
| description | VARCHAR(500) | NOT NULL | 反馈描述内容 |
| screenshots | TEXT | NULL | 截图URL列表，JSON数组格式 |
| status | VARCHAR(20) | NOT NULL DEFAULT 'PENDING' | 状态：PENDING（待处理）/ READ（已读） |
| created_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_at | DATETIME | NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP | 更新时间 |

### 2.2 SQL初始化脚本

```sql
CREATE TABLE IF NOT EXISTS feedback (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL,
    type VARCHAR(20) NOT NULL,
    description VARCHAR(500) NOT NULL,
    screenshots TEXT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_type (type),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

---

## 3. APP端后端实现（grid-app）

### 3.1 文件结构

```
backend/grid-app/src/main/java/com/naon/grid/modules/app/feedback/
├── domain/
│   └── Feedback.java                    # JPA实体
├── enums/
│   └── FeedbackType.java                # 反馈类型枚举
├── repository/
│   └── FeedbackRepository.java          # Repository接口
├── service/
│   ├── FeedbackService.java             # Service接口
│   ├── impl/
│   │   └── FeedbackServiceImpl.java     # Service实现
│   └── dto/
│       ├── SubmitFeedbackDTO.java       # 提交反馈请求DTO
│       └── FeedbackDTO.java             # 反馈响应DTO
└── rest/
    └── FeedbackController.java          # REST控制器
```

### 3.2 核心代码设计

#### Feedback.java (实体)
```java
@Entity
@Getter
@Setter
@Table(name = "feedback")
public class Feedback implements Serializable {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    @Column(name = "user_id", nullable = false)
    private Long userId;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "type", nullable = false, length = 20)
    private FeedbackType type;

    @NotBlank(message = "描述不能为空")
    @Size(max = 500, message = "描述最多500字")
    @Column(name = "description", nullable = false, length = 500)
    private String description;

    @Column(name = "screenshots", columnDefinition = "TEXT")
    private String screenshots;

    @NotNull
    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private FeedbackStatus status = FeedbackStatus.PENDING;

    @Column(name = "created_at")
    private Date createdAt;

    @Column(name = "updated_at")
    private Date updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = new Date();
        updatedAt = new Date();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = new Date();
    }
}
```

#### FeedbackType.java (枚举)
```java
public enum FeedbackType {
    SUGGESTION("功能建议"),
    ISSUE("问题反馈");

    private final String description;

    FeedbackType(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
```

#### FeedbackStatus.java (枚举)
```java
public enum FeedbackStatus {
    PENDING("待处理"),
    READ("已读");

    private final String description;

    FeedbackStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}
```

### 3.3 API设计

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | /api/feedback | 提交反馈 | 需要APP Token |

#### POST /api/feedback 请求
```json
{
  "type": "SUGGESTION",
  "description": "希望增加深色模式",
  "screenshots": ["https://example.com/1.jpg", "https://example.com/2.jpg"]
}
```

#### POST /api/feedback 响应 (200 OK)
```json
{
  "success": true,
  "message": "提交成功"
}
```

---

## 4. Admin端后端实现（grid-admin）

### 4.1 文件结构

```
backend/grid-admin/src/main/java/com/naon/grid/admin/
├── rest/
│   └── FeedbackAdminController.java      # Admin REST控制器
├── service/
│   └── FeedbackAdminService.java         # Admin Service
└── dto/
    ├── AdminFeedbackDTO.java             # 详情DTO
    └── AdminFeedbackListDTO.java         # 列表项DTO
```

### 4.2 API设计

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | /api/admin/feedback | 分页获取反馈列表 | 需要Admin Token |
| GET | /api/admin/feedback/{id} | 获取反馈详情 | 需要Admin Token |
| PUT | /api/admin/feedback/{id}/read | 标记已读 | 需要Admin Token |

#### GET /api/admin/feedback 查询参数
| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | int | 否 | 页码，默认1 |
| size | int | 否 | 每页数量，默认20 |
| type | string | 否 | 按类型筛选：SUGGESTION/ISSUE |
| status | string | 否 | 按状态筛选：PENDING/READ |

#### GET /api/admin/feedback 响应
```json
{
  "content": [
    {
      "id": 1,
      "userId": 100,
      "userNickname": "用户昵称",
      "type": "SUGGESTION",
      "description": "希望增加深色模式",
      "screenshotCount": 2,
      "status": "PENDING",
      "createdAt": "2026-04-29T10:00:00"
    }
  ],
  "totalElements": 100,
  "totalPages": 5,
  "size": 20,
  "number": 0
}
```

---

## 5. AdminWeb前端实现

### 5.1 文件结构

```
admin/app/dashboard/content/feedback/
├── page.tsx                          # 主页面
├── components/
│   ├── feedback-list.tsx             # 列表组件
│   └── feedback-detail.tsx           # 详情抽屉
└── hooks/
    └── use-feedback.ts               # API钩子
```

### 5.2 菜单配置更新

在 `admin/lib/menu-config.ts` 的"内容管理"下增加：
```typescript
{ label: '反馈管理', href: '/dashboard/content/feedback' }
```

### 5.3 页面布局

```
┌─────────────────────────────────────────────────────────────────┐
│  反馈管理                                                        │
├─────────────────────────────────────────────────────────────────┤
│  [ 类型: 全部 ▼ ]  [ 状态: 全部 ▼ ]      [ 刷新 ]              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ ID    用户      类型      状态      时间                │   │
│  ├─────────────────────────────────────────────────────────┤   │
│  │ 1     user1     建议      未读      2026-04-29 10:00   │   │
│  │ 2     user2     问题      已读      2026-04-28 15:30   │   │
│  │ ...                                                 │   │
│  └─────────────────────────────────────────────────────────┘   │
│                         [ <  1  2  3  ...  > ]                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 5.4 详情抽屉

点击列表项时，从右侧滑出详情抽屉，显示：
- 用户昵称/ID
- 反馈类型
- 描述内容
- 截图预览（可点击放大）
- 提交时间
- 状态
- "标记已读"按钮（如果当前是未读状态）

---

## 6. 实现步骤

### 阶段1：数据库
1. 创建feedback表SQL脚本
2. 执行SQL脚本初始化表

### 阶段2：grid-app后端
1. 创建FeedbackType和FeedbackStatus枚举
2. 创建Feedback JPA实体
3. 创建FeedbackRepository
4. 创建DTO类
5. 创建FeedbackService接口和实现
6. 创建FeedbackController
7. 测试提交反馈API

### 阶段3：grid-admin后端
1. 创建Admin端DTO类
2. 创建FeedbackAdminService
3. 创建FeedbackAdminController
4. 测试Admin端API

### 阶段4：AdminWeb前端
1. 创建use-feedback钩子
2. 创建feedback-list组件
3. 创建feedback-detail组件
4. 创建page.tsx主页面
5. 更新menu-config.ts菜单配置
6. 测试前端功能

---

## 7. 注意事项

1. **screenshots字段**：存储JSON数组字符串，需要在代码中进行序列化/反序列化
2. **用户信息关联**：Admin端列表需要显示用户昵称，需要关联查询grid_user表
3. **权限控制**：APP端API需要APP Token认证，Admin端API需要Admin Token认证
4. **分页查询**：Admin列表需要支持高效分页，使用Spring Data JPA的Pageable
5. **日期格式**：前后端日期使用ISO 8601格式
