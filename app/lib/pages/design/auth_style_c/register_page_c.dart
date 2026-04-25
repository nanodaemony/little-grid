import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../auth_common_widgets.dart';

class RegisterPageC extends StatefulWidget {
  const RegisterPageC({super.key});

  @override
  State<RegisterPageC> createState() => _RegisterPageCState();
}

class _RegisterPageCState extends State<RegisterPageC> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nicknameController.dispose();
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
          // Card 1: Input area
          _buildCard(
            children: [
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: lightBlueInputDecoration(
                  prefixIcon: Icons.phone,
                  hintText: '请输入手机号',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onChanged: (_) => setState(() {}),
                decoration: lightBlueInputDecoration(
                  prefixIcon: Icons.lock,
                  hintText: '至少8位，包含字母和数字',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
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
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nicknameController,
                decoration: lightBlueInputDecoration(
                  prefixIcon: Icons.person_outline,
                  hintText: '选填',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Card 2: Action area
          _buildCard(
            children: const [
              DesignPreviewButton(text: '注 册'),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => showDesignSnackBar(context),
            child: const Text(
              '已有账号？去登录',
              style: TextStyle(color: AppColors.primary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
