import 'dart:async';
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
            color: _countdown > 0 ? Colors.grey : const Color(0xFF5B9BD5),
          ),
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, letterSpacing: 8),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 48,
        child: ElevatedButton(
          onPressed: () => setState(() => _currentStep = 3),
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
          onPressed: () => _resetPassword(),
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
