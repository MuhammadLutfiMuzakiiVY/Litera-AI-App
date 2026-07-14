import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litera_ai_mobile/core/logging/app_logger.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(const AppLogger());
});

class AnalyticsService {
  const AnalyticsService(this._logger);

  final AppLogger _logger;

  Future<void> track(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    _logger.info('analytics:$name', context: parameters);
  }
}

