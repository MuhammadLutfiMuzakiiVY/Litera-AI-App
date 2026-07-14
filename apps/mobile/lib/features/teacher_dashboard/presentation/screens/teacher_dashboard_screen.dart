import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:litera_ai_mobile/app/router/route_names.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/application/teacher_dashboard_providers.dart';
import 'package:litera_ai_mobile/shared/widgets/app_navigation.dart';
import 'package:litera_ai_mobile/shared/widgets/app_screen.dart';

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classrooms = ref.watch(classroomsProvider);
    final progress = ref.watch(classroomProgressProvider('demo-class'));

    return AppScreen(
      title: 'Dashboard Guru',
      actions: [
        IconButton(
          tooltip: 'Notifikasi',
          onPressed: () => context.push(RouteNames.notifications),
          icon: const Icon(Icons.notifications_outlined),
        ),
      ],
      bottomNavigationBar: const TeacherNavigationBar(selectedIndex: 0),
      children: [
        classrooms.when(
          data: (data) => InfoCard(
            icon: Icons.groups_outlined,
            title: data.isEmpty ? 'Belum ada kelas' : data.first.name,
            body: data.isEmpty
                ? 'Tambahkan kelas untuk mulai memantau progres siswa.'
                : 'Tahun ajaran ${data.first.academicYear}.',
          ),
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) => const InfoCard(
            icon: Icons.error_outline,
            title: 'Kelas gagal dimuat',
            body: 'Periksa koneksi lalu coba lagi.',
          ),
        ),
        const SizedBox(height: 12),
        progress.when(
          data: (data) {
            final highRisk = data.students
                .where((student) => student.riskLevel == 'high')
                .length;
            return InfoCard(
              icon: Icons.grid_view_outlined,
              title: 'Peta Kompetensi',
              body:
                  '${data.students.length} siswa aktif. $highRisk siswa butuh intervensi prioritas.',
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const InfoCard(
            icon: Icons.error_outline,
            title: 'Progress gagal dimuat',
            body: 'Data kelas belum bisa diambil.',
          ),
        ),
        const SizedBox(height: 16),
        const SectionTitle('Siswa prioritas'),
        progress.maybeWhen(
          data: (data) {
            final highRiskStudents =
                data.students.where((student) => student.riskLevel == 'high');
            if (highRiskStudents.isEmpty) {
              return const AppEmptyState(
                title: 'Tidak ada prioritas tinggi',
                message: 'Semua siswa berada pada risiko rendah atau sedang.',
              );
            }
            final student = highRiskStudents.first;
            return InfoCard(
              icon: Icons.priority_high_outlined,
              title: student.fullName,
              body:
                  'Risk: ${student.riskLevel}. Mastery ${(student.averageMastery * 100).toStringAsFixed(0)}%.',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/teacher/students/${student.studentId}'),
            );
          },
          orElse: () => const SizedBox.shrink(),
        ),
        const SizedBox(height: 12),
        InfoCard(
          icon: Icons.groups,
          title: 'Buka Kelas VIII A',
          body: 'Lihat progres lengkap per siswa dan konsep.',
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.go('/teacher/classes/demo-class'),
        ),
      ],
    );
  }
}
