import 'dart:async';

import 'package:litera_ai_mobile/features/teacher_dashboard/domain/entities/teacher_dashboard_models.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/domain/repositories/teacher_dashboard_repository.dart';

class MockTeacherDashboardRepository implements TeacherDashboardRepository {
  @override
  Future<List<Classroom>> getClassrooms() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const [
      Classroom(id: 'demo-class', name: 'VIII A', academicYear: '2026/2027'),
    ];
  }

  @override
  Future<ClassroomProgress> getClassroomProgress(String classroomId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return ClassroomProgress(
      classroomId: classroomId,
      students: const [
        StudentProgressSummary(
          studentId: 'nadia',
          fullName: 'Nadia Putri',
          averageMastery: 0.48,
          riskLevel: 'high',
        ),
        StudentProgressSummary(
          studentId: 'fajar',
          fullName: 'Fajar Ramadhan',
          averageMastery: 0.65,
          riskLevel: 'medium',
        ),
        StudentProgressSummary(
          studentId: 'sinta',
          fullName: 'Sinta Aulia',
          averageMastery: 0.82,
          riskLevel: 'low',
        ),
      ],
    );
  }

  @override
  Future<List<InterventionRecommendation>> getInterventions(
    String studentId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return [
      InterventionRecommendation(
        id: 'intervention-1',
        studentId: studentId,
        priority: 'high',
        recommendationType: 'remedial_reading',
        rationale:
            'Dua quiz terakhir salah pada soal konteks, response time tinggi, mastery probability 0.42.',
      ),
    ];
  }
}

