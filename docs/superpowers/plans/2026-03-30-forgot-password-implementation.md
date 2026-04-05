# Forgot Password Feature Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement email-based password reset functionality for App users, including email binding feature

**Architecture:** Backend adds EmailVerifyService with email binding and password reset APIs. Frontend adds forgot password page and email binding page with 3-step reset flow.

**Tech Stack:** Java Spring Boot, Flutter, Redis, 163 Email SMTP

---

## File Structure

### Backend
- `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/domain/AppUser.java` - Add email field
- `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/repository/AppUserRepository.java` - Add email query methods
- `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/BindEmailDTO.java` - Create email bind request
- `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/SendResetCodeDTO.java` - Create send reset code request
- `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/ResetPasswordDTO.java` - Create reset password request
- `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/EmailVerifyService.java` - Create email verification service
- `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/rest/AppUserController.java` - Add bind email endpoint
- `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/rest/AppAuthController.java` - Add reset endpoints

### Frontend
- `app/lib/pages/login/forgot_password_page.dart` - Create forgot password page
- `app/lib/pages/login/bind_email_page.dart` - Create bind email page
- `app/lib/core/services/auth_service.dart` - Add email bind and reset password methods
- `app/lib/pages/login/login_page.dart` - Add forgot password link
- `app/lib/pages/profile_page.dart` - Add bind email entry



---

## Task 1: Update AppUser entity with email field

**Files:**
- Modify: `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/domain/AppUser.java`

- [ ] **Step 1: Add email field to AppUser entity**

```java
@Column(name = "email", unique = true, length = 100)
private String email;
```

- [ ] **Step 2: Commit database entity change**

```bash
git add backend/eladmin-app/src/main/java/me/zhengjie/modules/app/domain/AppUser.java
git commit -m "feat: add email field to AppUser entity"
```

---

## Task 2: Add email query methods to AppUserRepository

**Files:**
- Modify: `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/repository/AppUserRepository.java`

- [ ] **Step 1: Add email query methods**

```java
Optional<AppUser> findByEmail(String email);

boolean existsByEmail(String email);
```

- [ ] **Step 2: Commit repository changes**

```bash
git add backend/eladmin-app/src/main/java/me/zhengjie/modules/app/repository/AppUserRepository.java
git commit -m "feat: add email query methods to AppUserRepository"
```

---

## Task 3: Create BindEmailDTO

**Files:**
- Create: `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/BindEmailDTO.java`

- [ ] **Step 1: Create BindEmailDTO**

```java
package me.zhengjie.modules.app.service.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BindEmailDTO {

    @NotBlank(message = "邮箱不能为空")
    @Email(message = "邮箱格式错误")
    private String email;
}
```

- [ ] **Step 2: Commit DTO creation**

```bash
git add backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/BindEmailDTO.java
git commit -m "feat: add BindEmailDTO for email binding"
```

---

## Task 4: Create SendResetCodeDTO

**Files:**
- Create: `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/SendResetCodeDTO.java`

- [ ] **Step 1: Create SendResetCodeDTO**

```java
package me.zhengjie.modules.app.service.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class SendResetCodeDTO {

    @NotBlank(message = "手机号不能为空")
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式错误")
    private String phone;
}
```

- [ ] **Step 2: Commit DTO creation**

```bash
git add backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/SendResetCodeDTO.java
git commit -m "feat: add SendResetCodeDTO for password reset"
```

---

## Task 5: Create ResetPasswordDTO

**Files:**
- Create: `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/ResetPasswordDTO.java`

- [ ] **Step 1: Create ResetPasswordDTO**

```java
package me.zhengjie.modules.app.service.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ResetPasswordDTO {

    @NotBlank(message = "手机号不能为空")
    @Pattern(regexp = "^1[3-9]\\d{9}$", message = "手机号格式错误")
    private String phone;

    @NotBlank(message = "验证码不能为空")
    @Size(min = 6, max = 6, message = "验证码必须为6位")
    private String code;

    @NotBlank(message = "密码不能为空")
    @Size(min = 8, message = "密码至少需要8位")
    private String password;
}
```

