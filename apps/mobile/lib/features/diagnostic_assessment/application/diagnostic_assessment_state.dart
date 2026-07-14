import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_profile.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/entities/diagnostic_session.dart';

class DiagnosticAssessmentState {
  const DiagnosticAssessmentState({
    this.session,
    this.profile,
    this.selectedOptionId,
    this.currentIndex = 0,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final DiagnosticSession? session;
  final DiagnosticProfile? profile;
  final String? selectedOptionId;
  final int currentIndex;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  bool get hasSession => session != null;

  DiagnosticAssessmentState copyWith({
    DiagnosticSession? session,
    DiagnosticProfile? profile,
    String? selectedOptionId,
    int? currentIndex,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearSelectedOption = false,
    bool clearError = false,
  }) {
    return DiagnosticAssessmentState(
      session: session ?? this.session,
      profile: profile ?? this.profile,
      selectedOptionId:
          clearSelectedOption ? null : selectedOptionId ?? this.selectedOptionId,
      currentIndex: currentIndex ?? this.currentIndex,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

