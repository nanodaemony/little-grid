import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:provider/provider.dart';
import '../../core/ui/app_colors.dart';
import '../../core/services/rsa_service.dart';
import '../../providers/auth_provider.dart';
import '../design/auth_common_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
      String encryptedPassword;
      try {
        await RsaService.initialize();
        encryptedPassword = RsaService.encryptPassword(_passwordController.text);
      } catch (e) {
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
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      _showError(e.toString().replaceAll('Exception：', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('注册')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const AuthLogoHeader(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelDividerField(
                    label: '手机号',
                    hintText: '请输入手机号',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  LabelDividerField(
                    label: '密码',
                    hintText: '至少8位，包含字母和数字',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    onChanged: _checkPasswordStrength,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 6),
                  PasswordStrengthBar(password: _passwordController.text),
                  const SizedBox(height: 16),
                  LabelDividerField(
                    label: '确认密码',
                    hintText: '再次输入密码',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      onPressed: () => setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LabelDividerField(
                    label: '昵称（选填）',
                    hintText: '请输入昵称',
                    controller: _nicknameController,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('注 册', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '已有账号？去登录',
                        style: TextStyle(color: AppColors.primary, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
