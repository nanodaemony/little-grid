import 'package:flutter/material.dart';
import 'banner_queue.dart';

/// In-app banner service for global banner management
class InAppBannerService {
  static final InAppBannerService _instance = InAppBannerService._internal();
  factory InAppBannerService() => _instance;
  InAppBannerService._internal();

  BannerQueue? _queue;
  bool _initialized = false;

  /// Initialize the service
  void initialize(BannerQueue queue) {
    if (_initialized) return;
    _queue = queue;
    _initialized = true;
  }

  /// Show a banner
  void show({
    required String title,
    required String body,
    required IconData icon,
    Color? iconBackgroundColor,
    VoidCallback? onTap,
    String? toolId,
  }) {
    if (_queue == null || !_initialized) {
      throw StateError('InAppBannerService not initialized. Call initialize() first.');
    }

    final data = BannerData(
      title: title,
      body: body,
      icon: icon,
      iconBackgroundColor: iconBackgroundColor ?? const Color(0xFF22C55E),
      onTap: onTap,
      toolId: toolId,
    );

    _queue!.enqueue(data);
  }

  /// Dismiss current banner
  void dismiss() {
    if (_queue == null || !_initialized) return;
    _queue!.dismissCurrent();
  }

  /// Clear all banners
  void clearAll() {
    if (_queue == null || !_initialized) return;
    _queue!.clearAll();
  }
}
