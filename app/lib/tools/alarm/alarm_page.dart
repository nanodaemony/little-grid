import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/alarm_item.dart';
import 'services/alarm_service.dart';
import 'services/timer_service.dart';
import 'services/stopwatch_service.dart';
import 'pages/alarm_list_page.dart';
import 'pages/timer_page.dart';
import 'pages/stopwatch_page.dart';
import 'widgets/page_indicator.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<AlarmItem> _alarms = [];
  final AlarmService _alarmService = AlarmService();

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadAlarms();
  }

  Future<void> _initializeServices() async {
    await _alarmService.initialize();
    await _alarmService.requestPermissions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAlarms() async {
    // TODO: 从数据库加载闹钟
    setState(() {});
  }

  Future<void> _addAlarm(AlarmItem alarm) async {
    // TODO: 保存到数据库
    setState(() {
      _alarms.add(alarm);
    });
    await _alarmService.scheduleAlarm(alarm);
  }

  Future<void> _updateAlarm(AlarmItem alarm) async {
    // TODO: 更新数据库
    setState(() {
      final index = _alarms.indexWhere((a) => a.id == alarm.id);
      if (index != -1) {
        _alarms[index] = alarm;
      }
    });
    await _alarmService.cancelAlarm(alarm.id);
    if (alarm.isEnabled) {
      await _alarmService.scheduleAlarm(alarm);
    }
  }

  Future<void> _deleteAlarm(String id) async {
    // TODO: 从数据库删除
    setState(() {
      _alarms.removeWhere((a) => a.id == id);
    });
    await _alarmService.cancelAlarm(id);
  }

  Future<void> _toggleAlarm(AlarmItem alarm) async {
    final updated = alarm.copyWith(
      isEnabled: !alarm.isEnabled,
      updatedAt: DateTime.now(),
    );
    await _updateAlarm(updated);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerService()),
        ChangeNotifierProvider(create: (_) => StopwatchService()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('时钟'),
        ),
        body: Column(
          children: [
            PageIndicator(
              currentPage: _currentPage,
              onTabSelected: (index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  AlarmListPage(
                    alarms: _alarms,
                    onAddAlarm: _addAlarm,
                    onUpdateAlarm: _updateAlarm,
                    onDeleteAlarm: _deleteAlarm,
                    onToggleAlarm: _toggleAlarm,
                  ),
                  const TimerPage(),
                  const StopwatchPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}