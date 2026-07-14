import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:litera_ai_mobile/core/connectivity/network_mode.dart';
import 'package:litera_ai_mobile/core/sync/outbox_event.dart';
import 'package:litera_ai_mobile/core/sync/sync_service.dart';

final outboxQueueProvider =
    StateNotifierProvider<OutboxQueueController, List<OutboxEvent>>((ref) {
  return OutboxQueueController(ref)..loadPersistedEvents();
});

class OutboxQueueController extends StateNotifier<List<OutboxEvent>> {
  OutboxQueueController(this._ref) : super(const []);

  final Ref _ref;

  int get pendingCount => state.length;

  Box<Object?>? get _box {
    if (!Hive.isBoxOpen('outbox_events')) return null;
    return Hive.box<Object?>('outbox_events');
  }

  void loadPersistedEvents() {
    final box = _box;
    if (box == null) return;
    state = box.values
        .whereType<Map>()
        .map((json) => OutboxEvent.fromJson(Map<String, Object?>.from(json)))
        .toList(growable: false);
  }

  void enqueue(OutboxEvent event) {
    state = [...state, event];
    _box?.put(event.idempotencyKey, event.toJson());
  }

  Future<void> syncNow() async {
    if (state.isEmpty) return;
    final networkMode = _ref.read(networkModeControllerProvider);
    if (!networkMode.isOnline) return;

    final accepted = await _ref.read(syncServiceProvider).push(state);
    final box = _box;
    for (final key in accepted) {
      box?.delete(key);
    }
    state = state
        .where((event) => !accepted.contains(event.idempotencyKey))
        .toList(growable: false);
  }

  void clearSyncedForMockMode() {
    state = const [];
    _box?.clear();
  }
}
