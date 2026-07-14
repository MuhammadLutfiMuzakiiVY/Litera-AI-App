class Classroom {
  const Classroom({
    required this.id,
    required this.name,
    required this.academicYear,
  });

  final String id;
  final String name;
  final String academicYear;
}

class ClassroomProgress {
  const ClassroomProgress({
    required this.classroomId,
    required this.students,
  });

  final String classroomId;
  final List<StudentProgressSummary> students;
}

class StudentProgressSummary {
  const StudentProgressSummary({
    required this.studentId,
    required this.fullName,
    required this.averageMastery,
    required this.riskLevel,
  });

  final String studentId;
  final String fullName;
  final double averageMastery;
  final String riskLevel;
}

class InterventionRecommendation {
  const InterventionRecommendation({
    required this.id,
    required this.studentId,
    required this.priority,
    required this.recommendationType,
    required this.rationale,
  });

  final String id;
  final String studentId;
  final String priority;
  final String recommendationType;
  final String rationale;
}

