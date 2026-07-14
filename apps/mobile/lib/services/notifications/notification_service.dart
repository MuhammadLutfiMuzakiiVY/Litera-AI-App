import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return const NotificationService();
});

class NotificationService {
  const NotificationService();

  Future<void> initialize() async {}

  Future<void> requestPermission() async {}

  Future<void> scheduleStudyReminder({
    required String title,
    required String body,
  }) async {
    // Firebase/local notification wiring is added after platform scaffolding.
  }
}

