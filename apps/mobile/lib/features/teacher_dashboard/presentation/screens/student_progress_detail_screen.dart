import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/application/teacher_dashboard_providers.dart';
import 'package:litera_ai_mobile/shared/widgets/app_navigation.dart';
import 'package:litera_ai_mobile/shared/widgets/app_screen.dart';

class StudentProgressDetailScreen extends ConsumerWidget {
  const StudentProgressDetailScreen({required this.studentId, super.key});

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interventions = ref.watch(interventionsProvider(studentId));

    return AppScreen(
      title: 'Detail Siswa',
      bottomNavigationBar: const TeacherNavigationBar(selectedIndex: 2),
      children: [
        Text('Student ID: $studentId'),
        const SizedBox(height: 12),
        const InfoCard(
          icon: Icons.person_outline,
          title: 'Profil Siswa',
          body: 'Detail mastery dan riwayat belajar ditampilkan dari data kelas.',
        ),
        const SizedBox(height: 12),
        interventions.when(
          data: (data) {
            if (data.isEmpty) {
              return const AppEmptyState(
                title: 'Belum ada rekomendasi',
                message: 'Sistem belum menemukan intervensi prioritas.',
              );
            }
            final item = data.first;
            return InfoCard(
              icon: Icons.psychology_alt_outlined,
              title: 'Rekomendasi ${item.priority}',
              body: item.rationale,
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) => const InfoCard(
            icon: Icons.error_outline,
            title: 'Rekomendasi gagal dimuat',
            body: 'Coba buka ulang detail siswa.',
          ),
        ),
        const SizedBox(height: 12),
        const InfoCard(
          icon: Icons.timeline_outlined,
          title: 'Rationale AI',
          body:
              'Rationale disusun dari mastery probability, response time, dan tren jawaban terakhir.',
        ),
      ],
    );
  }
}
