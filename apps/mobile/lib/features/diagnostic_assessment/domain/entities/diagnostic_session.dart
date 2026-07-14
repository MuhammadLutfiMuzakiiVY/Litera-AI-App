import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_question.dart';

class DiagnosticSession {
  const DiagnosticSession({
    required this.id,
    required this.status,
    required this.questions,
  });

  final String id;
  final String status;
  final List<DiagnosticQuestion> questions;
}

