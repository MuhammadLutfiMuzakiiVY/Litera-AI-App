class LearningPath {
  const LearningPath({
    required this.id,
    required this.status,
    required this.items,
  });

  final String id;
  final String status;
  final List<LearningPathItem> items;
}

class LearningPathItem {
  const LearningPathItem({
    required this.id,
    required this.conceptId,
    required this.moduleId,
    required this.title,
    required this.targetDifficulty,
    required this.status,
  });

  final String id;
  final String conceptId;
  final String moduleId;
  final String title;
  final String targetDifficulty;
  final String status;
}

