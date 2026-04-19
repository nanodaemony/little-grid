import 'dart:async';
import 'package:flutter/material.dart';

/// Banner data model
class BannerData {
  final String id;
  final String title;
  final String body;
  final IconData icon;
  final Color iconBackgroundColor;
  final VoidCallback? onTap;
  final String? toolId;

  BannerData({
    required this.title,
    required this.body,
    required this.icon,
    this.iconBackgroundColor = const Color(0xFF22C55E),
    this.onTap,
    this.toolId,
  }) : id = DateTime.now().millisecondsSinceEpoch.toString();
}

/// Banner queue management service
class BannerQueue extends ChangeNotifier {
  final List<BannerData> _queue = [];
  BannerData? _currentBanner;
  bool _isShowing = false;

  /// Get current showing banner
  BannerData? get currentBanner => _currentBanner;

  /// Get queue length
  int get queueLength => _queue.length;

  /// Check if a banner is currently showing
  bool get isShowing => _isShowing;

  /// Enqueue a new banner
  void enqueue(BannerData data) {
    if (_queue.length >= 10) {
      _queue.removeAt(0);
    }
    _queue.add(data);
    _tryShowNext();
  }

  /// Dismiss current banner
  void dismissCurrent() {
    _currentBanner = null;
    _isShowing = false;
    notifyListeners();

    // Wait a bit before showing next
    Future.delayed(const Duration(milliseconds: 300), () {
      _tryShowNext();
    });
  }

  /// Clear all banners
  void clearAll() {
    _queue.clear();
    dismissCurrent();
  }

  /// Try to show next banner in queue
  void _tryShowNext() {
    if (_isShowing || _queue.isEmpty) return;

    _currentBanner = _queue.removeAt(0);
    _isShowing = true;
    notifyListeners();
  }
}
