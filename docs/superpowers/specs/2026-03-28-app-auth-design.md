# APP 注册与登录功能设计文档

**日期**: 2026-03-28
**主题**: APP 用户认证系统（注册+登录+微信绑定）
**作者**: Claude

---

## 1. 概述

为 LittleGrid APP 实现完整的用户认证系统，包括手机号注册、登录、微信登录及账号绑定功能。

### 1.1 目标
- 支持手机号+密码注册
- 支持手机号+密码登录
- 支持微信一键登录（自动注册）
- 支持微信账号绑定手机号

### 1.2 非目标
- 短信验证码功能（后续扩展）
- 邮箱注册
- 第三方登录（除微信外）

---

## 2. 后端设计

### 2.1 API 列表

| 接口 | 方法 | 描述 |
|------|------|------|
| `/api/app/auth/register` | POST | 手机号注册 |
| `/api/app/auth/login` | POST | 手机号登录（已存在） |
| `/api/app/auth/wechat` | POST | 微信登录（已存在） |
| `/api/app/auth/logout` | DELETE | 退出登录（已存在） |
| `/api/app/auth/bind/phone` | POST | 绑定手机号（微信用户） |

### 2.2 注册接口

**POST /api/app/auth/register**

**请求参数：**
```json
{
  "phone": "13800138000",
  "password": "RSA加密后的密码",
  "deviceId": "设备唯一标识"
}
```

**响应：**
```json
{
  "token": "Bearer xxx",
  "user": {
    "id": 1,
    "phone": "13800138000",
    "nickname": "用户xxxx",
    "avatarUrl": null
  }
}
```

**校验规则：**
- 手机号：中国大陆手机号格式（1开头，11位数字）
- 密码强度：8位以上，必须同时包含英文字母和阿拉伯数字
- 唯一性：手机号不能已注册
- 密码加密：前端RSA加密，后端解密后BCrypt存储

**错误码：**
- `400` - 手机号格式错误
- `400` - 密码强度不足
- `409` - 手机号已注册

### 2.3 绑定手机号接口

**POST /api/app/auth/bind/phone**

**请求参数：**
```json
{
  "phone": "13800138000",
  "password": "RSA加密后的密码"
}
```

**校验规则：**
- 仅允许微信登录的用户绑定
- 手机号不能已被其他账号绑定
- 绑定后该手机号可用于登录此账号

---

## 3. 前端设计

### 3.1 新增页面

#### RegisterPage（注册页）

**UI 组件：**
- 手机号输入框（带格式校验）
- 密码输入框（带强度提示）
- 确认密码输入框
- 注册按钮
- "已有账号？去登录" 链接

**密码强度提示：**
- 弱（红色）：不足8位或缺少字母/数字
- 中（黄色）：满足基本要求
- 强（绿色）：10位以上且包含大小写字母+数字

**交互流程：**
1. 填写手机号、密码、确认密码
2. 实时校验密码强度
3. 点击注册，密码RSA加密后发送
4. 注册成功自动登录，保存token
5. 跳转首页

#### LoginPage（登录页-已有，需调整）

**新增：**
- "还没有账号？去注册" 链接

#### BindPhonePage（绑定手机号页）

**触发条件：**
- 微信登录的用户在"我的"页面点击"绑定手机号"

**UI 组件：**
- 手机号输入框
- 密码输入框
- 确认密码输入框
- 绑定按钮

### 3.2 交互流程图

```
新用户打开APP
    │
    ├─→ 使用手机号注册 ──→ 填写信息 ──→ 注册成功自动登录
    │
    ├─→ 使用手机号登录 ──→ 填写信息 ──→ 登录成功
    │
    └─→ 使用微信登录 ──→ 授权 ──→ 自动注册/登录
                │
                └─→ 提示"绑定手机号"（可选）
```

---

## 4. 数据模型

### 4.1 AppUser 表（已有）

```java
@Entity
public class AppUser {
    @Id
    private Long id;
    private String phone;        // 手机号（唯一）
    private String password;     // BCrypt加密
    private String wechatOpenid; // 微信openid（唯一，可为空）
    private String nickname;     // 昵称
    private String avatarUrl;    // 头像URL
}
```

### 4.2 AppUserDevice 表（已有）

记录设备登录状态，支持单设备登录（踢掉之前设备）。

---

## 5. 安全设计

### 5.1 密码安全
- 传输：前端RSA公钥加密 → 后端私钥解密
- 存储：BCrypt哈希（自动加盐）
- 强度：8位以上，必须包含字母+数字

### 5.2 会话安全
- Token：JWT，有效期7天
- 单设备登录：新设备登录踢掉旧设备
- 传输：HTTPS（生产环境）

---

## 6. 错误处理

| 场景 | 错误提示 |
|------|----------|
| 手机号格式错误 | "请输入正确的手机号" |
| 密码强度不足 | "密码需8位以上且包含字母和数字" |
| 两次密码不一致 | "两次输入的密码不一致" |
| 手机号已注册 | "该手机号已注册，请直接登录" |
| 手机号已绑定 | "该手机号已被其他账号绑定" |
| 登录失败 | "手机号或密码错误" |

---

## 7. 测试要点

### 7.1 功能测试
- [ ] 正常注册流程
- [ ] 密码强度校验（边界值：7位、8位、无字母、无数字）
- [ ] 重复手机号注册
- [ ] 注册后自动登录
- [ ] 登录已注册账号
- [ ] 微信登录新用户自动注册
- [ ] 微信登录老用户正常登录
- [ ] 微信用户绑定手机号

### 7.2 安全测试
- [ ] 密码RSA加密传输
- [ ] Token过期处理
- [ ] 单设备登录踢人

---

## 8. 后续扩展

- 短信验证码注册/登录
- 忘记密码功能
- 邮箱绑定
- 更多第三方登录（Apple、QQ等）

---

## 9. 相关文件

### 后端
- `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/rest/AppAuthController.java`
- `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/AppAuthService.java`

### 前端
- `app/lib/pages/login/login_page.dart`
- `app/lib/pages/login/register_page.dart`（新建）
- `app/lib/pages/login/bind_phone_page.dart`（新建）
- `app/lib/services/auth_service.dart`
- `app/lib/providers/auth_provider.dart`
