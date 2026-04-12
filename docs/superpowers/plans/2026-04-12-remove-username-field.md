# 移除用户名字段实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 移除 APP 用户表中的 username 字段，改用手机号注册，保留 nickname 并支持自动生成

**Architecture:** 分两阶段实施：先修改后端 Java 代码，再修改前端 Flutter 代码；每个阶段按文件依赖顺序逐步修改

**Tech Stack:** Spring Boot (Java), JPA, Flutter, JWT

---

## 阶段一：后端 Java 修改

### Task 1: 修改 GridUser 实体类 - 移除 username 字段

**Files:**
- Modify: `backend/grid-app/src/main/java/com/naon/grid/modules/app/domain/GridUser.java`

- [ ] **Step 1: 读取当前文件**

先读取文件确认内容（已读取过，跳过）

- [ ] **Step 2: 修改 GridUser.java**

移除第 30-32 行的 username 字段：

```java
// 删掉这三行：
// @NotBlank(message = "用户名不能为空")
// @Column(name = "username", nullable = false, unique = true, length = 50)
// private String username;
```

修改后的实体类从 id 直接跳到 password 字段。

- [ ] **Step 3: 提交修改**

```bash
cd /Users/nano/claude/little-grid
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/domain/GridUser.java
git commit -m "refactor: remove username field from GridUser entity"
```

---

### Task 2: 修改 RegisterDTO - 移除 username，保留 nickname

**Files:**
- Modify: `backend/grid-app/src/main/java/com/naon/grid/modules/app/service/dto/RegisterDTO.java`

- [ ] **Step 1: 修改 RegisterDTO.java**

移除第 10-13 行的 username 字段：

```java
// 删掉这四行：
// @NotBlank(message = "用户名不能为空")
// @Pattern(regexp = "^[a-zA-Z0-9_]{3,20}$", message = "用户名只能包含3-20位字母、数字或下划线")
// @ApiModelProperty(value = "用户名", required = true)
// private String username;
```

保留 nickname 字段（第 27-28 行），不需要添加校验注解。

- [ ] **Step 2: 提交修改**

```bash
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/service/dto/RegisterDTO.java
git commit -m "refactor: remove username field from RegisterDTO"
```

---

### Task 3: 修改 AppUserDTO - 移除 username 字段

**Files:**
- Modify: `backend/grid-app/src/main/java/com/naon/grid/modules/app/service/dto/AppUserDTO.java`

- [ ] **Step 1: 修改 AppUserDTO.java**

移除第 13-14 行的 username 字段：

```java
// 删掉这两行：
// @ApiModelProperty(value = "用户名")
// private String username;
```

- [ ] **Step 2: 提交修改**

```bash
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/service/dto/AppUserDTO.java
git commit -m "refactor: remove username field from AppUserDTO"
```

---

### Task 4: 修改 GridUserRepository - 移除 username 相关方法

**Files:**
- Modify: `backend/grid-app/src/main/java/com/naon/grid/modules/app/repository/GridUserRepository.java`

- [ ] **Step 1: 修改 GridUserRepository.java**

移除第 16-20 行和第 26-29 行：

```java
// 删掉这些方法：
// /**
//  * 根据用户名查询用户
//  */
// Optional<GridUser> findByUsername(String username);

// /**
//  * 根据用户名判断是否存在
//  */
// boolean existsByUsername(String username);
```

保留 findByPhone、existsByPhone、findByEmail 方法。

- [ ] **Step 2: 提交修改**

```bash
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/repository/GridUserRepository.java
git commit -m "refactor: remove username query methods from GridUserRepository"
```

---

### Task 5: 修改 AppAuthServiceImpl - 更新注册逻辑

**Files:**
- Modify: `backend/grid-app/src/main/java/com/naon/grid/modules/app/service/impl/AppAuthServiceImpl.java`

- [ ] **Step 1: 修改 register() 方法**

修改第 44-70 行的 register() 方法：

