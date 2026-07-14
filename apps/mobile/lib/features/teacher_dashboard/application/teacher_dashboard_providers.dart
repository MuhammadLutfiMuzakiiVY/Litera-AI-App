import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litera_ai_mobile/core/config/app_config.dart';
import 'package:litera_ai_mobile/core/network/api_client.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/data/datasources/teacher_dashboard_remote_datasource.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/data/repositories/mock_teacher_dashboard_repository.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/data/repositories/remote_teacher_dashboard_repository.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/domain/entities/teacher_dashboard_models.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/domain/repositories/teacher_dashboard_repository.dart';

final teacherDashboardRepositoryProvider =
    Provider<TeacherDashboardRepository>((ref) {
  if (AppConfig.current.enableMockAuth) {
    return MockTeacherDashboardRepository();
  }
  return RemoteTeacherDashboardRepository(
    TeacherDashboardRemoteDataSource(ref.watch(dioProvider)),
  );
});

final classroomsProvider = FutureProvider<List<Classroom>>((ref) {
  return ref.watch(teacherDashboardRepositoryProvider).getClassrooms();
});

final classroomProgressProvider =
    FutureProvider.family<ClassroomProgress, String>((ref, classroomId) {
  return ref
      .watch(teacherDashboardRepositoryProvider)
      .getClassroomProgress(classroomId);
});

final interventionsProvider =
    FutureProvider.family<List<InterventionRecommendation>, String>(
  (ref, studentId) {
    return ref.watch(teacherDashboardRepositoryProvider).getInterventions(studentId);
  },
);

