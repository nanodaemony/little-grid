# Littlegrid Backend 设计文档

## 概述

Littlegrid 后端服务用于支持 Flutter App 的用户管理、数据同步和工具服务功能。基于 eladmin 脚手架快速搭建，采用 Spring Boot 单体架构，支持后续扩展。

## 技术栈

| 组件 | 版本 | 说明 |
|------|------|------|
| Java | 17 LTS | 长期支持版本 |
| Spring Boot | 3.2.x | 最新稳定版 |
| MySQL | 8.0 | 主数据库 |
| MyBatis-Plus | 3.5.x | ORM 框架 |
| Redis | 7.x | 缓存、Token 存储 |
| Maven | 3.9.x | 构建工具 |

## 项目结构

```
backend/
├── eladmin-common/          # 公共模块（工具类、常量、配置）
├── eladmin-system/          # 系统模块（用户、角色、权限、菜单）
├── eladmin-tools/           # 工具服务模块（计算器、日历等工具数据）
├── eladmin-sync/            # 数据同步模块（App 数据备份/恢复）
├── eladmin-auth/            # 认证模块（JWT、微信登录）
└── eladmin-admin/           # Web 管理后台 API
```

### 模块说明

| 模块 | 职责 |
|------|------|
| eladmin-common | 通用工具类、常量、全局配置、基础实体 |
| eladmin-system | 用户、角色、权限、菜单管理（eladmin 原有） |
| eladmin-tools | 工具相关数据存储（计算器历史、日历事件、用户配置） |
| eladmin-sync | App 数据同步功能（上传/下载/版本管理） |
| eladmin-auth | 认证逻辑（JWT Token、微信登录扩展） |
| eladmin-admin | Web 管理后台 API 入口 |

## 数据库设计

### 系统表（eladmin 已有）

| 表名 | 说明 |
|------|------|
| sys_user | 用户信息 |
| sys_role | 角色信息 |
| sys_menu | 菜单权限 |
| sys_user_role | 用户角色关联 |
| sys_role_menu | 角色菜单关联 |

### 业务表（新增）

#### 数据同步模块

```sql
-- 用户设备
CREATE TABLE sync_device (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    device_id VARCHAR(64) NOT NULL COMMENT '设备唯一标识',
    device_name VARCHAR(100) COMMENT '设备名称',
    device_type VARCHAR(20) COMMENT '设备类型: android/ios/web',
    last_sync_time DATETIME COMMENT '最后同步时间',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_device (user_id, device_id)
);

-- 同步记录
CREATE TABLE sync_record (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    device_id VARCHAR(64) NOT NULL COMMENT '设备ID',
    sync_type TINYINT NOT NULL COMMENT '同步类型: 1上传 2下载',
    data_size BIGINT COMMENT '数据大小(字节)',
    status TINYINT DEFAULT 1 COMMENT '状态: 1成功 2失败',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 同步数据
CREATE TABLE sync_data (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    data_type VARCHAR(50) NOT NULL COMMENT '数据类型: calculator/calendar/config等',
    data_content JSON NOT NULL COMMENT '数据内容(JSON格式)',
    version INT DEFAULT 1 COMMENT '数据版本',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_type (user_id, data_type)
);
```

#### 工具服务模块

