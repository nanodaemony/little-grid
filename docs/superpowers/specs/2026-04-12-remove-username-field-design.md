---
name: 移除用户名字段，使用手机号注册
description: 移除 username 字段，注册使用手机号，保留 nickname 字段并支持自动生成
type: project
---

# 移除用户名字段设计方案

## 概述

移除 APP 用户表中的 username 字段，改为使用手机号作为主要注册标识，保留 nickname 字段用于用户显示。

## 修改范围

### 后端（Java）

1. **GridUser.java** - 实体类
   - 移除 `username` 字段及其注解（`@NotBlank`、`@Column` unique 约束）

2. **RegisterDTO.java** - 注册请求 DTO
   - 移除 `username` 字段及其校验注解
   - 保留 `nickname` 字段（不做必填校验）

3. **AppUserDTO.java** - 用户响应 DTO
   - 移除 `username` 字段

4. **GridUserRepository.java** - 数据访问层
   - 移除 `findByUsername()` 方法
   - 移除 `existsByUsername()` 方法

5. **AppAuthServiceImpl.java** - 认证服务实现
   - 移除 username 重复校验逻辑
   - 修改 nickname 生成逻辑：
     - 如果用户传入 nickname，使用用户传入值
     - 如果用户未传入，自动生成 "用户XXX"，其中 XXX 是 `System.currentTimeMillis()` 的最后5位

6. **AppTokenProvider.java** - Token 提供者
   - 修改 `createToken()` 方法签名，不再传递 username
   - JWT subject 使用 userId（Long 类型转为 String）

7. **V1__Create_grid_user_table.sql** - 数据库迁移脚本
   - 移除 `username` 列定义
   - 移除 `uk_username` 唯一索引

8. **AppAuthControllerTest.java** - 测试用例
   - 更新注册测试，不再传递 username

### 前端（Flutter）

1. **register_page.dart** - 注册页面
   - 新增昵称输入框（可选，不校验）
   - 必填项（手机号、密码、确认密码）标签添加红色 `*` 号标识

2. **auth_service.dart** - 认证服务
   - 修改 `register()` 方法，新增可选的 `nickname` 参数

3. **auth_provider.dart** - 认证状态管理
   - 修改 `register()` 方法，新增可选的 `nickname` 参数

## 数据流程

### 注册流程

```
用户输入（手机号、密码、确认密码、[昵称]）
    ↓
前端校验（必填项、密码强度、密码一致性）
    ↓
调用注册接口（phone, password, deviceId, [nickname]）
    ↓
后端校验（手机号格式、手机号唯一性）
    ↓
生成 nickname（用户传入 或 自动生成 "用户XXX"）
    ↓
创建用户记录
    ↓
生成 JWT Token（subject = userId）
    ↓
返回 Token 和用户信息
```

## JWT Token 变更

### 修改前
```java
public String createToken(Long userId, String username, String deviceId) {
    // ...
    return Jwts.builder()
        .setClaims(claims)
        .setSubject(username)  // 使用 username
        // ...
        .compact();
}
```

### 修改后
```java
public String createToken(Long userId, String deviceId) {
    // ...
    return Jwts.builder()
        .setClaims(claims)
        .setSubject(String.valueOf(userId))  // 使用 userId
        // ...
        .compact();
}
```

## 注意事项

1. **JWT 解析**：grid-app 模块只使用 `SecurityUtils.getCurrentUserId()` 从 claims 的 `uid` 字段获取用户 ID，不依赖 subject 字段，因此变更不会影响现有功能。

2. **数据库兼容性**：需要新增数据库迁移脚本来处理现有数据（如果有）。

3. **nickname 自动生成**：使用时间戳最后5位，避免简单的自增数字带来的用户量暴露问题。
