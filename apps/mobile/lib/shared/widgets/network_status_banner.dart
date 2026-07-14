import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litera_ai_mobile/core/connectivity/network_mode.dart';
import 'package:litera_ai_mobile/core/sync/outbox_queue.dart';

class NetworkStatusBanner extends ConsumerWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(networkModeControllerProvider);
    final pendingCount = ref.watch(outboxQueueProvider).length;

    if (mode.isOnline && pendingCount == 0) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final isOffline = !mode.isOnline;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isOffline ? colorScheme.tertiaryContainer : colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.cloud_off_outlined : Icons.sync_outlined,
            color: isOffline
                ? colorScheme.onTertiaryContainer
                : colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isOffline
                  ? 'Mode offline aktif. $pendingCount aksi menunggu sinkronisasi.'
                  : '$pendingCount aksi menunggu sinkronisasi.',
              style: TextStyle(
                color: isOffline
                    ? colorScheme.onTertiaryContainer
                    : colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          if (mode.isOnline && pendingCount > 0)
            TextButton(
              onPressed: () => ref.read(outboxQueueProvider.notifier).syncNow(),
              child: const Text('Sync'),
            ),
        ],
      ),
    );
  }
}