1. 移除 username 校验（第 47-50 行）
2. 修改 nickname 生成逻辑

修改后的完整 register() 方法：

```java
@Override
@Transactional(rollbackFor = Exception.class)
public TokenDTO register(RegisterDTO registerDTO, HttpServletRequest request) {
    // 检查手机号
    if (userRepository.existsByPhone(registerDTO.getPhone())) {
        throw new BadRequestException(AppErrorCode.PHONE_EXISTS.getMessage());
    }
    // 直接使用明文密码（开发测试用）
    String decryptedPassword = registerDTO.getPassword();
    // 创建用户
    GridUser user = new GridUser();
    user.setPassword(passwordEncoder.encode(decryptedPassword));
    user.setPhone(registerDTO.getPhone());
    user.setEmail(registerDTO.getEmail());
    // 生成 nickname：用户传入则使用，否则自动生成 "用户XXX"
    String nickname;
    if (StrUtil.isNotBlank(registerDTO.getNickname())) {
        nickname = registerDTO.getNickname();
    } else {
        String timestamp = String.valueOf(System.currentTimeMillis());
        String suffix = timestamp.substring(timestamp.length() - 5);
        nickname = "用户" + suffix;
    }
    user.setNickname(nickname);
    user.setGender(Gender.UNKNOWN.getCode());
    user.setStatus(AppUserStatus.ENABLED.getCode());
    user.setRegisterIp(StringUtils.getIp(request));
    userRepository.save(user);
    // 生成Token
    return generateToken(user, registerDTO.getDeviceId());
}
```

- [ ] **Step 2: 修改 generateToken() 调用和方法**

同时修改第 69 行 generateToken 调用，以及第 101-109 行的 generateToken() 方法：

先修改 register() 中的调用（第 69 行）：
```java
return generateToken(user, registerDTO.getDeviceId());
```

然后修改 generateToken() 方法定义（第 101 行）和内部调用 appTokenProvider.createToken()（第 103 行）：

```java
private TokenDTO generateToken(GridUser user, String deviceId) {
    TokenDTO tokenDTO = new TokenDTO();
    tokenDTO.setToken(appTokenProvider.createToken(user.getId(), deviceId));
    tokenDTO.setRefreshToken("mock_refresh_" + user.getId());
    tokenDTO.setExpiresIn(tokenValidityInSeconds);
    tokenDTO.setUser(convertToDTO(user));
    deviceManager.registerDevice(user.getId(), deviceId, tokenDTO.getToken());
    return tokenDTO;
}
```

- [ ] **Step 3: 提交修改**

```bash
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/service/impl/AppAuthServiceImpl.java
git commit -m "refactor: update register logic, remove username check, add nickname auto-generation"
```

---

### Task 6: 修改 AppTokenProvider - 使用 userId 作为 subject

**Files:**
- Modify: `backend/grid-app/src/main/java/com/naon/grid/modules/app/security/AppTokenProvider.java`

- [ ] **Step 1: 修改 createToken() 方法签名和实现**

修改第 47-60 行的 createToken() 方法：

```java
public String createToken(Long userId, String deviceId) {
    Map<String, Object> claims = new HashMap<>();
    claims.put(AUTHORITIES_UID_KEY, userId);
    claims.put(DEVICE_ID_KEY, deviceId);
    claims.put(TOKEN_TYPE_KEY, TOKEN_TYPE_ACCESS);
    claims.put("jti", IdUtil.simpleUUID());

    return Jwts.builder()
            .setClaims(claims)
            .setSubject(String.valueOf(userId))
            .setIssuedAt(new Date())
            .signWith(signingKey, SignatureAlgorithm.HS512)
            .compact();
}
```

- [ ] **Step 2: 提交修改**

```bash
git add backend/grid-app/src/main/java/com/naon/grid/modules/app/security/AppTokenProvider.java
git commit -m "refactor: use userId as JWT subject in AppTokenProvider"
```

---

### Task 7: 修改数据库迁移脚本

