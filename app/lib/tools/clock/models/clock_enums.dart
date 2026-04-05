import 'package:flutter/material.dart';

enum ClockType { digital, analog }

enum ClockThemeMode { light, dark, custom }

enum FontSize { small, medium, large }
enum BackgroundType { color, gradient, image }
enum TimeFormat { auto, format12, format24 }

enum GradientDirection {
  topToBottom,
  leftToRight,
  topLeftToBottomRight,
  topRightToBottomLeft,
}

extension FontSizeExtension on FontSize {
  double get scale {
    switch (this) {
      case FontSize.small:
        return 0.7;
      case FontSize.medium:
        return 1.0;
      case FontSize.large:
        return 1.3;
    }
  }
}


extension GradientDirectionExtension on GradientDirection {
  LinearGradient toGradient(List<Color> colors) {
    final begin = switch (this) {
      GradientDirection.topToBottom => Alignment.topCenter,
      GradientDirection.leftToRight => Alignment.centerLeft,
      GradientDirection.topLeftToBottomRight => Alignment.topLeft,
      GradientDirection.topRightToBottomLeft => Alignment.topRight,
    };
    final end = switch (this) {
      GradientDirection.topToBottom => Alignment.bottomCenter,
      GradientDirection.leftToRight => Alignment.centerRight,
      GradientDirection.topLeftToBottomRight => Alignment.bottomRight,
      GradientDirection.topRightToBottomLeft => Alignment.bottomLeft,
    };
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
    );
  }
}
