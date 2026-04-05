# 用户登录功能设计文档

## 概述

实现 APP 端的用户登录功能，支持手机号+密码登录和微信登录两种方式。采用独立的后端模块设计，与现有 eladmin 后台管理系统解耦。

## 登录方式

| 方式 | 说明 | 优先级 |
|-----|------|-------|
| 手机号+密码 | 国内主流登录方式 | 高 |
| 微信登录 | 一键授权，无需密码 | 高 |

## 非功能需求

- **单设备登录**：新设备登录会踢掉旧设备
- **JWT Token**：使用 JWT 进行身份认证
- **密码加密**：RSA 加密传输 + BCrypt 存储
- **Token 存储**：APP 端使用安全存储（Keychain/Keystore）

## 数据模型

### 用户表 (app_user)

```sql
CREATE TABLE app_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    phone VARCHAR(20) UNIQUE NOT NULL COMMENT '手机号',
    password VARCHAR(100) COMMENT '密码(BCrypt加密)',
    wechat_openid VARCHAR(64) UNIQUE COMMENT '微信openid',
    nickname VARCHAR(64) COMMENT '昵称',
    avatar_url VARCHAR(500) COMMENT '头像URL',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_phone (phone),
    INDEX idx_wechat (wechat_openid)
) COMMENT='APP用户表';
```

### 登录设备表 (app_user_device)

```sql
CREATE TABLE app_user_device (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    device_id VARCHAR(64) NOT NULL COMMENT '设备唯一标识',
    token VARCHAR(500) NOT NULL COMMENT '当前有效JWT token',
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
    expire_at TIMESTAMP NOT NULL COMMENT 'token过期时间',
    UNIQUE KEY uk_user (user_id) COMMENT '单设备：每个用户只有一条记录',
    INDEX idx_device (device_id),
    FOREIGN KEY (user_id) REFERENCES app_user(id) ON DELETE CASCADE
) COMMENT='用户登录设备';
```

## 后端 API

### 1. 手机号登录

```http
POST /api/app/auth/login
Content-Type: application/json

{
  "phone": "13800138000",
  "password": "base64_encoded_rsa_encrypted_password",
  "deviceId": "device_uuid"
}
```

**成功响应 (200)**
```json
{
  "token": "Bearer eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": 1,
    "phone": "13800138000",
    "nickname": "用户123",
    "avatarUrl": "https://..."
  }
}
```

**错误响应**
- 401: 手机号或密码错误
- 400: 参数校验失败

### 2. 微信登录

```http
POST /api/app/auth/wechat
Content-Type: application/json

{
  "code": "wx_auth_code_from_app",
  "deviceId": "device_uuid"
}
```

**响应同手机号登录**

**特殊处理**
- 首次微信登录：自动创建用户（生成随机昵称）
- 已绑定手机号的微信：返回用户信息
- 微信 code 无效：401 错误

### 3. 退出登录

```http
DELETE /api/app/auth/logout
Authorization: Bearer {token}
```

### 4. 获取当前用户信息

```http
GET /api/app/auth/info
Authorization: Bearer {token}
```

## 单设备登录机制

1. 用户发起登录请求
2. 验证 credentials（密码或微信 code）
3. 检查 `app_user_device` 表
   - 如果存在该用户的记录：删除旧记录（旧 token 失效）
4. 生成新 JWT token
5. 插入新记录到 `app_user_device`
6. 返回 token 和用户信息

**Token 验证时**：检查 token 是否与 `app_user_device` 表中存储的一致，不一致则返回 401。

## 后端模块结构

```
backend/eladmin-app/              # 新增模块
├── src/main/java/me/zhengjie/
│   ├── modules/app/
│   │   ├── domain/
│   │   │   ├── AppUser.java           # 用户实体
│   │   │   └── AppUserDevice.java     # 设备绑定实体
│   │   ├── repository/
│   │   │   ├── AppUserRepository.java
│   │   │   └── AppUserDeviceRepository.java
│   │   ├── service/
│   │   │   ├── AppAuthService.java    # 登录业务逻辑
│   │   │   ├── AppUserService.java    # 用户管理
│   │   │   └── WechatAuthService.java # 微信认证
│   │   ├── service/dto/
│   │   │   ├── LoginDTO.java          # 登录请求
│   │   │   ├── WechatLoginDTO.java    # 微信登录请求
│   │   │   └── AppUserDTO.java        # 用户信息
│   │   └── rest/
│   │       └── AppAuthController.java # API接口
│   └── config/
│       └── AppSecurityConfig.java     # APP端安全配置
├── src/main/resources/
│   └── app-config.yml                 # APP模块配置
└── pom.xml
```

## APP端设计

### 页面流程

```
启动APP
   │
   ▼
检查本地 Token（SecureStorage）
   │
   ├─ 有效 ─────→ 进入首页
   │
   └─ 无效/过期 ─→ 登录页
           │
           ├─ 输入手机号+密码
           ├─ 点击"微信登录"
           │
           ▼
      调用登录API
           │
           ▼
      保存 Token & 用户信息
           │
           ▼
       进入首页
```

### 目录结构

```
app/lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart      # API 地址常量
│   └── services/
│       ├── auth_service.dart       # 登录API封装
│       └── secure_storage.dart     # 安全存储封装
├── pages/
│   └── login/
│       ├── login_page.dart         # 登录页面
│       └── widgets/
│           ├── phone_login_tab.dart    # 手机号登录Tab
│           └── wechat_login_button.dart # 微信登录按钮
├── providers/
│   └── auth_provider.dart          # 登录状态管理
└── models/
    └── user.dart                   # 用户模型
```

### 核心类设计

**AuthService**
```dart
class AuthService {
  // 手机号登录
  Future<AuthResult> loginWithPhone(String phone, String password);

  // 微信登录
  Future<AuthResult> loginWithWechat(String code);

  // 退出登录
  Future<void> logout();

  // 获取当前token
  Future<String?> getToken();

  // 检查登录状态
  Future<bool> isLoggedIn();
}
```

**AuthProvider**
```dart
class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  // 登录
  Future<void> login(String phone, String password);

  // 微信登录
  Future<void> loginWithWechat();

  // 退出
  Future<void> logout();

  // 初始化（APP启动时调用）
  Future<void> initialize();
}
```

## 安全考虑

1. **密码传输**：APP 端先用 RSA 公钥加密密码，后端用私钥解密后再 BCrypt 哈希
2. **Token 存储**：使用 `flutter_secure_storage`，数据存储在 iOS Keychain / Android Keystore
3. **Token 过期**：JWT 设置合理过期时间（如7天），配合 refresh token 机制（可选）
4. **设备标识**：使用设备唯一标识 + 随机 UUID，防止伪造
5. **接口安全**：登录相关接口添加限流，防止暴力破解

## 微信登录配置

需要在微信开放平台注册应用，获取：
- AppID
- AppSecret

后端配置：
```yaml
wechat:
  app-id: wx_xxx
  app-secret: xxx
```

## 数据库迁移

执行 SQL 文件创建表结构：`backend/sql/app_user_tables.sql`

## 后续扩展（暂不做）

- 数据同步：用户数据的云端备份和多设备同步
- 密码找回：手机号验证码重置密码
- 第三方登录：QQ、Apple ID 等
- Token 刷新：自动续期机制