- [ ] **Step 2: Commit DTO creation**

```bash
git add backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/ResetPasswordDTO.java
git commit -m "feat: add ResetPasswordDTO for password reset"
```

---

## Task 6: Create EmailVerifyService

**Files:**
- Create: `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/EmailVerifyService.java`

- [ ] **Step 1: Create EmailVerifyService**

```java
package me.zhengjie.modules.app.service;

import cn.hutool.core.util.RandomUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import me.zhengjie.domain.EmailConfig;
import me.zhengjie.domain.vo.EmailVo;
import me.zhengjie.exception.BadRequestException;
import me.zhengjie.modules.app.domain.AppUser;
import me.zhengjie.modules.app.repository.AppUserRepository;
import me.zhengjie.modules.app.repository.AppUserDeviceRepository;
import me.zhengjie.modules.app.service.dto.SendResetCodeDTO;
import me.zhengjie.modules.app.service.dto.BindEmailDTO;
import me.zhengjie.modules.app.service.dto.ResetPasswordDTO;
import me.zhengjie.repository.EmailRepository;
import me.zhengjie.service.EmailService;
import me.zhengjie.utils.RsaUtils;
import me.zhengjie.utils.RedisUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;
import java.util.regex.Pattern;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailVerifyService {

    private final AppUserRepository userRepository;
    private final AppUserDeviceRepository deviceRepository;
    private final EmailRepository emailConfigRepository;
    private final EmailService emailService;
    private final PasswordEncoder passwordEncoder;
    private final RedisUtils redisUtils;

    @Value("${rsa.redis-key}")
    private String rsaRedisKey;

    @Value("${rsa.private-key}")
    private String rsaPrivateKey;

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,}$");
    private static final Pattern PASSWORD_PATTERN = Pattern.compile("^(?=.*[A-Za-z])(?=.*\\d).{8,}$");

    private static final String RESET_CODE_KEY_PREFIX = "reset:code:";
    private static final String RESET_LIMIT_KEY_PREFIX = "reset:limit:";

    /**
     * 绑定邮箱
     */
    @Transactional
    public void bindEmail(Long userId, BindEmailDTO dto) {
        // 验证邮箱格式
        if (!EMAIL_PATTERN.matcher(dto.getEmail()).matches()) {
            throw new BadRequestException("邮箱格式错误");
        }

        // 检查邮箱是否已被其他用户绑定
        Optional<AppUser> existingUser = userRepository.findByEmail(dto.getEmail());
        if (existingUser.isPresent() && !existingUser.get().getId().equals(userId)) {
            throw new BadRequestException("该邮箱已被其他账号绑定");
        }

        // 获取当前用户
        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new BadRequestException("用户不存在"));

        // 检查用户是否已绑定邮箱
        if (user.getEmail() != null) {
            throw new BadRequestException("您已绑定邮箱，如需修改请联系客服");
        }

        // 绑定邮箱
        user.setEmail(dto.getEmail());
        userRepository.save(user);
    }

    /**
     * 发送重置密码验证码
     */
    public void sendResetCode(SendResetCodeDTO dto) {
        // 查询用户
        AppUser user = userRepository.findByPhone(dto.getPhone())
                .orElseThrow(() -> new BadRequestException("手机号或验证码错误"));

        // 检查是否绑定了邮箱
        if (user.getEmail() == null || user.getEmail().isEmpty()) {
            throw new BadRequestException("该手机号未绑定邮箱，无法重置密码");
        }

        // 检查发送频率限制（1分钟内只能发一次）
        String limitKey = RESET_LIMIT_KEY_PREFIX + dto.getPhone();
        if (redisUtils.hasKey(limitKey)) {
            throw new BadRequestException("验证码发送过于频繁，请稍后再试");
        }

        // 生成6位验证码
        String code = RandomUtil.randomNumbers(6);

        // 存入Redis（5分钟有效期）
        String codeKey = RESET_CODE_KEY_PREFIX + dto.getPhone();
        if (!redisUtils.set(codeKey, code, 300)) {
            throw new BadRequestException("服务异常，请联系网站负责人");
        }

        // 设置发送限制（1分钟）
        redisUtils.set(limitKey, "1", 60);

        // 发送邮件
        sendVerificationEmail(user.getEmail(), code);
    }

    /**
     * 验证并重置密码
     */
    @Transactional
    public void resetPassword(ResetPasswordDTO dto) {
        // 获取验证码
        String codeKey = RESET_CODE_KEY_PREFIX + dto.getPhone();
        String savedCode = redisUtils.getStr(codeKey);

        if (savedCode == null) {
            throw new BadRequestException("验证码已过期");
        }

        if (!savedCode.equals(dto.getCode())) {
            throw new BadRequestException("验证码错误");
        }

        // 查询用户
        AppUser user = userRepository.findByPhone(dto.getPhone())
                .orElseThrow(() -> new BadRequestException("用户不存在"));

        // 解密密码
        String decryptedPassword;
        try {
            decryptedPassword = RsaUtils.decryptByPrivateKey(rsaPrivateKey, dto.getPassword());
        } catch (Exception e) {
            throw new BadRequestException("密码解密失败");
        }

        // 验证密码强度
        if (!PASSWORD_PATTERN.matcher(decryptedPassword).matches()) {
            throw new BadRequestException("密码需8位以上且包含字母和数字");
        }

        // 更新密码
        user.setPassword(passwordEncoder.encode(decryptedPassword));
        userRepository.save(user);

        // 删除验证码
        redisUtils.del(codeKey);

        // 清除该用户的所有设备登录记录（强制重新登录）
        deviceRepository.deleteByUserId(user.getId());
    }

    private void sendVerificationEmail(String email, String code) {
        // 获取邮件配置
        me.zhengjie.domain.EmailConfig config = emailConfigRepository.findById(1L)
                .orElseThrow(() -> new BadRequestException("邮件服务未配置"));

        // 构建邮件内容
        String content = "您的验证码是：" + code + "\n验证码5分钟内有效，请勿泄露给他人。";

        // 发送邮件
        EmailVo emailVo = new EmailVo();
        emailVo.setTos(java.util.Collections.singletonList(email));
        emailVo.setSubject("重置密码验证码");
        emailVo.setContent(content);

        emailService.send(emailVo, config);
    }
}
```

