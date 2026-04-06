import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/debug_log_service.dart';
import '../core/services/log_storage_service.dart';
import '../core/utils/logger.dart';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LogStorageService _logStorage = LogStorageService();
  List<Map<String, dynamic>> _historyLogs = [];
  String _searchQuery = '';
  String? _selectedTraceId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistoryLogs();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistoryLogs() async {
    final logs = await _logStorage.getLogs(limit: 200);
    setState(() {
      _historyLogs = logs;
    });
  }

  Future<void> _searchLogs(String query) async {
    setState(() {
      _searchQuery = query;
    });
    final logs = await _logStorage.getLogs(limit: 200, search: query);
    setState(() {
      _historyLogs = logs;
    });
  }

  Future<void> _filterByTraceId(String traceId) async {
    setState(() {
      _selectedTraceId = traceId;
    });
    final logs = await _logStorage.getLogsByTraceId(traceId);
    setState(() {
      _historyLogs = logs;
    });
  }

  Future<void> _clearAllLogs() async {
    await _logStorage.clearAll();
    context.read<DebugLogService>().clearLogs();
    await _loadHistoryLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '实时日志'),
            Tab(text: '历史日志'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRealTimeLogs(),
          _buildHistoryLogs(),
        ],
      ),
    );
  }

  Widget _buildRealTimeLogs() {
    return Column(
      children: [
        Expanded(
          child: Consumer<DebugLogService>(
            builder: (context, logService, child) {
              final logs = logService.logs;

              if (logs.isEmpty) {
                return const Center(
                  child: Text('暂无日志', style: TextStyle(color: Colors.grey)),
                );
              }

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16.0),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[logs.length - 1 - index];
                  return _buildRealTimeLogItem(log);
                },
              );
            },
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _clearAllLogs,
              icon: const Icon(Icons.clear_all),
              label: const Text('清空所有日志'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade100,
                foregroundColor: Colors.red.shade900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryLogs() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索 TraceId 或关键词',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: _searchLogs,
          ),
        ),
        if (_selectedTraceId != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              label: Text('TraceId: $_selectedTraceId'),
              onDeleted: () {
                setState(() {
                  _selectedTraceId = null;
                });
                _loadHistoryLogs();
              },
            ),
          ),
        Expanded(
          child: _historyLogs.isEmpty
              ? const Center(child: Text('暂无历史日志', style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _loadHistoryLogs,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _historyLogs.length,
                    itemBuilder: (context, index) {
                      final log = _historyLogs[index];
                      return _buildHistoryLogItem(log);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildRealTimeLogItem(LogEntry log) {
    Color levelColor;
    switch (log.level) {
      case 'DEBUG': levelColor = Colors.grey; break;
      case 'INFO': levelColor = Colors.blue; break;
      case 'WARNING': levelColor = Colors.orange; break;
      case 'ERROR': levelColor = Colors.red; break;
      default: levelColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}]',
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'monospace'),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(color: levelColor.withOpacity(0.2), borderRadius: BorderRadius.circular(3)),
            child: Text(log.level, style: TextStyle(fontSize: 10, color: levelColor, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(log.message, style: const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
        ],
      ),
    );
  }

  Widget _buildHistoryLogItem(Map<String, dynamic> log) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(log['timestamp'] as int);
    final level = log['level'] as String;
    final module = log['module'] as String?;
    final traceId = log['trace_id'] as String?;
    final message = log['message'] as String;

    Color levelColor;
    switch (level) {
      case 'DEBUG': levelColor = Colors.grey; break;
      case 'INFO': levelColor = Colors.blue; break;
      case 'WARNING': levelColor = Colors.orange; break;
      case 'ERROR': levelColor = Colors.red; break;
      default: levelColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 11, color: Colors.grey, fontFamily: 'monospace'),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(color: levelColor.withOpacity(0.2), borderRadius: BorderRadius.circular(3)),
            child: Text(level, style: TextStyle(fontSize: 10, color: levelColor, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
          ),
          const SizedBox(width: 4),
          if (traceId != null)
            GestureDetector(
              onTap: () => _filterByTraceId(traceId),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.2), borderRadius: BorderRadius.circular(3)),
                child: Text(traceId, style: const TextStyle(fontSize: 10, color: Colors.purple, fontFamily: 'monospace')),
              ),
            ),
          const SizedBox(width: 4),
          if (module != null)
            Text('[${module}] ', style: const TextStyle(fontSize: 11, color: Colors.teal, fontFamily: 'monospace')),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
        ],
      ),
    );
  }
}