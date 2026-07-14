import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litera_ai_mobile/core/connectivity/network_mode.dart';
import 'package:litera_ai_mobile/core/sync/outbox_event.dart';
import 'package:litera_ai_mobile/core/sync/outbox_queue.dart';
import 'package:litera_ai_mobile/features/learning/application/learning_providers.dart';
import 'package:litera_ai_mobile/features/learning/application/quiz_state.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/quiz.dart';
import 'package:litera_ai_mobile/features/learning/domain/repositories/learning_repository.dart';

final quizControllerProvider =
    StateNotifierProvider.family<QuizController, QuizState, String>(
  (ref, moduleId) {
    return QuizController(
      ref.watch(learningRepositoryProvider),
      ref.read(networkModeControllerProvider.notifier),
      ref.read(outboxQueueProvider.notifier),
      moduleId,
    )..start();
  },
);

class QuizController extends StateNotifier<QuizState> {
  QuizController(
    this._repository,
    this._networkModeController,
    this._outboxQueueController,
    this._moduleId,
  )
      : super(const QuizState(isLoading: true));

  final LearningRepository _repository;
  final NetworkModeController _networkModeController;
  final OutboxQueueController _outboxQueueController;
  final String _moduleId;

  Future<void> start() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _repository.startQuiz(_moduleId);
      final selectedOptionId = session.questions.isEmpty
          ? null
          : session.questions.first.options.isEmpty
              ? null
              : session.questions.first.options.first.id;
      state = state.copyWith(
        session: session,
        selectedOptionId: selectedOptionId,
        isLoading: false,
      );
    } on Object {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Quiz belum bisa dimuat. Coba lagi.',
      );
    }
  }

  void selectOption(String optionId) {
    state = state.copyWith(selectedOptionId: optionId);
  }

  Future<void> submit() async {
    final session = state.session;
    final question = session == null || session.questions.isEmpty
        ? null
        : session.questions.first;
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
        await _repository.saveQuizAnswer(
          quizSessionId: session.id,
          questionId: question.id,
          selectedOptionId: selectedOptionId,
          responseTimeMs: 11000,
          idempotencyKey: idempotencyKey,
        );
      } else {
        _outboxQueueController.enqueue(
          OutboxEvent(
            idempotencyKey: idempotencyKey,
            eventType: 'quiz_answer_saved',
            payload: {
              'quizSessionId': session.id,
              'questionId': question.id,
              'selectedOptionId': selectedOptionId,
              'responseTimeMs': 11000,
            },
            occurredAt: DateTime.now(),
          ),
        );
        state = state.copyWith(
          evaluation: const QuizEvaluation(
            score: 80,
            mastery: [
              ConceptMastery(
                conceptId: 'concept-inference',
                masteryProbability: 0.7,
                confidence: 0.68,
              ),
            ],
            ddaDecision: DdaDecision(
              previousDifficulty: 'medium',
              nextDifficulty: 'medium',
              reasonCode: 'offline_keep',
              explanation:
                  'Hasil disimpan lokal. Difficulty final akan disinkronkan saat online.',
            ),
          ),
          isSubmitting: false,
        );
        return;
      }
      final evaluation = await _repository.submitQuiz(session.id);
      state = state.copyWith(evaluation: evaluation, isSubmitting: false);
    } on Object {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Submit quiz gagal. Coba lagi.',
      );
    }
  }
}