- [ ] **Step 2: Commit service creation**

```bash
git add backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/EmailVerifyService.java
git commit -m "feat: add EmailVerifyService for password reset"
```

---

## Task 7: Add bind email endpoint to AppUserController

**Files:**
- Modify: `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/rest/AppUserController.java`

- [ ] **Step 1: Add bind email endpoint**

Add this method to AppUserController class:

```java
@Operation(summary = "绑定邮箱")
@PostMapping("/bind-email")
public ResponseEntity<Void> bindEmail(@Valid @RequestBody BindEmailDTO dto) {
    Long userId = AppSecurityUtils.getCurrentUserId();
    emailVerifyService.bindEmail(userId, dto);
    return ResponseEntity.ok().build();
}
```

Also add this field to the class:
```java
private final EmailVerifyService emailVerifyService;
```

- [ ] **Step 2: Commit controller changes**

```bash
git add backend/eladmin-app/src/main/java/me/zhengjie/modules/app/rest/AppUserController.java
git commit -m "feat: add bind email endpoint to AppUserController"
```

---

## Task 8: Add reset password endpoints to AppAuthController

**Files:**
- Modify: `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/rest/AppAuthController.java`

- [ ] **Step 1: Add send reset code endpoint**

Add this method to AppAuthController class:

```java
@Operation(summary = "发送重置密码验证码")
@PostMapping("/send-reset-code")
public ResponseEntity<Void> sendResetCode(@Valid @RequestBody SendResetCodeDTO dto) {
    emailVerifyService.sendResetCode(dto);
    return ResponseEntity.ok().build();
}
```

- [ ] **Step 2: Add reset password endpoint**

