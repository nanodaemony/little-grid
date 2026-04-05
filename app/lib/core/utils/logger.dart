import 'package:logger/logger.dart';
import '../services/debug_log_service.dart';

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

class AppLogger {
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.d(message, error: error, stackTrace: stackTrace);
    DebugLogService().addLog('DEBUG', message);
  }

  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.i(message, error: error, stackTrace: stackTrace);
    DebugLogService().addLog('INFO', message);
  }

  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.w(message, error: error, stackTrace: stackTrace);
    DebugLogService().addLog('WARNING', message);
  }

  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
    DebugLogService().addLog('ERROR', message);
  }
}
