import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../auth_common_widgets.dart';

class ForgotPasswordPageC extends StatefulWidget {
  const ForgotPasswordPageC({super.key});

  @override
  State<ForgotPasswordPageC> createState() => _ForgotPasswordPageCState();
}

class _ForgotPasswordPageCState extends State<ForgotPasswordPageC> {
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

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
      child: Column(children: children),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 32),
          const AuthLogoHeader(),
          const SizedBox(height: 32),
          // Card 1: Step indicator
          _buildCard(
            children: [
              StepIndicator(currentStep: _currentStep),
            ],
          ),
          const SizedBox(height: 8),
          // Card 2: Content area
          _buildCard(
            children: [
              if (_currentStep == 1) ..._buildStep1(),
              if (_currentStep == 2) ..._buildStep2(),
              if (_currentStep == 3) ..._buildStep3(),
            ],
          ),
          const SizedBox(height: 8),
          // Card 3: Action area
          _buildCard(
            children: [
              if (_currentStep == 1)
                DesignPreviewButton(
                  text: '下一步',
                  onPressed: () => setState(() => _currentStep = 2),
                ),
              if (_currentStep == 2)
                DesignPreviewButton(
                  text: '下一步',
                  onPressed: () => setState(() => _currentStep = 3),
                ),
              if (_currentStep == 3)
                DesignPreviewButton(
                  text: '完成',
                  onPressed: () {
                    setState(() => _currentStep = 1);
                    showDesignSnackBar(context);
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => showDesignSnackBar(context),
            child: const Text(
              '返回登录',
              style: TextStyle(color: AppColors.primary, fontSize: 14),
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
    ];
  }
}
