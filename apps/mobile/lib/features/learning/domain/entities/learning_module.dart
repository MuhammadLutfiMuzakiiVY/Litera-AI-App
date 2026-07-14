class LearningModule {
  const LearningModule({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.contents,
  });

  final String id;
  final String title;
  final String difficulty;
  final int estimatedMinutes;
  final List<ModuleContent> contents;
}

class ModuleContent {
  const ModuleContent({
    required this.id,
    required this.contentType,
    required this.sortOrder,
    required this.body,
    this.assetUrl,
  });

  final String id;
  final String contentType;
  final int sortOrder;
  final Map<String, Object?> body;
  final String? assetUrl;
}

