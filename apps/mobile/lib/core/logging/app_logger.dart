import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger();

  void info(String message, {Map<String, Object?> context = const {}}) {
    _write('INFO', message, context);
  }

  void warning(String message, {Map<String, Object?> context = const {}}) {
    _write('WARN', message, context);
  }

  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context = const {},
  }) {
    _write('ERROR', message, {...context, 'error': error});
    if (kDebugMode && stackTrace != null) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _write(String level, String message, Map<String, Object?> context) {
    if (kDebugMode) {
      debugPrint('[$level] $message ${context.isEmpty ? '' : context}');
    }
  }
}

