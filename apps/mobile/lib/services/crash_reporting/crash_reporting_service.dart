import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litera_ai_mobile/core/logging/app_logger.dart';

final crashReportingServiceProvider = Provider<CrashReportingService>((ref) {
  return CrashReportingService(const AppLogger());
});

class CrashReportingService {
  const CrashReportingService(this._logger);

  final AppLogger _logger;

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    String reason = 'unhandled',
  }) async {
    _logger.error(reason, error: error, stackTrace: stackTrace);
  }
}

