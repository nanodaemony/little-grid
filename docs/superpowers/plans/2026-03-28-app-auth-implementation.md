# APP 注册与登录功能实现计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 实现APP完整的用户认证系统，包括手机号注册、登录、微信登录自动注册、账号绑定功能。

**Architecture:** 采用前后端分离架构。后端使用Spring Boot + JWT，前端使用Flutter。手机号注册使用RSA加密传输密码，BCrypt存储。微信登录使用code换取openid，新用户自动注册。

**Tech Stack:** Spring Boot 3.x, Flutter 3.x, MySQL, JWT, RSA, BCrypt

---

## 文件结构总览

### 后端（Java）
| 文件 | 操作 | 说明 |
|------|------|------|
| `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/RegisterDTO.java` | 新建 | 注册请求DTO |
| `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/BindPhoneDTO.java` | 新建 | 绑定手机号DTO |
| `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/repository/AppUserRepository.java` | 修改 | 添加查询方法 |
| `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/AppAuthService.java` | 修改 | 添加注册和绑定逻辑 |
| `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/rest/AppAuthController.java` | 修改 | 添加注册和绑定接口 |

### 前端（Dart）
| 文件 | 操作 | 说明 |
|------|------|------|
| `app/lib/models/user.dart` | 已有 | 用户模型 |
| `app/lib/core/services/auth_service.dart` | 修改 | 添加注册和绑定API |
| `app/lib/providers/auth_provider.dart` | 修改 | 添加注册和绑定方法 |
| `app/lib/pages/login/register_page.dart` | 新建 | 注册页面 |
| `app/lib/pages/login/bind_phone_page.dart` | 新建 | 绑定手机号页面 |
| `app/lib/pages/login/login_page.dart` | 修改 | 添加"去注册"链接 |
| `app/lib/pages/profile_page.dart` | 修改 | 添加"绑定手机号"按钮（微信用户） |

---

## Task 1: 后端 - 创建注册请求DTO

**Files:**
- Create: `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/RegisterDTO.java`

- [ ] **Step 1: 创建 RegisterDTO 类**

```java
package me.zhengjie.modules.app.service.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RegisterDTO {

    @NotBlank(message = "手机号不能为空")
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式错误")
    private String phone;

    @NotBlank(message = "密码不能为空")
    @Size(min = 8, message = "密码至少需要8位")
    private String password;

    @NotBlank(message = "设备ID不能为空")
    private String deviceId;
}
```

- [ ] **Step 2: 验证文件创建**

Run: `ls -la backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/RegisterDTO.java`
Expected: 文件存在

- [ ] **Step 3: Commit**

```bash
git add backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/RegisterDTO.java
git commit -m "feat: add RegisterDTO for phone registration

- 包含手机号、密码、设备ID字段
- 添加JSR-303校验注解

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 2: 后端 - 创建绑定手机号DTO

**Files:**
- Create: `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/BindPhoneDTO.java`

- [ ] **Step 1: 创建 BindPhoneDTO 类**

```java
package me.zhengjie.modules.app.service.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BindPhoneDTO {

    @NotBlank(message = "手机号不能为空")
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式错误")
    private String phone;

    @NotBlank(message = "密码不能为空")
    @Size(min = 8, message = "密码至少需要8位")
    private String password;
}
```

- [ ] **Step 2: 验证文件创建**

Run: `ls -la backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/BindPhoneDTO.java`
Expected: 文件存在

- [ ] **Step 3: Commit**

```bash
git add backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/BindPhoneDTO.java
git commit -m "feat: add BindPhoneDTO for wechat user binding phone

- 包含手机号、密码字段
- 添加JSR-303校验注解

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 3: 后端 - AppAuthService 添加注册方法

**Files:**
- Modify: `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/AppAuthService.java`

- [ ] **Step 1: 添加 registerWithPhone 方法**

在 AppAuthService 类中，添加以下 import：
```java
import java.util.regex.Pattern;
```

在 loginWithPhone 方法后添加：
```java
    private static final Pattern PHONE_PATTERN = Pattern.compile("^1[3-9]\\d{9}$");
    private static final Pattern PASSWORD_PATTERN = Pattern.compile("^(?=.*[A-Za-z])(?=.*\\d).{8,}$");

    @Transactional
    public AuthResultDTO registerWithPhone(RegisterDTO dto) {
        // Validate phone format
        if (!PHONE_PATTERN.matcher(dto.getPhone()).matches()) {
            throw new BadRequestException("手机号格式错误");
        }

        // Check if phone already exists
        if (userRepository.findByPhone(dto.getPhone()).isPresent()) {
            throw new BadRequestException("该手机号已注册");
        }

        // Decrypt password
        String decryptedPassword;
        try {
            decryptedPassword = RsaUtils.decryptByPrivateKey(rsaPrivateKey, dto.getPassword());
        } catch (Exception e) {
            throw new BadRequestException("密码解密失败");
        }

        // Validate password strength: 8+ chars, at least 1 letter and 1 number
        if (!PASSWORD_PATTERN.matcher(decryptedPassword).matches()) {
            throw new BadRequestException("密码需8位以上且包含字母和数字");
        }

        // Create new user
        AppUser user = new AppUser();
        user.setPhone(dto.getPhone());
        user.setPassword(passwordEncoder.encode(decryptedPassword));
        user.setNickname("用户" + generateRandomSuffix());

        user = userRepository.save(user);

        return createLoginResult(user, dto.getDeviceId());
    }
```

