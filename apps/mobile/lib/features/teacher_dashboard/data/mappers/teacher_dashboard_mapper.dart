import 'package:litera_ai_mobile/features/teacher_dashboard/data/dtos/teacher_dashboard_dtos.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/domain/entities/teacher_dashboard_models.dart';

extension ClassroomDtoMapper on ClassroomDto {
  Classroom toDomain() {
    return Classroom(id: id, name: name, academicYear: academicYear);
  }
}

extension ClassroomProgressDtoMapper on ClassroomProgressDto {
  ClassroomProgress toDomain() {
    return ClassroomProgress(
      classroomId: classroomId,
      students: students.map((student) => student.toDomain()).toList(),
    );
  }
}

extension StudentProgressSummaryDtoMapper on StudentProgressSummaryDto {
  StudentProgressSummary toDomain() {
    return StudentProgressSummary(
      studentId: studentId,
      fullName: fullName,
      averageMastery: averageMastery,
      riskLevel: riskLevel,
    );
  }
}

extension InterventionRecommendationDtoMapper on InterventionRecommendationDto {
  InterventionRecommendation toDomain() {
    return InterventionRecommendation(
      id: id,
      studentId: studentId,
      priority: priority,
      recommendationType: recommendationType,
      rationale: rationale,
    );
  }
}