**Files:**
- Modify: `backend/grid-app/src/main/resources/db/migration/V1__Create_grid_user_table.sql`
- Create: `backend/grid-app/src/main/resources/db/migration/V2__Remove_username_column.sql`

- [ ] **Step 1: 修改 V1__Create_grid_user_table.sql**

移除第 3 行的 username 列和第 19 行的 uk_username 索引：

```sql
CREATE TABLE IF NOT EXISTS `grid_user` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
    `password` VARCHAR(100) NOT NULL COMMENT '密码（BCrypt加密）',
    `phone` VARCHAR(20) NOT NULL COMMENT '手机号',
    `email` VARCHAR(100) DEFAULT NULL COMMENT '邮箱',
    `nickname` VARCHAR(50) DEFAULT NULL COMMENT '昵称',
    `avatar` VARCHAR(500) DEFAULT NULL COMMENT '头像URL',
    `gender` TINYINT DEFAULT 0 COMMENT '性别：0-未知 1-男 2-女',
    `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：0-禁用 1-正常',
    `register_ip` VARCHAR(50) DEFAULT NULL COMMENT '注册IP',
    `last_login_time` DATETIME DEFAULT NULL COMMENT '最后登录时间',
    `last_login_ip` VARCHAR(50) DEFAULT NULL COMMENT '最后登录IP',
    `wx_openid` VARCHAR(50) DEFAULT NULL COMMENT '微信openid',
    `wx_unionid` VARCHAR(50) DEFAULT NULL COMMENT '微信unionid',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_phone` (`phone`),
    KEY `idx_wx_openid` (`wx_openid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='APP用户表';
