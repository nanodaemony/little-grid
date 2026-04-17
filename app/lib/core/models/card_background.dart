import 'package:flutter/material.dart';

enum CardBackgroundType {
  solidColor,
  gradient,
  image,
}

class CardBackground {
  final CardBackgroundType type;
  final String? colorKey;
  final String? assetPath;
  final List<Color>? colors;

  const CardBackground({
    required this.type,
    this.colorKey,
    this.assetPath,
    this.colors,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'colorKey': colorKey,
      'assetPath': assetPath,
    };
  }

  factory CardBackground.fromMap(Map<String, dynamic> map) {
    return CardBackground(
      type: CardBackgroundType.values[map['type'] as int],
      colorKey: map['colorKey'] as String?,
      assetPath: map['assetPath'] as String?,
    );
  }

  CardBackground copyWith({
    CardBackgroundType? type,
    String? colorKey,
    String? assetPath,
    List<Color>? colors,
  }) {
    return CardBackground(
      type: type ?? this.type,
      colorKey: colorKey ?? this.colorKey,
      assetPath: assetPath ?? this.assetPath,
      colors: colors ?? this.colors,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardBackground &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          colorKey == other.colorKey &&
          assetPath == other.assetPath;

  @override
  int get hashCode => type.hashCode ^ colorKey.hashCode ^ assetPath.hashCode;
}