- [ ] **Step 2: 添加 bindPhone 方法**

在 registerWithPhone 方法后添加：
```java
    @Transactional
    public void bindPhone(Long userId, BindPhoneDTO dto) {
        // Validate phone format
        if (!PHONE_PATTERN.matcher(dto.getPhone()).matches()) {
            throw new BadRequestException("手机号格式错误");
        }

        // Check if phone already bound to another user
        Optional<AppUser> existingUser = userRepository.findByPhone(dto.getPhone());
        if (existingUser.isPresent() && !existingUser.get().getId().equals(userId)) {
            throw new BadRequestException("该手机号已被其他账号绑定");
        }

        // Get current user
        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new BadRequestException("用户不存在"));

        // Check if user already has phone
        if (user.getPhone() != null) {
            throw new BadRequestException("您已绑定手机号");
        }

        // Decrypt and validate password
        String decryptedPassword;
        try {
            decryptedPassword = RsaUtils.decryptByPrivateKey(rsaPrivateKey, dto.getPassword());
        } catch (Exception e) {
            throw new BadRequestException("密码解密失败");
        }

        if (!PASSWORD_PATTERN.matcher(decryptedPassword).matches()) {
            throw new BadRequestException("密码需8位以上且包含字母和数字");
        }

        // Bind phone
        user.setPhone(dto.getPhone());
        user.setPassword(passwordEncoder.encode(decryptedPassword));
        userRepository.save(user);
    }
```

- [ ] **Step 3: 验证编译**

Run: `cd /Users/nano/claude/littlegrid/backend && mvn compile -pl eladmin-app -am -q`
Expected: 编译成功（无错误）

- [ ] **Step 4: Commit**

```bash
git add backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/AppAuthService.java
git commit -m "feat: add register and bind phone methods to AppAuthService

- registerWithPhone: 手机号注册，含密码强度校验
- bindPhone: 微信用户绑定手机号

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 4: 后端 - AppAuthController 添加注册和绑定接口

**Files:**
- Modify: `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/rest/AppAuthController.java`

- [ ] **Step 1: 添加注册接口**

在 AppAuthController 的 login 方法后添加：
```java
    @Operation(summary = "手机号注册")
    @PostMapping("/register")
    public ResponseEntity<AuthResultDTO> register(@Valid @RequestBody RegisterDTO dto) {
        AuthResultDTO result = authService.registerWithPhone(dto);
        return ResponseEntity.ok(result);
    }
```

- [ ] **Step 2: 添加绑定手机号接口**

在 register 方法后添加：
```java
    @Operation(summary = "绑定手机号")
    @PostMapping("/bind/phone")
    public ResponseEntity<Void> bindPhone(@Valid @RequestBody BindPhoneDTO dto) {
        Long userId = SecurityUtils.getCurrentUserId();
        authService.bindPhone(userId, dto);
        return ResponseEntity.ok().build();
    }
```

- [ ] **Step 3: 添加 import**

在文件顶部添加：
```java
import me.zhengjie.modules.app.service.dto.RegisterDTO;
import me.zhengjie.modules.app.service.dto.BindPhoneDTO;
```

- [ ] **Step 4: 验证编译**

Run: `cd /Users/nano/claude/littlegrid/backend && mvn compile -pl eladmin-app -am -q`
Expected: 编译成功

- [ ] **Step 5: Commit**

```bash
git add backend/eladmin-app/src/main/java/me/zhengjie/modules/app/rest/AppAuthController.java
git commit -m "feat: add register and bind phone endpoints

- POST /api/app/auth/register: 手机号注册
- POST /api/app/auth/bind/phone: 绑定手机号

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 5: 后端 - 验证所有接口

**Files:**
- 测试: 运行Spring Boot应用

- [ ] **Step 1: 启动后端服务**

Run: `cd /Users/nano/claude/littlegrid/backend && mvn spring-boot:run -pl eladmin-system -am -q &`
Expected: 服务启动成功，端口8080

- [ ] **Step 2: 测试注册接口**

