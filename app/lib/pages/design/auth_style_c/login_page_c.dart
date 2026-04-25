import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../auth_common_widgets.dart';

class LoginPageC extends StatefulWidget {
  const LoginPageC({super.key});

  @override
  State<LoginPageC> createState() => _LoginPageCState();
}

class _LoginPageCState extends State<LoginPageC> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
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
                decoration: lightBlueInputDecoration(
                  prefixIcon: Icons.lock,
                  hintText: '请输入密码',
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
            ],
          ),
          const SizedBox(height: 8),
          // Card 2: Action area
          _buildCard(
            children: const [
              DesignPreviewButton(text: '登 录'),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => showDesignSnackBar(context),
            child: const Text(
              '忘记密码？',
              style: TextStyle(color: AppColors.primary, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: () => showDesignSnackBar(context),
            child: const Text(
              '还没有账号？去注册',
              style: TextStyle(color: AppColors.primary, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
