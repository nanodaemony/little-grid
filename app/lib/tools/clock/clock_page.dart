import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:provider/provider.dart';
import 'models/clock_config.dart';
import 'models/clock_enums.dart';
import 'services/clock_service.dart';
import 'widgets/digital_clock.dart';
import 'widgets/analog_clock.dart';
import 'widgets/settings_panel.dart';

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  bool _showSettingsIcon = true;
  bool _showSettingsPanel = false;
  Timer? _hideTimer;
  late final ClockService _clockService;

  @override
  void initState() {
    super.initState();
    _clockService = ClockService();
    _enterFullScreen();
    WakelockPlus.enable();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _clockService.dispose();
    WakelockPlus.disable();
    _exitFullScreen();
    super.dispose();
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && !_showSettingsPanel) {
        setState(() => _showSettingsIcon = false);
      }
    });
  }

  void _onScreenTap() {
    if (_showSettingsPanel) return;
    setState(() => _showSettingsIcon = true);
    _startHideTimer();
  }

  void _openSettings() {
    setState(() {
      _showSettingsPanel = true;
      _showSettingsIcon = false;
    });
    _hideTimer?.cancel();
  }

  void _closeSettings() {
    setState(() => _showSettingsPanel = false);
    _startHideTimer();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClockService>.value(
      value: _clockService,
      child: Consumer<ClockService>(
        builder: (context, service, child) {
          return GestureDetector(
            onTap: _onScreenTap,
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  // Background
                  _buildBackground(service.config),
                  // Clock display
                  Center(
                    child: _buildClock(service),
                  ),
                  // Settings icon
                  AnimatedOpacity(
                    opacity: _showSettingsIcon ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: _buildSettingsIcon(),
                  ),
                  // Tap hint (shown when settings icon is hidden)
                  AnimatedOpacity(
                    opacity: !_showSettingsIcon && !_showSettingsPanel ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Positioned(
                      top: 40,
                      right: 24,
                      child: SafeArea(
                        child: Text(
                          '点击屏幕显示设置',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Settings panel
                  if (_showSettingsPanel)
                    _buildSettingsOverlay(service),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackground(ClockConfig config) {
    switch (config.backgroundType) {
      case BackgroundType.color:
        return Container(color: config.backgroundColor);
      case BackgroundType.gradient:
        final gradient = config.gradientDirection?.toGradient(
              config.gradientColors ?? [Colors.blue, Colors.purple],
            ) ??
            const LinearGradient(
              colors: [Colors.blue, Colors.purple],
            );
        return Container(
          decoration: BoxDecoration(gradient: gradient),
        );
      case BackgroundType.image:
        if (config.backgroundImagePath != null) {
          return Image.file(
            File(config.backgroundImagePath!),
            fit: BoxFit.cover,
          );
        }
        return Container(color: config.backgroundColor);
    }
  }

  Widget _buildClock(ClockService service) {
    final config = service.config;
    final time = service.currentTime;

    switch (config.type) {
      case ClockType.digital:
        return DigitalClock(time: time, config: config);
      case ClockType.analog:
        return AnalogClock(time: time, config: config);
    }
  }

  Widget _buildSettingsIcon() {
    return Positioned(
      top: 24,
      right: 24,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: IconButton(
              onPressed: _openSettings,
              icon: const Icon(Icons.settings, color: Colors.white, size: 28),
              padding: const EdgeInsets.all(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOverlay(ClockService service) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SettingsPanel(
              config: service.config,
              onConfigChanged: (newConfig) {
                service.saveConfig(newConfig);
              },
              previewTime: service.currentTime,
              onClose: _closeSettings,
            ),
          ],
        ),
      ),
    );
  }
}
