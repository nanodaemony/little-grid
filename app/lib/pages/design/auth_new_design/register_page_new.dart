import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../auth_common_widgets.dart';

class RegisterPageNew extends StatefulWidget {
  const RegisterPageNew({super.key});

  @override
  State<RegisterPageNew> createState() => _RegisterPageNewState();
}

class _RegisterPageNewState extends State<RegisterPageNew> {
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            const SizedBox(height: 40),
            _buildCard(
              context,
              children: [
                _buildTitle('注册'),
                const SizedBox(height: 24),
                _buildInput(
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  label: '手机号 *',
                  hint: '请输入手机号',
                ),
                const SizedBox(height: 16),
                _buildInput(
                  controller: _passwordController,
                  icon: Icons.lock_outline,
                  label: '密码 *',
                  hint: '至少8位，包含字母和数字',
                  isPassword: true,
                  obscurePassword: _obscurePassword,
                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                  showStrength: true,
                ),
                const SizedBox(height: 16),
                _buildInput(
                  controller: _confirmPasswordController,
                  icon: Icons.lock_outline,
                  label: '确认密码 *',
                  hint: '再次输入密码',
                  isPassword: true,
                  obscurePassword: _obscureConfirmPassword,
                  onToggleVisibility: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                const SizedBox(height: 16),
                _buildInput(
                  controller: _nicknameController,
                  icon: Icons.person_outline,
                  label: '昵称（选填）',
                  hint: '请输入昵称',
                ),
                const SizedBox(height: 32),
                _buildButton(context, '注册'),
                const SizedBox(height: 16),
                _buildLinkButton(context, '已有账号？去登录'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildLogo() {
  return Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(24),
    ),
    child: const Icon(
      Icons.grid_view,
      size: 48,
      color: Colors.white,
    ),
  );
}

Widget _buildTitle(String title) {
  return Text(
    title,
    style: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
  );
}

Widget _buildCard(BuildContext context, {required List<Widget> children}) {
  return Container(
    width: double.infinity,
    constraints: const BoxConstraints(maxWidth: 400),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: children,
    ),
  );
}

Widget _buildInput({
  required TextEditingController controller,
  required IconData icon,
  required String label,
  required String hint,
  bool isPassword = false,
  bool obscurePassword = false,
  VoidCallback? onToggleVisibility,
  bool showStrength = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword ? obscurePassword : false,
          keyboardType: label.contains('手机号') ? TextInputType.phone : null,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ),
      if (showStrength) ...[
        const SizedBox(height: 4),
        const Text(
          '密码强度：中',
          style: TextStyle(color: Colors.orange, fontSize: 12),
        ),
      ],
    ],
  );
}

Widget _buildButton(BuildContext context, String text) {
  return SizedBox(
    width: double.infinity,
    height: 48,
    child: ElevatedButton(
      onPressed: () => showDesignSnackBar(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
  );
}

Widget _buildLinkButton(BuildContext context, String text) {
  return TextButton(
    onPressed: () => showDesignSnackBar(context),
    child: Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
    ),
  );
}