```

- [ ] **Step 2: 创建 V2__Remove_username_column.sql（用于现有数据库）**

创建新的迁移脚本：

```sql
-- 移除 username 列的迁移脚本（用于已执行过 V1 的数据库）
ALTER TABLE `grid_user` DROP INDEX `uk_username`;
ALTER TABLE `grid_user` DROP COLUMN `username`;
```

- [ ] **Step 3: 提交修改**

```bash
git add backend/grid-app/src/main/resources/db/migration/V1__Create_grid_user_table.sql
git add backend/grid-app/src/main/resources/db/migration/V2__Remove_username_column.sql
git commit -m "refactor: update database schema, remove username column"
```

---

### Task 8: 更新测试用例

**Files:**
- Modify: `backend/grid-app/src/test/java/com/naon/grid/modules/app/rest/AppAuthControllerTest.java`

- [ ] **Step 1: 修改 testRegister() 方法**

修改第 28-44 行的 testRegister() 方法，移除 username 相关代码：

```java
@Test
void testRegister() throws Exception {
    String timestamp = String.valueOf(System.currentTimeMillis());
    String phone = "138" + timestamp.substring(5);

    RegisterDTO registerDTO = new RegisterDTO();
    registerDTO.setPassword("encrypted_password");
    registerDTO.setPhone(phone);
    registerDTO.setDeviceId("test-device-001");

    mockMvc.perform(post("/api/app/auth/register")
            .contentType(MediaType.APPLICATION_JSON)
            .content(objectMapper.writeValueAsString(registerDTO)))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.token").exists());
}
```

- [ ] **Step 2: 提交修改**

```bash
git add backend/grid-app/src/test/java/com/naon/grid/modules/app/rest/AppAuthControllerTest.java
git commit -m "test: update register test case, remove username"
```

---

### Task 9: 编译后端验证修改

**Files:**
- (no file changes)

- [ ] **Step 1: 运行 Maven 编译**

```bash
cd /Users/nano/claude/little-grid/backend
./mvnw clean compile -pl grid-app -am
```

预期：编译成功，无错误

- [ ] **Step 2: 提交（如果需要调整则修改后提交）**

如果编译成功，无需额外提交。如果有错误，修复后提交修复。

---

## 阶段二：前端 Flutter 修改

### Task 10: 修改 auth_service.dart - 添加 nickname 参数

**Files:**
- Modify: `app/lib/core/services/auth_service.dart`

- [ ] **Step 1: 修改 register() 方法**

修改第 33-53 行的 register() 方法，添加可选的 nickname 参数：

```dart
/// Phone registration
static Future<AuthResult> register(String phone, String password, String deviceId, {String? nickname}) async {
  final response = await HttpClient.post(
    Uri.parse('$_baseUrl/register'),
    body: {
      'phone': phone,
      'password': password,
      'deviceId': deviceId,
      if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
    },
    module: 'AuthService',
  );

  if (response.statusCode == 200) {
    final result = AuthResult.fromJson(jsonDecode(response.body));
    await _saveAuthData(result);
    return result;
  } else if (response.statusCode == 409) {
    throw Exception('该手机号已注册，请直接登录');
  } else {
    throw Exception('注册失败: ${response.body}');
  }
}
```

- [ ] **Step 2: 提交修改**

```bash
cd /Users/nano/claude/little-grid
git add app/lib/core/services/auth_service.dart
git commit -m "refactor: add nickname parameter to auth service register"
```

---

### Task 11: 修改 auth_provider.dart - 添加 nickname 参数

**Files:**
- Modify: `app/lib/providers/auth_provider.dart`

- [ ] **Step 1: 修改 register() 方法**

修改第 53-72 行的 register() 方法，添加可选的 nickname 参数：

```dart
/// Phone registration
Future<bool> register(String phone, String password, String deviceId, {String? nickname}) async {
  _isLoading = true;
  notifyListeners();

  try {
    developer.log('AuthProvider: Starting registration for phone=$phone, deviceId=$deviceId', name: 'AuthProvider');
    final result = await AuthService.register(phone, password, deviceId, nickname: nickname);
    _currentUser = result.user;
    _isLoggedIn = true;
    _isLoading = false;
    notifyListeners();
    developer.log('AuthProvider: Registration successful, user=${result.user.id}', name: 'AuthProvider');
    return true;
  } catch (e) {
    developer.log('AuthProvider: Registration failed, error=$e', name: 'AuthProvider');
    _isLoading = false;
    notifyListeners();
    throw e;
  }
}
```

- [ ] **Step 2: 提交修改**

```bash
git add app/lib/providers/auth_provider.dart
git commit -m "refactor: add nickname parameter to auth provider register"
```

---

### Task 12: 修改 register_page.dart - 添加昵称输入框和必填标识

**Files:**
- Modify: `app/lib/pages/login/register_page.dart`

- [ ] **Step 1: 添加昵称控制器**

在第 14-23 行添加昵称控制器：

```dart
class _RegisterPageState extends State<RegisterPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController(); // 新增这行
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _passwordStrength = '';
  Color _strengthColor = Colors.grey;
