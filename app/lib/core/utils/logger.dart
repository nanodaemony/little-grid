import 'package:logger/logger.dart';
import '../services/debug_log_service.dart';
import '../services/log_storage_service.dart';
import '../services/trace_service.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 2,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

/// 统一日志 API
/// 同时输出到控制台、实时日志服务、持久化存储
class AppLogger {
  static final LogStorageService _storage = LogStorageService();

  /// Debug 级别日志
  static void d(String message, {String? module, String? traceId}) {
    final tid = traceId ?? TraceService().currentTraceId;
    logger.d('[${module ?? 'App'}] [$tid] $message');
    DebugLogService().addLog('DEBUG', '[${module ?? 'App'}] $message');
    _storage.save(level: 'DEBUG', message: message, module: module, traceId: tid);
  }

  /// Info 级别日志
  static void i(String message, {String? module, String? traceId}) {
    final tid = traceId ?? TraceService().currentTraceId;
    logger.i('[${module ?? 'App'}] [$tid] $message');
    DebugLogService().addLog('INFO', '[${module ?? 'App'}] $message');
    _storage.save(level: 'INFO', message: message, module: module, traceId: tid);
  }

  /// Warning 级别日志
  static void w(String message, {String? module, String? traceId}) {
    final tid = traceId ?? TraceService().currentTraceId;
    logger.w('[${module ?? 'App'}] [$tid] $message');
    DebugLogService().addLog('WARNING', '[${module ?? 'App'}] $message');
    _storage.save(level: 'WARNING', message: message, module: module, traceId: tid);
  }

  /// Error 级别日志
  static void e(String message, {dynamic error, StackTrace? stackTrace, String? module, String? traceId}) {
    final tid = traceId ?? TraceService().currentTraceId;
    final errorStr = error != null ? error.toString() : null;
    logger.e('[${module ?? 'App'}] [$tid] $message', error: error, stackTrace: stackTrace);
    DebugLogService().addLog('ERROR', '[${module ?? 'App'}] $message');
    _storage.save(level: 'ERROR', message: message, module: module, traceId: tid, error: errorStr);
  }

  // ============ 便捷方法 ============

  /// Debug（自动获取 TraceId）
  static void logDebug(String module, String message) {
    d(message, module: module);
  }

  /// Info（自动获取 TraceId）
  static void logInfo(String module, String message) {
    i(message, module: module);
  }

  /// Warning（自动获取 TraceId）
  static void logWarn(String module, String message) {
    w(message, module: module);
  }

  /// Error（自动获取 TraceId）
  static void logError(String module, String message, {dynamic error, StackTrace? stackTrace}) {
    e(message, error: error, stackTrace: stackTrace, module: module);
  }
}