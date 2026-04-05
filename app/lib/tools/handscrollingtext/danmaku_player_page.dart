import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/danmaku_models.dart';
import 'widgets/danmaku_player.dart';

class DanmakuPlayerPage extends StatefulWidget {
  final DanmakuConfig config;

  const DanmakuPlayerPage({
    super.key,
    required this.config,
  });

  @override
  State<DanmakuPlayerPage> createState() => _DanmakuPlayerPageState();
}

class _DanmakuPlayerPageState extends State<DanmakuPlayerPage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: widget.config.backgroundColor,
        body: DanmakuPlayer(
          config: widget.config,
          isPreview: false,
        ),
      ),
    );
  }
}