```

- [ ] **Step 2: 修改 _register() 方法调用**

修改第 86-119 行的 _register() 方法，传递 nickname：

```dart
Future<void> _register() async {
  if (!_validateInput()) return;

  setState(() => _isLoading = true);

  try {
    final deviceId = await _getDeviceId();
    // RSA加密密码
    String encryptedPassword;
    try {
      await RsaService.initialize();
      encryptedPassword = RsaService.encryptPassword(_passwordController.text);
    } catch (e) {
      // 如果RSA加密失败，使用明文（开发测试用）
      encryptedPassword = _passwordController.text;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.register(
      _phoneController.text,
      encryptedPassword,
      deviceId,
      nickname: _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('注册成功')),
    );
    Navigator.of(context).pop();
  } catch (e) {
    _showError(e.toString().replaceAll('Exception: ', ''));
  } finally {
    setState(() => _isLoading = false);
  }
}
```

- [ ] **Step 3: 修改 dispose() 方法**

修改第 195-201 行的 dispose() 方法，添加昵称控制器释放：

```dart
@override
void dispose() {
  _phoneController.dispose();
  _passwordController.dispose();
  _confirmPasswordController.dispose();
  _nicknameController.dispose(); // 新增这行
  super.dispose();
}
```

- [ ] **Step 4: 修改 UI 部分 - 添加红色 * 号和昵称输入框**

修改第 121-193 行的 build() 方法：

1. 手机号标签添加红色 *（第 134 行）
2. 密码标签添加红色 *（第 146 行）
3. 确认密码标签添加红色 *（第 165 行）
4. 在确认密码后添加昵称输入框

完整的 Column children 修改后：

```dart
children: [
  const SizedBox(height: 32),
  TextField(
    controller: _phoneController,
    keyboardType: TextInputType.phone,
    decoration: const InputDecoration(
      labelText: '手机号 *',
      hintText: '请输入手机号',
      prefixIcon: Icon(Icons.phone),
    ),
  ),
  const SizedBox(height: 16),
  TextField(
    controller: _passwordController,
    obscureText: _obscurePassword,
    onChanged: _checkPasswordStrength,
    decoration: InputDecoration(
      labelText: '密码 *',
      hintText: '至少8位，包含字母和数字',
      prefixIcon: const Icon(Icons.lock),
      suffixIcon: IconButton(
        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ),
    ),
  ),
  const SizedBox(height: 4),
  Text(
    _passwordStrength,
    style: TextStyle(color: _strengthColor, fontSize: 12),
  ),
  const SizedBox(height: 16),
  TextField(
    controller: _confirmPasswordController,
    obscureText: _obscureConfirmPassword,
    decoration: InputDecoration(
      labelText: '确认密码 *',
      hintText: '再次输入密码',
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
      ),
    ),
  ),
  const SizedBox(height: 16),
  TextField(
    controller: _nicknameController,
    decoration: const InputDecoration(
      labelText: '昵称（选填）',
      hintText: '请输入昵称',
      prefixIcon: Icon(Icons.person_outline),
    ),
  ),
  const SizedBox(height: 32),
  SizedBox(
    height: 48,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _register,
      child: _isLoading
          ? const CircularProgressIndicator()
          : const Text('注册', style: TextStyle(fontSize: 16)),
    ),
  ),
  const SizedBox(height: 16),
  TextButton(
    onPressed: () => Navigator.of(context).pop(),
    child: const Text('已有账号？去登录'),
  ),
],
```

- [ ] **Step 5: 提交修改**

```bash
git add app/lib/pages/login/register_page.dart
git commit -m "feat: add nickname input field, add required asterisk to labels"
```

---

### Task 13: 验证 Flutter 编译

**Files:**
- (no file changes)

- [ ] **Step 1: 运行 Flutter 分析检查**

```bash
cd /Users/nano/claude/little-grid/app
flutter analyze
```

预期：无严重错误

- [ ] **Step 2: 提交（如果需要调整则修改后提交）**

如果分析成功，无需额外提交。如果有错误，修复后提交修复。

---

## 最终验证

### Task 14: 端到端测试

**Files:**
- (no file changes)

- [ ] **Step 1: 启动后端服务**

```bash
cd /Users/nano/claude/little-grid/backend
./mvnw spring-boot:run -pl grid-app
```

- [ ] **Step 2: 启动 Flutter APP（可选，用于手动测试）**

```bash
cd /Users/nano/claude/little-grid/app
flutter run
```

- [ ] **Step 3: 手动测试注册流程**

1. 打开注册页面，确认：
   - 手机号、密码、确认密码有红色 * 号
   - 有昵称输入框（选填）

2. 不输入昵称直接注册，确认成功，nickname 自动生成 "用户XXXXX"

3. 输入昵称注册，确认使用用户输入的 nickname

---

## 总结

此计划包含 14 个任务，分为两个阶段：
- 阶段一（Task 1-9）：后端 Java 修改
- 阶段二（Task 10-14）：前端 Flutter 修改

每个任务都包含具体的代码修改和提交步骤，确保可以安全、逐步地完成改造。
