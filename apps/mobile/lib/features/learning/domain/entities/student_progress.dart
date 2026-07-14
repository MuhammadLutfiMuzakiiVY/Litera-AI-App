class StudentProgress {
  const StudentProgress({
    required this.averageMastery,
    required this.weeklyProgressLabel,
    required this.priorityConcepts,
  });

  final double averageMastery;
  final String weeklyProgressLabel;
  final List<String> priorityConcepts;
}