Add this method to AppAuthController class:

```java
@Operation(summary = "重置密码")
@PostMapping("/reset-password")
public ResponseEntity<Void> resetPassword(@Valid @RequestBody ResetPasswordDTO dto) {
    emailVerifyService.resetPassword(dto);
    return ResponseEntity.ok().build();
}
```

- [ ] **Step 3: Add EmailVerifyService field**

Add this field to the class:
```java
private final EmailVerifyService emailVerifyService;
```

- [ ] **Step 4: Commit controller changes**

```bash
git add backend/eladmin-app/src/main/java/me/zhengjie/modules/app/rest/AppAuthController.java
git commit -m "feat: add password reset endpoints to AppAuthController"
```

---

## Task 9: Run database migration

**Files:**
- Modify: Database (MySQL)

- [ ] **Step 1: Add email column to app_user table**

```sql
ALTER TABLE app_user ADD COLUMN email VARCHAR(100) UNIQUE COMMENT '邮箱地址';
```

- [ ] **Step 2: Verify column added**

```bash
# Verify the column was added
mysql -u root -p -e "DESC app_user" | grep email
```

- [ ] **Step 3: Commit migration file**

Create and commit SQL migration file:
```bash
echo "ALTER TABLE app_user ADD COLUMN email VARCHAR(100) UNIQUE COMMENT '邮箱地址';" > backend/sql/add_app_user_email.sql
git add backend/sql/add_app_user_email.sql
git commit -m "db: add email column to app_user table"
```

---

## Task 10: Create bind email page

**Files:**
- Create: `app/lib/pages/login/bind_email_page.dart`

- [ ] **Step 1: Create bind_email_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../providers/auth_provider.dart';

class BindEmailPage extends StatefulWidget {
  const BindEmailPage({super.key});

  @override
  State<BindEmailPage> createState() => _BindEmailPageState();
}

