import 'package:litera_ai_mobile/features/learning/domain/entities/learning_module.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/learning_path.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/quiz.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/student_progress.dart';

abstract interface class LearningRepository {
  Future<StudentProgress> getStudentProgress();

  Future<LearningPath> getCurrentPath();

  Future<LearningModule> getModule(String moduleId);

  Future<QuizSession> startQuiz(String moduleId);

  Future<void> saveQuizAnswer({
    required String quizSessionId,
    required String questionId,
    required String selectedOptionId,
    required int responseTimeMs,
    required String idempotencyKey,
  });

  Future<QuizEvaluation> submitQuiz(String quizSessionId);
}

