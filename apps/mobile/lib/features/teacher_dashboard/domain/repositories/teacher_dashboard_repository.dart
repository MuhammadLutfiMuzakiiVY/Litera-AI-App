import 'package:litera_ai_mobile/features/teacher_dashboard/domain/entities/teacher_dashboard_models.dart';

abstract interface class TeacherDashboardRepository {
  Future<List<Classroom>> getClassrooms();

  Future<ClassroomProgress> getClassroomProgress(String classroomId);

  Future<List<InterventionRecommendation>> getInterventions(String studentId);
}