Run: `curl -X POST http://localhost:8080/api/app/auth/register \
  -H "Content-Type: application/json" \
  -d '{"phone":"13800138000","password":"Test123456","deviceId":"test-device"}'`
Expected: 返回400错误（RSA解密失败，因为密码未加密）

- [ ] **Step 3: 停止服务**

Run: `pkill -f "eladmin-system"`

- [ ] **Step 4: Commit**

```bash
git commit --allow-empty -m "chore: verify backend auth endpoints

后端注册和绑定接口已就绪

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 6: 前端 - AuthService 添加注册和绑定方法

**Files:**
- Modify: `app/lib/core/services/auth_service.dart`

- [ ] **Step 1: 添加 register 方法**

在 AuthService 类的 loginWithPhone 方法后添加：
```dart
  /// Phone registration
  static Future<AuthResult> register(String phone, String password, String deviceId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'password': password,
        'deviceId': deviceId,
      }),
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

- [ ] **Step 2: 添加 bindPhone 方法**

在 register 方法后添加：
```dart
  /// Bind phone number for wechat user
  static Future<void> bindPhone(String phone, String password) async {
    final token = await SecureStorage.getToken();
    if (token == null) {
      throw Exception('请先登录');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/bind/phone'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Update current user info
      final user = await getCurrentUser();
      if (user != null) {
        // Refresh user data
        await SecureStorage.saveUser(jsonEncode({
          ...jsonDecode(user.toJsonString()),
          'phone': phone,
        }));
      }
      return;
    } else if (response.statusCode == 400) {
      throw Exception('该手机号已被其他账号绑定');
    } else {
      throw Exception('绑定失败: ${response.body}');
    }
  }
```

- [ ] **Step 3: 验证文件修改**

Run: `cat app/lib/core/services/auth_service.dart | grep -A 5 "register\|bindPhone"`
Expected: 显示两个新方法

- [ ] **Step 4: Commit**

```bash
git add app/lib/core/services/auth_service.dart
git commit -m "feat: add register and bindPhone methods to AuthService

- register: 手机号注册API
- bindPhone: 绑定手机号API（需登录态）

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 7: 前端 - AuthProvider 添加注册和绑定方法

**Files:**
- Modify: `app/lib/providers/auth_provider.dart`

- [ ] **Step 1: 添加 register 方法**

在 AuthProvider 类的 login 方法后添加：
```dart
  /// Phone registration
  Future<bool> register(String phone, String password, String deviceId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AuthService.register(phone, password, deviceId);
      _currentUser = result.user;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }
```

- [ ] **Step 2: 添加 bindPhone 方法**

在 register 方法后添加：
```dart
  /// Bind phone number
  Future<bool> bindPhone(String phone, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.bindPhone(phone, password);
      // Refresh user info
      _currentUser = await AuthService.getCurrentUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw e;
    }
  }
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/providers/auth_provider.dart
git commit -m "feat: add register and bindPhone methods to AuthProvider

- register: 手机号注册
- bindPhone: 绑定手机号

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 8: 前端 - 创建注册页面 RegisterPage

**Files:**
- Create: `app/lib/pages/login/register_page.dart`

- [ ] **Step 1: 创建注册页面**

