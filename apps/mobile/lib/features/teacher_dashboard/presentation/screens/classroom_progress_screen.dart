import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/application/teacher_dashboard_providers.dart';
import 'package:litera_ai_mobile/shared/widgets/app_navigation.dart';
import 'package:litera_ai_mobile/shared/widgets/app_screen.dart';

class ClassroomProgressScreen extends ConsumerWidget {
  const ClassroomProgressScreen({required this.classroomId, super.key});

  final String classroomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(classroomProgressProvider(classroomId));

    return AppScreen(
      title: 'Progress Kelas',
      bottomNavigationBar: const TeacherNavigationBar(selectedIndex: 1),
      children: progress.when(
        data: (data) => [
          Text('Classroom ID: ${data.classroomId}'),
          const SizedBox(height: 12),
          if (data.students.isEmpty)
            const AppEmptyState(
              title: 'Belum ada siswa',
              message: 'Tambahkan siswa untuk melihat progres kelas.',
            )
          else
            for (final student in data.students)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InfoCard(
                  icon: student.riskLevel == 'high'
                      ? Icons.warning_amber_outlined
                      : Icons.check_circle_outline,
                  title: student.fullName,
                  body:
                      'Mastery ${(student.averageMastery * 100).toStringAsFixed(0)}%. Risk: ${student.riskLevel}.',
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/teacher/students/${student.studentId}'),
                ),
              ),
        ],
        loading: () => [const Center(child: CircularProgressIndicator())],
        error: (error, stackTrace) => [
          AppEmptyState(
            title: 'Progress gagal dimuat',
            message: 'Periksa koneksi lalu coba lagi.',
            action: FilledButton.icon(
              onPressed: () => ref.invalidate(
                classroomProgressProvider(classroomId),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ),
        ],
      ),
    );
  }
}
