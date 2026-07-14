import 'package:litera_ai_mobile/features/learning/domain/entities/quiz.dart';

class QuizState {
  const QuizState({
    this.session,
    this.evaluation,
    this.selectedOptionId,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final QuizSession? session;
  final QuizEvaluation? evaluation;
  final String? selectedOptionId;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  QuizState copyWith({
    QuizSession? session,
    QuizEvaluation? evaluation,
    String? selectedOptionId,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return QuizState(
      session: session ?? this.session,
      evaluation: evaluation ?? this.evaluation,
      selectedOptionId: selectedOptionId ?? this.selectedOptionId,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