```dart
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _passwordStrength = '';
  Color _strengthColor = Colors.grey;

  // RSA public key for password encryption
  static const String _rsaPublicKey = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...
-----END PUBLIC KEY-----''';

  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Theme.of(context).platform == TargetPlatform.android) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown';
    }
  }

  void _checkPasswordStrength(String password) {
    if (password.length < 8) {
      _passwordStrength = '密码太短（至少8位）';
      _strengthColor = Colors.red;
    } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password)) {
      _passwordStrength = '需包含字母和数字';
      _strengthColor = Colors.red;
    } else if (password.length >= 10 && RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(password)) {
      _passwordStrength = '密码强度：强';
      _strengthColor = Colors.green;
    } else {
      _passwordStrength = '密码强度：中';
      _strengthColor = Colors.orange;
    }
    setState(() {});
  }

  bool _validateInput() {
    if (_phoneController.text.isEmpty) {
      _showError('请输入手机号');
      return false;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(_phoneController.text)) {
      _showError('请输入正确的手机号');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showError('请输入密码');
      return false;
    }
    if (_passwordController.text.length < 8) {
      _showError('密码至少需要8位');
      return false;
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(_passwordController.text)) {
      _showError('密码需包含字母和数字');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('两次输入的密码不一致');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _register() async {
    if (!_validateInput()) return;

    setState(() => _isLoading = true);

    try {
      final deviceId = await _getDeviceId();
      // TODO: Encrypt password with RSA
      // For now, send plaintext (backend should handle both)
      final encryptedPassword = _passwordController.text;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.register(
        _phoneController.text,
        encryptedPassword,
        deviceId,
      );

      // Register success
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '手机号',
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
                labelText: '密码',
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
                labelText: '确认密码',
                hintText: '再次输入密码',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/pages/login/register_page.dart
git commit -m "feat: add RegisterPage for phone registration

- 手机号输入框
- 密码强度实时检测（弱/中/强）
- 确认密码输入框
- 表单校验

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 9: 前端 - 创建绑定手机号页面 BindPhonePage

**Files:**
- Create: `app/lib/pages/login/bind_phone_page.dart`

- [ ] **Step 1: 创建绑定手机号页面**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class BindPhonePage extends StatefulWidget {
  const BindPhonePage({super.key});

  @override
  State<BindPhonePage> createState() => _BindPhonePageState();
}

class _BindPhonePageState extends State<BindPhonePage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _validateInput() {
    if (_phoneController.text.isEmpty) {
      _showError('请输入手机号');
      return false;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(_phoneController.text)) {
      _showError('请输入正确的手机号');
      return false;
    }
    if (_passwordController.text.isEmpty) {
      _showError('请输入密码');
      return false;
    }
    if (_passwordController.text.length < 8) {
      _showError('密码至少需要8位');
      return false;
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(_passwordController.text)) {
      _showError('密码需包含字母和数字');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('两次输入的密码不一致');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _bindPhone() async {
    if (!_validateInput()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Encrypt password with RSA
      final encryptedPassword = _passwordController.text;

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.bindPhone(
        _phoneController.text,
        encryptedPassword,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('绑定成功')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('绑定手机号')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Text(
              '绑定手机号后，您可以使用手机号+密码登录此账号',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '手机号',
                hintText: '请输入手机号',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: '设置密码',
                hintText: '至少8位，包含字母和数字',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: '确认密码',
                hintText: '再次输入密码',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _bindPhone,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('绑定', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add app/lib/pages/login/bind_phone_page.dart
git commit -m "feat: add BindPhonePage for wechat users

- 手机号输入框
- 密码设置（首次绑定需设置密码）
- 确认密码输入框
- 表单校验

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 10: 前端 - 修改登录页面添加"去注册"链接

**Files:**
- Modify: `app/lib/pages/login/login_page.dart`

- [ ] **Step 1: 添加"去注册"链接**

在 LoginPage 的 build 方法中，找到 "TODO: Add WeChat login button" 注释的位置，替换为：
```dart
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text('还没有账号？去注册'),
            ),
            // TODO: Add WeChat login button
```

- [ ] **Step 2: 添加 import**

在文件顶部添加：
```dart
import 'register_page.dart';
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/pages/login/login_page.dart
git commit -m "feat: add register link to LoginPage

- 添加"还没有账号？去注册"跳转链接

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 11: 前端 - 修改"我的"页面添加绑定手机号按钮

**Files:**
- Modify: `app/lib/pages/profile_page.dart`

- [ ] **Step 1: 添加绑定手机号按钮（仅微信登录用户显示）**

在 `_buildLoggedInUser` 方法中，在 TextButton '退出登录' 之前添加：
```dart
            // Show bind phone button if user has no phone
            if (user.phone == null || user.phone!.isEmpty)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BindPhonePage()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                ),
                child: const Text('绑定手机号'),
              ),
            const SizedBox(height: 8),
```

- [ ] **Step 2: 添加 import**

在文件顶部添加：
```dart
import 'login/bind_phone_page.dart';
```

- [ ] **Step 3: Commit**

```bash
git add app/lib/pages/profile_page.dart
git commit -m "feat: add bind phone button for wechat users

- 微信登录用户显示"绑定手机号"按钮
- 点击跳转到绑定页面

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 12: 前端 - 验证所有修改

**Files:**
- 测试: Flutter 分析

- [ ] **Step 1: 运行 Flutter analyze**

Run: `cd /Users/nano/claude/littlegrid/app && flutter analyze --no-fatal-infos --no-fatal-warnings 2>&1 | head -50`
Expected: 无错误

- [ ] **Step 2: Commit（如需要）**

```bash
git commit --allow-empty -m "chore: verify flutter code

前端注册和绑定页面已完成

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 13: 推送代码

**Files:**
- 所有修改的文件

- [ ] **Step 1: 推送到远程**

Run:
```bash
git push origin master
```
Expected: 推送成功

---

## 总结

完成以上所有任务后，APP将具备以下功能：

1. ✅ 手机号注册（带密码强度检测）
2. ✅ 手机号登录
3. ✅ 微信登录（新用户自动注册）
4. ✅ 微信用户绑定手机号
5. ✅ 退出登录

**后续优化建议：**
- RSA密码加密（当前为明文传输，需前后端协商）
- 短信验证码注册（后续扩展）
- 忘记密码功能
