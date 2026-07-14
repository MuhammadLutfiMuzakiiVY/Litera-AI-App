import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

typedef AppBuilder = Widget Function();

void bootstrap(AppBuilder builder) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    Zone.current.handleUncaughtError(
      details.exception,
      details.stack ?? StackTrace.current,
    );
  };

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Hive.initFlutter();
      await Hive.openBox<Object?>('app_settings');
      await Hive.openBox<Object?>('outbox_events');
      await Hive.openBox<Object?>('learning_cache');
      runApp(ProviderScope(child: builder()));
    },
    (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Uncaught error: $error');
        debugPrintStack(stackTrace: stackTrace);
      }
    },
  );
}
