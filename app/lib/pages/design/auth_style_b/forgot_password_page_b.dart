import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../auth_common_widgets.dart';

class ForgotPasswordPageB extends StatefulWidget {
  const ForgotPasswordPageB({super.key});

  @override
  State<ForgotPasswordPageB> createState() => _ForgotPasswordPageBState();
}

class _ForgotPasswordPageBState extends State<ForgotPasswordPageB> {
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
      DesignPreviewButton(
        text: '发送验证码',
        onPressed: () => setState(() => _currentStep = 2),
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
      const SizedBox(height: 16),
      DesignPreviewButton(
        text: '下一步',
        onPressed: () => setState(() => _currentStep = 3),
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
        onChanged: (_) => setState(() {}),
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
