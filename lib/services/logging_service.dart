import 'dart:developer' as developer;

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical
}

class LoggingService {
  static final LoggingService _instance = LoggingService._internal();
  factory LoggingService() => _instance;
  LoggingService._internal();

  static const String _appName = 'STER_APP';
  static const bool _enableConsoleLogging = true;
  static const bool _enableFileLogging = false;
  static const LogLevel _minLogLevel = LogLevel.debug;

  void _log(LogLevel level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (level.index < _minLogLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelName = level.name.toUpperCase();
    final tagStr = tag != null ? '[$tag]' : '';

    // Console logging
    if (_enableConsoleLogging) {
      switch (level) {
        case LogLevel.debug:
          developer.log(message, name: _appName, level: 500);
          break;
        case LogLevel.info:
          developer.log(message, name: _appName, level: 800);
          break;
        case LogLevel.warning:
          developer.log(message, name: _appName, level: 900);
          break;
        case LogLevel.error:
        case LogLevel.critical:
          developer.log(message, name: _appName, level: 1000, error: error, stackTrace: stackTrace);
          break;
      }
    }

    // File logging (for production)
    if (_enableFileLogging) {
      // TODO: Implement file logging for production
    }

    // Error reporting for critical errors
    if (level == LogLevel.critical) {
      _reportCriticalError(message, error, stackTrace);
    }
  }

  void _reportCriticalError(String message, Object? error, StackTrace? stackTrace) {
    // TODO: Implement error reporting service (e.g., Sentry, Firebase Crashlytics)
    developer.log('CRITICAL ERROR: $message', name: _appName, level: 1000, error: error, stackTrace: stackTrace);
  }

  // Public logging methods
  void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  void warning(String message, {String? tag, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }

  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  void critical(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.critical, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  // Convenience methods for common scenarios
  void logApiCall(String endpoint, {String? method, int? statusCode, String? response}) {
    final methodStr = method ?? 'GET';
    final statusStr = statusCode != null ? ' ($statusCode)' : '';
    final responseStr = response != null ? ' - $response' : '';
    
    info('API $methodStr $endpoint$statusStr$responseStr', tag: 'API');
  }

  void logUserAction(String action, {String? userId, Map<String, dynamic>? data}) {
    final userStr = userId != null ? ' (User: $userId)' : '';
    final dataStr = data != null ? ' - ${data.toString()}' : '';
    
    info('User Action: $action$userStr$dataStr', tag: 'USER');
  }

  void logPerformance(String operation, {Duration? duration, String? details}) {
    final durationStr = duration != null ? ' (${duration.inMilliseconds}ms)' : '';
    final detailsStr = details != null ? ' - $details' : '';
    
    info('Performance: $operation$durationStr$detailsStr', tag: 'PERF');
  }

  void logError(String operation, Object error, {StackTrace? stackTrace, String? tag}) {
    this.error('Error in $operation: $error', tag: tag, error: error, stackTrace: stackTrace);
  }
}

// Global logger instance
final logger = LoggingService(); 