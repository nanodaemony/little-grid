import 'package:flutter/material.dart';

/// Parses a hex color string to a Color.
/// Supports formats: #RGB, #RRGGBB, #AARRGGBB, RGB, RRGGBB, AARRGGBB
Color parseColor(String? colorStr, {Color defaultColor = Colors.blue}) {
  if (colorStr == null || colorStr.isEmpty) {
    return defaultColor;
  }

  try {
    String hex = colorStr.replaceFirst('#', '');

    // Handle different lengths
    if (hex.length == 3) {
      // RGB -> RRGGBB
      hex = hex.split('').map((c) => '$c$c').join();
      hex = 'FF$hex'; // Add alpha
    } else if (hex.length == 6) {
      hex = 'FF$hex'; // Add alpha
    } else if (hex.length == 8) {
      // Already has alpha
    } else {
      return defaultColor;
    }

    return Color(int.parse(hex, radix: 16));
  } catch (e) {
    return defaultColor;
  }
}
