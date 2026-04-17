import 'package:flutter/material.dart';
import '../core/models/card_background.dart';
import '../core/constants/card_theme_constants.dart';

class CardBackgroundContainer extends StatelessWidget {
  final Widget child;
  final CardBackground background;
  final BorderRadius? borderRadius;
  final bool useLightText; // 强制使用浅色文字

  const CardBackgroundContainer({
    super.key,
    required this.child,
    required this.background,
    this.borderRadius,
    this.useLightText = true,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = _buildDecoration();
    final needsDarkText = _needsDarkText();

    return Container(
      decoration: decoration,
      child: DefaultTextStyle(
        style: TextStyle(
          color: needsDarkText ? const Color(0xFF333333) : Colors.white,
        ),
        child: IconTheme(
          data: IconThemeData(
            color: needsDarkText ? const Color(0xFF333333) : Colors.white,
          ),
          child: child,
        ),
      ),
    );
  }

  bool _needsDarkText() {
    if (!useLightText) return false;
    if (background.type == CardBackgroundType.image) return false;
    if (background.type == CardBackgroundType.gradient) return false;
    if (background.colorKey != null) {
      return CardThemeConstants.isLightBackground(background.colorKey!);
    }
    return false;
  }

  Decoration _buildDecoration() {
    switch (background.type) {
      case CardBackgroundType.solidColor:
      case CardBackgroundType.gradient:
        final colors = CardThemeConstants.getColors(background);
        return BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.first.withAlpha((0.3 * 255).round()),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        );
      case CardBackgroundType.image:
        return BoxDecoration(
          image: DecorationImage(
            image: AssetImage(background.assetPath!),
            fit: BoxFit.cover,
          ),
          borderRadius: borderRadius ?? BorderRadius.circular(16),
        );
    }
  }
}
