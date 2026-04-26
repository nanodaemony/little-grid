import 'package:flutter/material.dart';
import '../../core/ui/app_colors.dart';

/// Logo + app name header used by all auth design pages
class AuthLogoHeader extends StatelessWidget {
  const AuthLogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.grid_view,
            size: 36,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '小方格',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Password strength indicator bar (red/orange/green 3-segment)
class PasswordStrengthBar extends StatelessWidget {
  final String password;

  const PasswordStrengthBar({super.key, required this.password});

  int get _strength {
    if (password.isEmpty) return 0;
    if (password.length < 8) return 1;
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password)) return 1;
    if (password.length >= 12) return 3;
    return 2;
  }

  Color get _color {
    switch (_strength) {
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.success;
      default:
        return AppColors.divider;
    }
  }

  String get _label {
    switch (_strength) {
      case 1:
        return '弱';
      case 2:
        return '中';
      case 3:
        return '强';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(3, (index) {
            return Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                decoration: BoxDecoration(
                  color: index < _strength ? _color : AppColors.divider,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            );
          }),
        ),
        if (_strength > 0) ...[
          const SizedBox(height: 4),
          Text(
            '密码强度：$_label',
            style: TextStyle(color: _color, fontSize: 12),
          ),
        ],
      ],
    );
  }
}

/// Step indicator for forgot-password flow (①→②→③)
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final step = index + 1;
        final isCompleted = step < currentStep;
        final isCurrent = step == currentStep;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? AppColors.primary
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
              if (index < totalSteps - 1)
                Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? AppColors.primary
                        : AppColors.divider,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : Text(
                            '$step',
                            style: TextStyle(
                              fontSize: 12,
                              color: isCurrent ? Colors.white : AppColors.textTertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

/// Primary action button for design preview pages
class DesignPreviewButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const DesignPreviewButton({
    super.key,
    required this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed ?? () => showDesignSnackBar(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

/// Show design preview SnackBar
void showDesignSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('此为设计预览，请选择您喜欢的风格'),
      duration: Duration(seconds: 2),
    ),
  );
}

/// Light-blue filled input decoration (Style A & C)
InputDecoration lightBlueInputDecoration({
  required IconData prefixIcon,
  String? hintText,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.primaryLight.withOpacity(0.3),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
  );
}

/// Label + divider input decoration (Style B)
class LabelDividerField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  const LabelDividerField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14),
          ),
        ),
        Container(height: 1, color: AppColors.divider),
      ],
    );
  }
}
