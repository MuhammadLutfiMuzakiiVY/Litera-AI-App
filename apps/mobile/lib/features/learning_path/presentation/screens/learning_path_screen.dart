import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:litera_ai_mobile/features/learning/application/learning_providers.dart';
import 'package:litera_ai_mobile/shared/widgets/app_navigation.dart';
import 'package:litera_ai_mobile/shared/widgets/app_screen.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final path = ref.watch(currentLearningPathProvider);

    return AppScreen(
      title: 'Learning Path',
      bottomNavigationBar: const StudentNavigationBar(selectedIndex: 1),
      children: path.when(
        data: (data) => [
          if (data.items.isEmpty)
            const AppEmptyState(
              title: 'Learning path kosong',
              message: 'Selesaikan asesmen diagnostik untuk membuat jalur belajar.',
            )
          else
            for (final item in data.items.indexed) ...[
              InfoCard(
                icon: item.$1 == 0 ? Icons.play_circle : Icons.lock_open,
                title: item.$2.title,
                body:
                    'Status: ${item.$2.status}\nDifficulty: ${item.$2.targetDifficulty}',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/student/modules/${item.$2.moduleId}'),
              ),
              const SizedBox(height: 12),
            ],
        ],
        loading: () => [const Center(child: CircularProgressIndicator())],
        error: (error, stackTrace) => [
          AppEmptyState(
            title: 'Learning path gagal dimuat',
            message: 'Periksa koneksi lalu coba lagi.',
            action: FilledButton.icon(
              onPressed: () => ref.invalidate(currentLearningPathProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ),
        ],
      ),
    );
  }
}
