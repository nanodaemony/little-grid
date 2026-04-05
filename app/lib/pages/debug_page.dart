import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/services/debug_log_service.dart';
import '../core/utils/logger.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
      ),
      body: Column(
        children: [
          // Button area
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.center,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to page ${index + 1}
                      AppLogger.i('Button 页面${index + 1} clicked');
                    },
                    child: Text('页面${index + 1}'),
                  ),
                );
              }),
            ),
          ),

          const Divider(),

          // Log display area
          Expanded(
            child: Consumer<DebugLogService>(
              builder: (context, logService, child) {
                final logs = logService.logs;

                if (logs.isEmpty) {
                  return const Center(
                    child: Text(
                      '暂无日志',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true, // Newest logs at bottom
                  padding: const EdgeInsets.all(16.0),
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[logs.length - 1 - index]; // Reverse index
                    return _buildLogItem(log);
                  },
                );
              },
            ),
          ),

          const Divider(),

          // Clear button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<DebugLogService>().clearLogs();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('清空日志'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red.shade900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(LogEntry log) {
    Color levelColor;
    switch (log.level) {
      case 'DEBUG':
        levelColor = Colors.grey;
        break;
      case 'INFO':
        levelColor = Colors.blue;
        break;
      case 'WARNING':
        levelColor = Colors.orange;
        break;
      case 'ERROR':
        levelColor = Colors.red;
        break;
      default:
        levelColor = Colors.grey;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}]',
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: levelColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              log.level,
              style: TextStyle(
                fontSize: 10,
                color: levelColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              log.message,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
