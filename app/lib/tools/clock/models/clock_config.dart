import 'package:flutter/material.dart';
import 'clock_enums.dart';


class ClockConfig {
  final ClockType type;
  final ClockThemeMode theme;
  final TimeFormat timeFormat;
  final bool showDate;
  final bool showSeconds;
  final FontSize fontSize;
  final BackgroundType backgroundType;
  final Color backgroundColor;
  final GradientDirection? gradientDirection;
  final List<Color>? gradientColors;
  final String? backgroundImagePath;
  final Color? customTextColor;

  const ClockConfig({
    required this.type,
    required this.theme,
    required this.timeFormat,
    required this.showDate,
    required this.showSeconds,
    required this.fontSize,
    required this.backgroundType,
    required this.backgroundColor,
    this.gradientDirection,
    this.gradientColors,
    this.backgroundImagePath,
    this.customTextColor,
  });

  factory ClockConfig.defaultConfig() => const ClockConfig(
        type: ClockType.digital,
        theme: ClockThemeMode.dark,
        timeFormat: TimeFormat.auto,
        showDate: true,
        showSeconds: true,
        fontSize: FontSize.large,
        backgroundType: BackgroundType.gradient,
        backgroundColor: Colors.black,
        gradientDirection: GradientDirection.topLeftToBottomRight,
        gradientColors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
        backgroundImagePath: null,
        customTextColor: null,
      );

  ClockConfig copyWith({
    ClockType? type,
    ClockThemeMode? theme,
    TimeFormat? timeFormat,
    bool? showDate,
    bool? showSeconds,
    FontSize? fontSize,
    BackgroundType? backgroundType,
    Color? backgroundColor,
    GradientDirection? gradientDirection,
    List<Color>? gradientColors,
    String? backgroundImagePath,
    Color? customTextColor,
  }) {
    return ClockConfig(
      type: type ?? this.type,
      theme: theme ?? this.theme,
      timeFormat: timeFormat ?? this.timeFormat,
      showDate: showDate ?? this.showDate,
      showSeconds: showSeconds ?? this.showSeconds,
      fontSize: fontSize ?? this.fontSize,
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gradientDirection: gradientDirection ?? this.gradientDirection,
      gradientColors: gradientColors ?? this.gradientColors,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      customTextColor: customTextColor ?? this.customTextColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'theme': theme.name,
      'timeFormat': timeFormat.name,
      'showDate': showDate,
      'showSeconds': showSeconds,
      'fontSize': fontSize.name,
      'backgroundType': backgroundType.name,
      'backgroundColor': backgroundColor.value,
      'gradientDirection': gradientDirection?.name,
      'gradientColors': gradientColors?.map((c) => c.value).toList(),
      'backgroundImagePath': backgroundImagePath,
      'customTextColor': customTextColor?.value,
    };
  }

  factory ClockConfig.fromJson(Map<String, dynamic> json) {
    return ClockConfig(
      type: ClockType.values.byName(json['type'] as String),
      theme: ClockThemeMode.values.byName(json['theme'] as String),
      timeFormat: TimeFormat.values.byName(json['timeFormat'] as String),
      showDate: json['showDate'] as bool,
      showSeconds: json['showSeconds'] as bool,
      fontSize: FontSize.values.byName(json['fontSize'] as String),
      backgroundType: BackgroundType.values.byName(json['backgroundType'] as String),
      backgroundColor: Color(json['backgroundColor'] as int),
      gradientDirection: json['gradientDirection'] != null
          ? GradientDirection.values.byName(json['gradientDirection'] as String)
          : null,
      gradientColors: (json['gradientColors'] as List<dynamic>?)
          ?.map((v) => Color(v as int))
          .toList(),
      backgroundImagePath: json['backgroundImagePath'] as String?,
      customTextColor: json['customTextColor'] != null
          ? Color(json['customTextColor'] as int)
          : null,
    );
  }

  Color get effectiveTextColor {
    if (customTextColor != null) return customTextColor!;
    switch (theme) {
      case ClockThemeMode.light:
        return Colors.black;
      case ClockThemeMode.dark:
        return Colors.white;
      case ClockThemeMode.custom:
        return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }
  }

  bool get use24HourFormat {
    switch (timeFormat) {
      case TimeFormat.format24:
        return true;
      case TimeFormat.format12:
        return false;
      case TimeFormat.auto:
        return WidgetsBinding.instance.platformDispatcher.locale.languageCode != 'en';
    }
  }
}
