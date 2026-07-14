import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum NetworkMode { online, offline }

extension NetworkModeLabel on NetworkMode {
  bool get isOnline => this == NetworkMode.online;

  String get label => isOnline ? 'Online' : 'Offline';
}

final networkModeControllerProvider =
    StateNotifierProvider<NetworkModeController, NetworkMode>((ref) {
  return NetworkModeController();
});

class NetworkModeController extends StateNotifier<NetworkMode> {
  NetworkModeController() : super(_readInitialMode());

  bool get isOnline => state.isOnline;

  void setOnline() {
    state = NetworkMode.online;
    _persist();
  }

  void setOffline() {
    state = NetworkMode.offline;
    _persist();
  }

  void setOfflineEnabled(bool enabled) {
    state = enabled ? NetworkMode.offline : NetworkMode.online;
    _persist();
  }

  void _persist() {
    if (!Hive.isBoxOpen('app_settings')) return;
    Hive.box<Object?>('app_settings').put('network_mode', state.name);
  }
}

NetworkMode _readInitialMode() {
  if (!Hive.isBoxOpen('app_settings')) return NetworkMode.online;
  final value = Hive.box<Object?>('app_settings').get('network_mode');
  return value == NetworkMode.offline.name ? NetworkMode.offline : NetworkMode.online;
}
