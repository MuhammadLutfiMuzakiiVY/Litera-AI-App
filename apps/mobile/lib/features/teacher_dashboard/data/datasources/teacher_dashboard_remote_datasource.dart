import 'package:dio/dio.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/data/dtos/teacher_dashboard_dtos.dart';

class TeacherDashboardRemoteDataSource {
  const TeacherDashboardRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<ClassroomDto>> getClassrooms() async {
    final response = await _dio.get<List<dynamic>>('/teacher/classrooms');
    return (response.data ?? const [])
        .whereType<Map<String, Object?>>()
        .map(ClassroomDto.fromJson)
        .toList();
  }

  Future<ClassroomProgressDto> getClassroomProgress(String classroomId) async {
    final response = await _dio.get<Map<String, Object?>>(
      '/teacher/classrooms/$classroomId/progress',
    );
    return ClassroomProgressDto.fromJson(
      response.data ?? const <String, Object?>{},
    );
  }

  Future<List<InterventionRecommendationDto>> getInterventions(
    String studentId,
  ) async {
    final response = await _dio.get<List<dynamic>>(
      '/teacher/students/$studentId/interventions',
    );
    return (response.data ?? const [])
        .whereType<Map<String, Object?>>()
        .map(InterventionRecommendationDto.fromJson)
        .toList();
  }
}

