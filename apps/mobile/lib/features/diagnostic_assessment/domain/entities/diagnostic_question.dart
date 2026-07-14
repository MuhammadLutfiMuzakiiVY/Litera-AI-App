class DiagnosticQuestion {
  const DiagnosticQuestion({
    required this.id,
    required this.conceptId,
    required this.difficulty,
    required this.stem,
    required this.options,
  });

  final String id;
  final String conceptId;
  final String difficulty;
  final String stem;
  final List<DiagnosticOption> options;
}

class DiagnosticOption {
  const DiagnosticOption({
    required this.id,
    required this.label,
    required this.body,
  });

  final String id;
  final String label;
  final String body;
}

