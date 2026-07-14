class DiagnosticOptionDto {
  const DiagnosticOptionDto({
    required this.id,
    required this.label,
    required this.body,
  });

  factory DiagnosticOptionDto.fromJson(Map<String, Object?> json) {
    return DiagnosticOptionDto(
      id: json['id'] as String,
      label: json['label'] as String,
      body: json['body'] as String,
    );
  }

  final String id;
  final String label;
  final String body;
}

class DiagnosticQuestionDto {
  const DiagnosticQuestionDto({
    required this.id,
    required this.conceptId,
    required this.difficulty,
    required this.stem,
    required this.options,
  });

  factory DiagnosticQuestionDto.fromJson(Map<String, Object?> json) {
    final options = json['options'] as List? ?? const [];
    return DiagnosticQuestionDto(
      id: json['id'] as String,
      conceptId: json['concept_id'] as String? ?? json['conceptId'] as String,
      difficulty: json['difficulty'] as String,
      stem: json['stem'] as String,
      options: options
          .whereType<Map<String, Object?>>()
          .map(DiagnosticOptionDto.fromJson)
          .toList(),
    );
  }

  final String id;
  final String conceptId;
  final String difficulty;
  final String stem;
  final List<DiagnosticOptionDto> options;
}

class DiagnosticSessionDto {
  const DiagnosticSessionDto({
    required this.id,
    required this.status,
    required this.questions,
  });

  factory DiagnosticSessionDto.fromJson(Map<String, Object?> json) {
    final questions = json['questions'] as List? ?? const [];
    return DiagnosticSessionDto(
      id: json['id'] as String,
      status: json['status'] as String,
      questions: questions
          .whereType<Map<String, Object?>>()
          .map(DiagnosticQuestionDto.fromJson)
          .toList(),
    );
  }

  final String id;
  final String status;
  final List<DiagnosticQuestionDto> questions;
}

class DiagnosticProfileDto {
  const DiagnosticProfileDto({
    required this.literacyProfile,
    required this.numeracyProfile,
    required this.confidence,
    required this.modelVersion,
  });

  factory DiagnosticProfileDto.fromJson(Map<String, Object?> json) {
    return DiagnosticProfileDto(
      literacyProfile:
          json['literacy_profile'] as String? ?? json['literacyProfile'] as String,
      numeracyProfile:
          json['numeracy_profile'] as String? ?? json['numeracyProfile'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      modelVersion:
          json['model_version'] as String? ?? json['modelVersion'] as String,
    );
  }

  final String literacyProfile;
  final String numeracyProfile;
  final double confidence;
  final String modelVersion;
}

