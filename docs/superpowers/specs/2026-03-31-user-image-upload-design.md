# 用户图片上传接口设计文档

**日期：** 2026-03-31
**模块：** eladmin-app
**状态：** 已批准

---

## 概述

为用户端提供图片上传接口，支持多种业务类型（头像、动态、通用等），使用现有的 S3 配置和 JWT 鉴权。不同业务类型映射到 OSS 的不同子目录。

---

## 需求背景

- APP 中需要上传各种类型的图片
- 不同业务类型需要存储在不同目录下
- 需要登录后才能上传（使用现有 JWT 鉴权）
- 复用现有的 S3 配置（阿里云 OSS）

---

## 技术架构

```
┌─────────────────────────────────────────────────────┐
│              eladmin-app 模块                    │
├─────────────────────────────────────────────────────┤
│  ImageUploadController  (用户端接口）         │
│         ↓                                        │
│  ImageUploadService   (业务逻辑）           │
│         ↓                                        │
│  S3Client (复用 eladmin-tools 的配置）    │
│         ↓                                        │
│  阿里云 OSS 存储                                   │
└─────────────────────────────────────────────────────┘
```

---

## 业务类型映射

| 业务类型 | OSS 子目录 | 说明 |
|---------|-----------|------|
| avatar | avatar/ | 用户头像 |
| post | post/ | 用户动态图片 |
| dynamic | dynamic/ | 通用动态内容 |
| temp | temp/ | 临时文件 |

---

## 后端实现

### 文件结构

```
backend/eladmin-app/src/main/java/com/littlegrid/modules/app/
├── rest/
│   └── ImageUploadController.java  [新建]
├── service/
│   └── ImageUploadService.java  [新建]
├── service/dto/
│   └── UploadDTO.java  [新建]
├── service/dto/
│   └── UploadResultDTO.java  [新建]
└── security/
    └── (复用现有的 JWT 鉴权）
```

### API 接口设计

**基础路径：** `/api/app/upload`

| 方法 | 路径 | 说明 | 鉴权 |
|------|------|------|------|
| POST | /api/app/upload/image | 上传单张图片 | 需要 |
| POST | /api/app/upload/images | 上传多张图片 | 需要 |

### 请求参数

```java
public class UploadDTO {
    private MultipartFile file;
    private String businessType;  // avatar|post|dynamic|temp
}
```

### 响应格式

```java
public class UploadResultDTO {
    private String url;      // 完整文件 URL
    private String fileName;  // 原始文件名
    private Long fileSize;    // 文件大小（字节）
    private String fileType;   // 文件类型
}
```

成功响应：
```json
{
  "code": 200,
  "message": "上传成功",
  "data": {
    "url": "https://bucket.oss.com/avatar/abc123.jpg",
    "fileName": "abc123.jpg",
    "fileSize": 102400,
    "fileType": "jpg"
  }
}
```

### 错误处理

| 错误码 | 说明 |
|--------|------|
| 401 | 未登录或 token 无效 |
| 403 | 没有权限 |
| 400 | 参数错误（无效的业务类型） |
| 500 | 服务器错误 |
| 413 | 文件太大（超过限制） |

---

## 数据流

```
用户上传图片 (携带 JWT token)
    ↓
ImageUploadController 验证 JWT
    ↓
ImageUploadService 处理上传
    ↓
根据 businessType 确定 OSS 子目录
    ↓
生成唯一文件名 (UUID + 原始扩展名)
    ↓
上传到阿里云 OSS
    ↓
构建完整 URL (domain + 子目录 + 文件名)
    ↓
返回上传结果
```

---

## 安全考虑

1. **JWT 韶权验证**
   - 使用现有的 `AppSecurityUtils.getCurrentUserId()`
   - 未登录返回 401

2. **文件类型验证**
   - 只允许图片类型（jpg, jpeg, png, gif, webp）
   - MIME 类型验证

3. **文件大小限制**
   - 单文件不超过 10MB
   - 防止恶意上传

4. **业务类型白名单**
   - 只允许预定义的业务类型
   - 防止目录遍历攻击

---

## 技术依赖

- Spring Boot Web
- AWS S3 SDK（已在 eladmin-tools 中配置）
- 现有的 JWT 验证 (`AppSecurityUtils`)
- Lombok

---

## 测试要点

1. **鉴权测试**
   - 未登录上传 → 返回 401
   - 登录后上传 → 成功

2. **业务类型测试**
   - avatar → 上传到 avatar/ 目录
   - post → 上传到 post/ 目录
   - dynamic → 上传到 dynamic/ 目录

3. **文件类型测试**
   - 上传图片 → 成功
   - 上传非图片文件 → 返回错误

4. **边界情况**
   - 空文件
   - 超大文件
   - 无效 businessType

5. **URL 访问测试**
   - 验证返回的 URL 可以访问
   - 验证 URL 包含正确的业务类型目录

---

## 实施步骤

1. 创建 `UploadDTO.java` - 请求参数类
2. 创建 `UploadResultDTO.java` - 响应结果类
3. 创建 `ImageUploadService.java` - 业务逻辑类
4. 创建 `ImageUploadController.java` - 控制器
5. 配置 S3 Client Bean（复用或创建新的）
6. 测试各种场景
