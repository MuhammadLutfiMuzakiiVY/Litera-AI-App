import 'dart:async';

import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_profile.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_question.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_session.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/repositories/diagnostic_assessment_repository.dart';

class MockDiagnosticAssessmentRepository
    implements DiagnosticAssessmentRepository {
  @override
  Future<DiagnosticSession> startOrResume() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const DiagnosticSession(
      id: 'mock-diagnostic-session',
      status: 'in_progress',
      questions: [
        DiagnosticQuestion(
          id: 'q-1',
          conceptId: 'concept-inference',
          difficulty: 'medium',
          stem:
              'Data menunjukkan penggunaan air naik saat hari olahraga. Intervensi paling logis adalah...',
          options: [
            DiagnosticOption(id: 'a', label: 'A', body: 'Mengurangi semua kegiatan.'),
            DiagnosticOption(
              id: 'b',
              label: 'B',
              body: 'Menyiapkan titik isi ulang dan jadwal penggunaan air.',
            ),
            DiagnosticOption(id: 'c', label: 'C', body: 'Mengabaikan data.'),
            DiagnosticOption(id: 'd', label: 'D', body: 'Menyimpulkan tanpa data.'),
          ],
        ),
      ],
    );
  }

  @override
  Future<void> saveAnswer({
    required String sessionId,
    required String questionId,
    required String selectedOptionId,
    required int responseTimeMs,
    required String idempotencyKey,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<DiagnosticProfile> submit({required String sessionId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return const DiagnosticProfile(
      literacyProfile: 'developing_reader',
      numeracyProfile: 'transitional',
      confidence: 0.86,
      modelVersion: 'cnn-diagnostic-0.1.0',
    );
  }
}

