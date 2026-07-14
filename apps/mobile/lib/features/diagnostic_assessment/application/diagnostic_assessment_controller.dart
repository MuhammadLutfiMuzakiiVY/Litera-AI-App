import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litera_ai_mobile/core/connectivity/network_mode.dart';
import 'package:litera_ai_mobile/core/sync/outbox_event.dart';
import 'package:litera_ai_mobile/core/sync/outbox_queue.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/application/diagnostic_assessment_providers.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/application/diagnostic_assessment_state.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_profile.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/repositories/diagnostic_assessment_repository.dart';

final diagnosticAssessmentControllerProvider = StateNotifierProvider<
    DiagnosticAssessmentController, DiagnosticAssessmentState>((ref) {
  return DiagnosticAssessmentController(
    ref.watch(diagnosticAssessmentRepositoryProvider),
    ref.read(networkModeControllerProvider.notifier),
    ref.read(outboxQueueProvider.notifier),
  )..startOrResume();
});

class DiagnosticAssessmentController
    extends StateNotifier<DiagnosticAssessmentState> {
  DiagnosticAssessmentController(
    this._repository,
    this._networkModeController,
    this._outboxQueueController,
  )
      : super(const DiagnosticAssessmentState(isLoading: true));

  final DiagnosticAssessmentRepository _repository;
  final NetworkModeController _networkModeController;
  final OutboxQueueController _outboxQueueController;

  Future<void> startOrResume() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _repository.startOrResume();
      final initialOptionId = session.questions.isEmpty
          ? null
          : session.questions.first.options.isEmpty
              ? null
              : session.questions.first.options.first.id;
      state = state.copyWith(
        session: session,
        isLoading: false,
        selectedOptionId: initialOptionId,
      );
    } on Object {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Asesmen belum bisa dimuat. Coba lagi.',
      );
    }
  }

  void selectOption(String optionId) {
    state = state.copyWith(selectedOptionId: optionId);
  }

  Future<void> submit() async {
    final session = state.session;
    final question = session?.questions[state.currentIndex];
    final selectedOptionId = state.selectedOptionId;
    if (session == null || question == null || selectedOptionId == null) {
      state = state.copyWith(errorMessage: 'Pilih jawaban terlebih dahulu.');
      return;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final idempotencyKey =
          '${session.id}-${question.id}-${DateTime.now().millisecondsSinceEpoch}';
      if (_networkModeController.isOnline) {
        await _repository.saveAnswer(
          sessionId: session.id,
          questionId: question.id,
          selectedOptionId: selectedOptionId,
          responseTimeMs: 12000,
          idempotencyKey: idempotencyKey,
        );
      } else {
        _outboxQueueController.enqueue(
          OutboxEvent(
            idempotencyKey: idempotencyKey,
            eventType: 'diagnostic_answer_saved',
            payload: {
              'sessionId': session.id,
              'questionId': question.id,
              'selectedOptionId': selectedOptionId,
              'responseTimeMs': 12000,
            },
            occurredAt: DateTime.now(),
          ),
        );
        state = state.copyWith(
          profile: const DiagnosticProfile(
            literacyProfile: 'developing_reader',
            numeracyProfile: 'transitional',
            confidence: 0.72,
            modelVersion: 'offline-diagnostic-0.1.0',
          ),
          isSubmitting: false,
        );
        return;
      }
      final profile = await _repository.submit(sessionId: session.id);
      state = state.copyWith(profile: profile, isSubmitting: false);
    } on Object {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Submit asesmen gagal. Periksa koneksi lalu coba lagi.',
      );
    }
  }
}
