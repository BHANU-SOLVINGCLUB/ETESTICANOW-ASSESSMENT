import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConstants.enableLogging) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConstants.enableLogging) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConstants.enableLogging) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConstants.enableLogging) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    if (AppConstants.enableLogging) {
      _logger.f(message, error: error, stackTrace: stackTrace);
    }
  }

  // Specific logging methods for different components
  static void logTaskOperation(String operation, String taskId, {String? details}) {
    info('Task $operation: $taskId${details != null ? ' - $details' : ''}');
  }

  static void logUserAction(String action, {Map<String, dynamic>? parameters}) {
    info('User Action: $action${parameters != null ? ' - $parameters' : ''}');
  }

  static void logApiCall(String endpoint, {String? method, int? statusCode, String? error}) {
    if (error != null) {
      warning('API Call Failed: $method $endpoint - Status: $statusCode - Error: $error');
    } else {
      info('API Call: $method $endpoint - Status: $statusCode');
    }
  }

  static void logPerformance(String operation, Duration duration) {
    if (duration.inMilliseconds > 1000) {
      warning('Slow Operation: $operation took ${duration.inMilliseconds}ms');
    } else {
      debug('Performance: $operation took ${duration.inMilliseconds}ms');
    }
  }

  static void logSecurityEvent(String event, {Map<String, dynamic>? details}) {
    warning('Security Event: $event${details != null ? ' - $details' : ''}');
  }
}
