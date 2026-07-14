import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litera_ai_mobile/core/network/api_client.dart';
import 'package:litera_ai_mobile/core/sync/outbox_event.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(ref.watch(dioProvider));
});

class SyncService {
  const SyncService(this._dio);

  final Dio _dio;

  Future<List<String>> push(List<OutboxEvent> events) async {
    if (events.isEmpty) return const [];
    final response = await _dio.post<Map<String, Object?>>(
      '/sync/push',
      data: {'events': events.map((event) => event.toJson()).toList()},
    );
    final accepted = response.data?['accepted'];
    if (accepted is List) {
      return accepted.whereType<String>().toList();
    }
    return const [];
  }

  Future<void> pull({DateTime? since}) async {
    await _dio.get<Map<String, Object?>>(
      '/sync/pull',
      queryParameters: {
        if (since != null) 'since': since.toIso8601String(),
      },
    );
  }
}

