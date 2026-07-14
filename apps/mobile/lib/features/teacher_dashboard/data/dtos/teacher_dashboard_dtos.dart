class ClassroomDto {
  const ClassroomDto({
    required this.id,
    required this.name,
    required this.academicYear,
  });

  factory ClassroomDto.fromJson(Map<String, Object?> json) {
    return ClassroomDto(
      id: json['id'] as String,
      name: json['name'] as String,
      academicYear:
          json['academic_year'] as String? ?? json['academicYear'] as String,
    );
  }

  final String id;
  final String name;
  final String academicYear;
}

class ClassroomProgressDto {
  const ClassroomProgressDto({
    required this.classroomId,
    required this.students,
  });

  factory ClassroomProgressDto.fromJson(Map<String, Object?> json) {
    final students = json['students'] as List? ?? const [];
    return ClassroomProgressDto(
      classroomId:
          json['classroom_id'] as String? ?? json['classroomId'] as String,
      students: students
          .whereType<Map<String, Object?>>()
          .map(StudentProgressSummaryDto.fromJson)
          .toList(),
    );
  }

  final String classroomId;
  final List<StudentProgressSummaryDto> students;
}

class StudentProgressSummaryDto {
  const StudentProgressSummaryDto({
    required this.studentId,
    required this.fullName,
    required this.averageMastery,
    required this.riskLevel,
  });

  factory StudentProgressSummaryDto.fromJson(Map<String, Object?> json) {
    return StudentProgressSummaryDto(
      studentId: json['student_id'] as String? ?? json['studentId'] as String,
      fullName: json['full_name'] as String? ?? json['fullName'] as String,
      averageMastery:
          (json['average_mastery'] as num? ?? json['averageMastery'] as num)
              .toDouble(),
      riskLevel: json['risk_level'] as String? ?? json['riskLevel'] as String,
    );
  }

  final String studentId;
  final String fullName;
  final double averageMastery;
  final String riskLevel;
}

class InterventionRecommendationDto {
  const InterventionRecommendationDto({
    required this.id,
    required this.studentId,
    required this.priority,
    required this.recommendationType,
    required this.rationale,
  });

  factory InterventionRecommendationDto.fromJson(Map<String, Object?> json) {
    return InterventionRecommendationDto(
      id: json['id'] as String,
      studentId: json['student_id'] as String? ?? json['studentId'] as String,
      priority: json['priority'] as String,
      recommendationType: json['recommendation_type'] as String? ??
          json['recommendationType'] as String,
      rationale: json['rationale'] as String,
    );
  }

  final String id;
  final String studentId;
  final String priority;
  final String recommendationType;
  final String rationale;
}

