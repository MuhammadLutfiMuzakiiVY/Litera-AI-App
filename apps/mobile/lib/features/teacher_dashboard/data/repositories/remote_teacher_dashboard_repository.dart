import 'package:litera_ai_mobile/features/teacher_dashboard/data/datasources/teacher_dashboard_remote_datasource.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/data/mappers/teacher_dashboard_mapper.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/domain/entities/teacher_dashboard_models.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/domain/repositories/teacher_dashboard_repository.dart';

class RemoteTeacherDashboardRepository implements TeacherDashboardRepository {
  const RemoteTeacherDashboardRepository(this._remoteDataSource);

  final TeacherDashboardRemoteDataSource _remoteDataSource;

  @override
  Future<List<Classroom>> getClassrooms() async {
    return (await _remoteDataSource.getClassrooms())
        .map((classroom) => classroom.toDomain())
        .toList();
  }

  @override
  Future<ClassroomProgress> getClassroomProgress(String classroomId) async {
    return (await _remoteDataSource.getClassroomProgress(classroomId)).toDomain();
  }

  @override
  Future<List<InterventionRecommendation>> getInterventions(
    String studentId,
  ) async {
    return (await _remoteDataSource.getInterventions(studentId))
        .map((recommendation) => recommendation.toDomain())
        .toList();
  }
}