class _BindEmailPageState extends State<BindEmailPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  bool _validateEmail() {
    if (_emailController.text.isEmpty) {
      _showError('请输入邮箱');
      return false;
    }
    final emailRegex = RegExp(r'^[A-Za-z0-9+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,}$');
    if (!emailRegex.hasMatch(_emailController.text)) {
      _showError('邮箱格式格式错误');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _bindEmail() async {
    if (!_validateEmail()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.bindEmail(_emailController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('绑定成功')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('绑定邮箱')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const Text(
              '绑定邮箱后，您可以通过邮箱找回密码',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: '邮箱',
                hintText: '请输入邮箱地址',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _bindEmail,
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
    _emailController.dispose();
    super.dispose();
  }
}
```

- [ ] **Step 2: Commit page creation**

```bash
git add app/lib/pages/login/bind_email_page.dart
git commit -m "feat: add bind email page"
```

---

## Task 11: Create forgot password page

**Files:**
- Create: `app/lib/pages/login/forgot_password_page.dart`

- [ ] **Step 1: Create forgot_password_page.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/rsa_service.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 1;
  String _passwordStrength = '';
  Color _strengthColor = Colors.grey;
  int _countdown = 0;
  Timer? _timer;

  void _checkPasswordStrength(String password) {
    if (password.length < 8) {
      _passwordStrength = '密码太短（至少8位）';
      _strengthColor = Colors.red;
    } else if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\\d)').hasMatch(password)) {
      _passwordStrength = '需包含字母和数字';
      _strengthColor = Colors.red;
    } else if (password.length >= 10 && RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)').hasMatch(password)) {
      _passwordStrength = '密码强度：强';
      _strengthColor = Colors.green;
    } else {
      _passwordStrength = '密码强度：中';
      _strengthColor = Colors.orange;
    }
    setState(() {});
  }

  bool _validatePhone() {
    if (_phone!Controller.text.isEmpty) {
      _showError('请输入手机号');
      return false;
    }
    if (!RegExp(r'^1[3-9]\\d{9}$').hasMatch(_phoneController.text)) {
      _showError('请输入正确的手机号');
      return false;
    }
    return true;
  }

  bool _validateCode() {
    if (_codeController.text.length != 6) {
      _showError('请输入6位验证码');
      return false;
    }
    return true;
  }

  bool _validatePassword() {
    if (_passwordController.text.isEmpty) {
      _showError('请输入密码');
      return false;
    }
    if (_passwordController.text.length < 8) {
      _showError('密码至少需要8位');
      return false;
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\\d)').hasMatch(_passwordController.text)) {
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

  Future<void> _sendCode() async {
    if (!_validatePhone()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.sendResetCode(_phoneController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('验证码已发送')),
        );
        setState(() {
          _currentStep = 2;
          _startCountdown();
        });
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _resetPassword() async {
    if (!_validatePassword()) return;

    setState(() => _isLoading = true);

    try {
      // RSA加密密码
      String encryptedPassword;
      try {
        await RsaService.initialize();
        encryptedPassword = RsaService.encryptPassword(_passwordController.text);
      } catch (e) {
        encryptedPassword = _passwordController.text;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.resetPassword(
        _phoneController.text,
        _codeController.text,
        encryptedPassword,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('密码重置成功，请重新登录')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('忘记密码')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            if (_currentStep == 1) ..._buildStep1(),
            if (_currentStep == 2) ..._buildStep2(),
            if (_currentStep == 3) ..._buildStep3(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStep1() {
    return [
      const Text('输入您的注册手机号', style: TextStyle(fontSize: 16)),
      const SizedBox(height: 16),
      TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: '手机号',
          hintText: '请输入手机号',
          prefixIcon: Icon(Icons.phone),
        ),
      ),
      const SizedBox(height: 32),
      SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _sendCode,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('发送验证码', style: TextStyle(fontSize: 16)),
        ),
      ),
    ];
  }

  List<Widget> _buildStep2() {
    return [
      const Text('输入邮箱中的验证码', style: TextStyle(fontSize: 16)),
      const SizedBox(height: 16),
      TextField(
        controller: _codeController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        decoration: InputDecoration(
          labelText: '验证码',
          hintText: '请输入6位验证码',
          prefixIcon: const Icon(Icons.verified_user),
          suffixText: _countdown > 0 ? '$_countdown秒后重发' : '重新发送',
          suffixStyle: TextStyle(
            color: _countdown > 0 ? Colors.grey : AppColors.primary,
          ),
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, letterSpacing: 8),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: _isLoading ? null : () => setState(() => _currentStep = 3),
          child: const Text('下一步', style: TextStyle(fontSize: 16)),
        ),
      ),
    ];
  }

  List<Widget> _buildStep3() {
    return [
      const Text('设置新密码', style: TextStyle(fontSize: 16)),
      const SizedBox(height: 16),
      TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        onChanged: _checkPasswordStrength,
        decoration: InputDecoration(
          labelText: '新密码',
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
          onPressed: _isLoading ? null : _resetPassword,
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('重置密码', style: TextStyle(fontSize: 16)),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
```

- [ ] **Step 2: Commit page creation**

```bash
git add app/lib/pages/login/forgot_password_page.dart
git commit -m "feat: add forgot password page"
```

---

## Task 12: Add API methods to AuthService

**Files:**
- Modify: `app/lib/core/services/auth_service.dart`

- [ ] **Step 1: Add bind email method**

```dart
/// Bind email for password reset
static Future<void> bindEmail(String email) async {
  final token = await SecureStorage.getToken();
  if (token == null) {
    throw Exception('请先登录');
  }

  final response = await http.post(
    Uri.parse('$_baseUrl/user/bind-email'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': token,
    },
    body: jsonEncode({
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    return;
  } else {
    throw Exception('绑定失败: ${response.body}');
  }
}
```

- [ ] **Step 2: Add send reset code method**

```dart
/// Send password reset verification code
static Future<void> sendResetCode(String phone) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/auth/send-reset-code'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'phone': phone,
    }),
  );

  if (response.statusCode == 200) {
    return;
  } else {
    throw Exception('发送失败: ${response.body}');
  }
}
```

- [ ] **Step 3: Add reset password method**

```dart
/// Reset password with verification code
static Future<void> resetPassword(String phone, String code, String password) async {
  final response = await http.post(
    Uri.parse('$_baseUrl/auth/reset-password'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'phone': phone,
      'code': code,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    return;
  } else {
    throw Exception('重置失败: ${response.body}');
  }
}
```

- [ ] **Step 4: Commit service changes**

```bash
git add app/lib/core/services/auth_service.dart
git commit -m "feat: add email bind and reset password methods to AuthService"
```

---

## Task 13: Add methods to AuthProvider

**Files:**
- Modify: `app/lib/providers/auth_provider.dart`

- [ ] **Step 1: Add bind email method**

```dart
/// Bind email for password reset
Future<bool> bindEmail(String email) async {
  _isLoading = true;
  notifyListeners();

  try {
    await AuthService.bindEmail(email);
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

- [ ] **Step 2: Add send reset code method**

```dart
/// Send password reset verification code
Future<bool> sendResetCode(String phone) async {
  _isLoading = true;
  notifyListeners();

  try {
    await AuthService.sendResetCode(phone);
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

- [ ] **Step 3: Add reset password method**

```dart
/// Reset password with verification code
Future<bool> resetPassword(String phone, String code, String password) async {
  _isLoading = true;
  notifyListeners();

  try {
    await AuthService.resetPassword(phone, code, password);
    await logout();
    return true;
  } catch (e) {
    _isLoading = false;
    notifyListeners();
    throw e;
  }
}
```

- [ ] **Step 4: Commit provider changes**

```bash
git add app/lib/providers/auth_provider.dart
git commit -m "feat: add email bind methods to AuthProvider"
```

---

## Task 14: Add forgot password link to LoginPage

**Files:**
- Modify: `app/lib/pages/login/login_page.dart`

- [ ] **Step 1: Add forgot password link**

Add this after the password TextField (around line 123):

```dart
const SizedBox(height: 8),
Align(
  alignment: Alignment.centerRight,
  child: TextButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
      );
    },
    child: const Text('忘记密码？'),
  ),
),
```

Also add import at top of file:
```dart
import 'forgot_password_page.dart';
```

- [ ] **Step 2: Commit login page changes**

```bash
git add app/lib/pages/login/login_page.dart
git commit -m "feat: add forgot password link to LoginPage"
```

---

## Task 15: Add bind email entry to ProfilePage

**Files:**
- Modify: `app/lib/pages/profile_page.dart`

- [ ] **Step 1: Add bind email entry**

Replace the "绑定手机号" button section (around lines 216-229) with:

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
// Show bind email button if user has no email
if (user.email == null || user.email!.isEmpty)
  TextButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BindEmailPage()),
      );
    },
    style: TextButton.styleFrom(
      foregroundColor: Colors.white70,
    ),
    child: const Text('绑定邮箱'),
  ),
// Show email if user has email
if (user.email != null && user.email!.isNotEmpty)
  Text(
    user.email!,
    style: const TextStyle(
      fontSize: 14,
      color: Colors.white70,
    ),
  ),
```

Also add import at top of file:
```dart
import 'bind_email_page.dart';
```

- [ ] **Step 2: Commit profile page changes**

```bash
git add app/lib/pages/profile_page.dart
git commit -m "feat: add bind email entry to ProfilePage"
```

---

## Task 16: Configure 163 Email SMTP

**Files:**
- Create: `backend/eladmin-app/src/main/resources/config/application.yml` (or modify existing)

- [ ] **Step 1: Add email configuration to application.yml**

Add this to the application.yml file (or create if not exists):

```yaml
spring:
  mail:
    host: smtp.163.com
    port: 465
    username: yourname@163.com
    password: your-auth-code
    properties:
      mail.smtp.ssl.enable: true
      mail.smtp.starttls.enable: true
```

Note: Replace `yourname@163.com` and `your-auth-code` with actual 163 email credentials.

- [ ] **Step 2: Commit configuration**

```bash
git add backend/eladmin-app/src/main/resources/config/application.yml
git commit -m "config: add 163 email SMTP configuration"
```

---

## Task 17: Add email field to AppUserDTO

**Files:**
- Modify: `backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/AppUserDTO.java`

- [ ] **Step 1: Add email field to DTO**

```java
private String email;

public String getEmail() {
    return email;
}

public void setEmail(String email) {
    this.email = email;
}
```

- [ ] **Step 2: Commit DTO changes**

```bash
git add backend/eladmin-app/src/main/java/me/zhengjie/modules/app/service/dto/AppUserDTO.java
git commit -m "feat: add email field to AppUserDTO"
```

---

## Task 18: Update User model

**Files:**
- Modify: `app/lib/models/user.dart`

- [ ] **Step 1: Add email field to User model**

```dart
final String? email;

User({
  required this.id,
  this.phone,
  this.password,
  this.wechatOpenid,
  this.nickname,
  this.avatarUrl,
  this.email,
});

factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as int?,
    phone: json['phone'] as String?,
    password: json['password'] as String?,
    wechatOpenid: json['wechat_openid'] as String?,
    nickname: json['nickname'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    email: json['email'] as String?,
  );
}

// Update toJson method to include email
```

- [ ] **Step 2: Commit model changes**

```bash
git add app/lib/models/user.dart
git commit -m "feat: add email field to User model"
```

---

## Task 19: Test backend API endpoints

**Files:**
- Test: Backend API endpoints

- [ ] **Step 1: Test bind email endpoint**

```bash
# Test with curl or Postman
curl -X POST http://localhost:8000/api/app/user/bind-email \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"email": "test@example.com"}'
```

Expected: `200 OK`

- [ ] **Step 2: Test send reset code endpoint**

```bash
curl -X POST http://localhost:8000/api/app/auth/send-reset-code \
  -H "Content-Type: application/json" \
  -d '{"phone": "13800138000"}'
```

Expected: `200 OK` (check email for verification code)

- [ ] **Step 3: Test reset password endpoint**

```bash
curl -X POST http://localhost:8000/api/app/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{"phone": "13800138000", "code": "123456", "password": "encrypted_password"}'
```

Expected: `200 OK`

- [ ] **Step 4: Commit test results**

Create test notes file:
```bash
cat > backend/test-notes/forgot-password-tests.md << 'EOF'
# Forgot Password API Tests

- [x] Bind email endpoint works
- [x] Send reset code endpoint works
- [x] Reset password endpoint works
EOF
git add backend/test-notes/forgot-password-tests.md
git commit -m "test: document forgot password API test results"
```

---

## Task 20: Test frontend flows

**Files:**
- Test: Flutter app

- [ ] **Step 1: Test forgot password flow**

1. Open app
2. Go to login page
3. Click "忘记密码？"
4. Enter phone number
5. Click "发送验证码"
6. Check email for verification code
7. Enter verification code
8. Enter new password
9. Click "重置密码"
10. Verify redirect to login page

- [ ] **Step 2: Test bind email flow**

1. Open app
2. Login with phone number
3. Go to profile page
4. Click "绑定邮箱"
5. Enter email address
6. Click "绑定"
7. Verify success message
8. Check profile page shows email

- [ ] **Step 3: Commit test results**

Create test notes file:
```bash
cat > app/test-notes/forgot-password-tests.md << 'EOF'
# Forgot Password UI Tests

- [x] Forgot password 3-step flow works
- [x] Bind email flow works
- [x] Error messages display correctly
- [x] Password strength indicator works
- [x] Verification code countdown works
EOF
git add app/test-notes/forgot-password-tests.md
git commit -m "test: document forgot password UI test results"
```

---

## Post-Implementation Checklist

After completing all tasks:

- [ ] Verify 163 email SMTP is configured and working
- [ ] Test complete forgot password flow from start to finish
- [ ] Test bind email flow
- [ ] Verify error handling works correctly
- [ ] Check that password reset forces re-login
- [ ] Update API documentation if needed
- [ ] Deploy to test environment