```sql
-- 计算器历史
CREATE TABLE tool_calculator_history (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    expression VARCHAR(500) NOT NULL COMMENT '表达式',
    result VARCHAR(200) NOT NULL COMMENT '计算结果',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 日历事件
CREATE TABLE tool_calendar_event (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '用户ID',
    title VARCHAR(200) NOT NULL COMMENT '事件标题',
    description TEXT COMMENT '事件描述',
    event_date DATE NOT NULL COMMENT '事件日期',
    event_time TIME COMMENT '事件时间',
    reminder TINYINT DEFAULT 0 COMMENT '是否提醒',
    reminder_time DATETIME COMMENT '提醒时间',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 用户工具配置
CREATE TABLE tool_user_config (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL UNIQUE COMMENT '用户ID',
    config_json JSON COMMENT '配置信息(JSON格式)',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

#### 第三方账号绑定

```sql
-- 社交账号绑定
CREATE TABLE social_user (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT NOT NULL COMMENT '系统用户ID',
    platform VARCHAR(20) NOT NULL COMMENT '平台: wechat/google等',
    open_id VARCHAR(100) NOT NULL COMMENT '平台唯一标识',
    union_id VARCHAR(100) COMMENT '联合ID',
    nickname VARCHAR(100) COMMENT '昵称',
    avatar VARCHAR(500) COMMENT '头像URL',
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_platform_openid (platform, open_id)
);
```

## API 设计

### 认证 API（/api/auth）

| 方法 | 路径 | 说明 | 请求体 | 响应体 |
|------|------|------|--------|--------|
| POST | /login | 用户登录 | {username, password} | {token, userInfo} |
| POST | /register | 用户注册 | {username, password, email} | {userId} |
| POST | /logout | 退出登录 | - | {success} |
| POST | /refresh | 刷新Token | {refreshToken} | {token} |
| POST | /wechat/login | 微信登录 | {code} | {token, userInfo} |

### 数据同步 API（/api/sync）

| 方法 | 路径 | 说明 | 请求体 | 响应体 |
|------|------|------|--------|--------|
| POST | /upload | 上传同步数据 | {dataType, dataContent} | {syncId} |
| GET | /download | 下载同步数据 | ?dataType=xxx | {dataContent, version} |
| GET | /records | 同步记录列表 | ?page=1&size=10 | {records[], total} |
| DELETE | /records/{id} | 删除同步记录 | - | {success} |

### 工具服务 API（/api/tools）

| 方法 | 路径 | 说明 | 请求体 | 响应体 |
|------|------|------|--------|--------|
| GET | /calculator/history | 计算器历史 | ?page=1&size=20 | {history[], total} |
| POST | /calculator/history | 保存计算记录 | {expression, result} | {id} |
| DELETE | /calculator/history/{id} | 删除记录 | - | {success} |
| GET | /calendar/events | 日历事件列表 | ?year=2024&month=3 | {events[]} |
| POST | /calendar/events | 创建事件 | {title, date, ...} | {id} |
| PUT | /calendar/events/{id} | 更新事件 | {title, date, ...} | {success} |
| DELETE | /calendar/events/{id} | 删除事件 | - | {success} |
| GET | /config | 获取用户配置 | - | {config} |
| PUT | /config | 更新用户配置 | {config} | {success} |

### 用户 API（/api/user）

| 方法 | 路径 | 说明 | 请求体 | 响应体 |
|------|------|------|--------|--------|
| GET | /info | 获取用户信息 | - | {userInfo} |
| PUT | /info | 更新用户信息 | {nickname, avatar, ...} | {success} |
| PUT | /password | 修改密码 | {oldPassword, newPassword} | {success} |

## 部署架构

### 服务器配置（阿里云 ECS）

**初期配置：**
- CPU：2 核
- 内存：4 GB
- 磁盘：50 GB SSD
- 带宽：3 Mbps

### 架构图

```
┌─────────────────────────────────────────────┐
│                  阿里云 ECS                  │
│  ┌─────────┐  ┌─────────┐  ┌─────────────┐  │
│  │  Nginx  │  │ Spring  │  │   MySQL     │  │
│  │ (80/443)│→ │  Boot   │→ │   3306      │  │
│  └─────────┘  └─────────┘  └─────────────┘  │
│                    ↓                         │
│              ┌───────────┐                   │
│              │   Redis   │                   │
│              └───────────┘                   │
└─────────────────────────────────────────────┘
        ↓ HTTPS
   Flutter App (用户)
   Web 管理后台 (管理员)
```

### 安全策略

- HTTPS 证书（阿里云免费 SSL）
- 防火墙只开放 80/443/22 端口
- MySQL/Redis 只监听内网
- JWT Token 过期时间：7 天（可配置）

## 实施步骤

1. 克隆 eladmin 项目到 backend 目录
2. 升级 Spring Boot 版本到 3.2.x
3. 调整项目模块结构
4. 创建业务表（sync_*, tool_*, social_user）
5. 实现数据同步模块
6. 实现工具服务模块
7. 抽取认证模块，预留微信登录接口
8. 编写单元测试
9. 部署到阿里云 ECS