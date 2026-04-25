import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../auth_common_widgets.dart';

class ForgotPasswordPageA extends StatefulWidget {
  const ForgotPasswordPageA({super.key});

  @override
  State<ForgotPasswordPageA> createState() => _ForgotPasswordPageAState();
}

class _ForgotPasswordPageAState extends State<ForgotPasswordPageA> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 1;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),
          const AuthLogoHeader(),
          const SizedBox(height: 32),
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
    );
  }

  List<Widget> _buildStep1() {
    return [
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: lightBlueInputDecoration(
                prefixIcon: Icons.phone,
                hintText: '请输入手机号',
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () => setState(() => _currentStep = 2),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('发送验证码'),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildStep2() {
    return [
      TextField(
        controller: _codeController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, letterSpacing: 8),
        decoration: lightBlueInputDecoration(
          prefixIcon: Icons.verified_user,
          hintText: '6位验证码',
        ),
      ),
      const SizedBox(height: 16),
      DesignPreviewButton(
        text: '下一步',
        onPressed: () => setState(() => _currentStep = 3),
      ),
    ];
  }

  List<Widget> _buildStep3() {
    return [
      TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        onChanged: (_) => setState(() {}),
        decoration: lightBlueInputDecoration(
          prefixIcon: Icons.lock,
          hintText: '至少8位，包含字母和数字',
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textTertiary,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
      const SizedBox(height: 6),
      PasswordStrengthBar(password: _passwordController.text),
      const SizedBox(height: 12),
      TextField(
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        decoration: lightBlueInputDecoration(
          prefixIcon: Icons.lock_outline,
          hintText: '再次输入密码',
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textTertiary,
            ),
            onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
        ),
      ),
      const SizedBox(height: 20),
      DesignPreviewButton(
        text: '完成',
        onPressed: () {
          setState(() => _currentStep = 1);
          showDesignSnackBar(context);
        },
      ),
    ];
  }
}