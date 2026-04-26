import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/ui/app_colors.dart';
import '../../core/services/rsa_service.dart';
import '../../providers/auth_provider.dart';
import '../design/auth_common_widgets.dart';

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
  int _countdown = 0;
  Timer? _timer;

  void _checkPasswordStrength(String password) {
    setState(() {});
  }

  bool _validatePhone() {
    if (_phoneController.text.isEmpty) {
      _showError('请输入手机号');
      return false;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(_phoneController.text)) {
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
        _showError(e.toString().replaceAll('Exception：', ''));
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

  Future<void> _verifyAndNext() async {
    if (!_validateCode()) return;
    setState(() => _currentStep = 3);
  }

  Future<void> _resetPassword() async {
    if (!_validatePassword()) return;

    setState(() => _isLoading = true);

    try {
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
        _showError(e.toString().replaceAll('Exception：', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('忘记密码')),
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
                  StepIndicator(currentStep: _currentStep),
                  const SizedBox(height: 24),
                  if (_currentStep == 1) ..._buildStep1(),
                  if (_currentStep == 2) ..._buildStep2(),
                  if (_currentStep == 3) ..._buildStep3(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStep1() {
    return [
      LabelDividerField(
        label: '手机号',
        hintText: '请输入手机号',
        controller: _phoneController,
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _sendCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('发送验证码', style: TextStyle(fontSize: 16)),
        ),
      ),
    ];
  }

  List<Widget> _buildStep2() {
    return [
      LabelDividerField(
        label: '验证码',
        hintText: '请输入6位验证码',
        controller: _codeController,
        keyboardType: TextInputType.number,
      ),
      const SizedBox(height: 8),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: _countdown == 0 ? _sendCode : null,
          child: Text(
            _countdown > 0 ? '$_countdown秒后重新发送' : '重新发送',
            style: TextStyle(
              color: _countdown > 0 ? AppColors.textTertiary : AppColors.primary,
              fontSize: 14,
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _verifyAndNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('下一步', style: TextStyle(fontSize: 16)),
        ),
      ),
    ];
  }

  List<Widget> _buildStep3() {
    return [
      LabelDividerField(
        label: '新密码',
        hintText: '至少8位，包含字母和数字',
        controller: _passwordController,
        obscureText: _obscurePassword,
        onChanged: _checkPasswordStrength,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textTertiary,
            size: 20,
          ),
          onPressed: () => setState(
              () => _obscureConfirmPassword = !_obscureConfirmPassword),
        ),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _resetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('完成', style: TextStyle(fontSize: 16)),
        ),
      ),
    ];
  }
}
