import 'package:flutter/material.dart';
import '../../../core/ui/app_colors.dart';
import '../auth_common_widgets.dart';

class ForgotPasswordPageNew extends StatefulWidget {
  const ForgotPasswordPageNew({super.key});

  @override
  State<ForgotPasswordPageNew> createState() => _ForgotPasswordPageNewState();
}

class _ForgotPasswordPageNewState extends State<ForgotPasswordPageNew> {
  final _phoneController = TextEditingController();
  int _currentStep = 1;

  @override
  void dispose() {
    _phoneController.dispose();
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
                _buildTitle('忘记密码'),
                const SizedBox(height: 8),
                const Text(
                  '输入您的注册手机号',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                _buildInput(
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  label: '手机号',
                  hint: '请输入手机号',
                ),
                const SizedBox(height: 32),
                _buildButton(context, '发送验证码'),
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
}) {
  return Container(
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    ),
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
