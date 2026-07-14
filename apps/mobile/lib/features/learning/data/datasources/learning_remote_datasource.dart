import 'package:dio/dio.dart';
import 'package:litera_ai_mobile/features/learning/data/dtos/learning_dtos.dart';

class LearningRemoteDataSource {
  const LearningRemoteDataSource(this._dio);

  final Dio _dio;

  Future<LearningPathDto> getCurrentPath() async {
    final response = await _dio.get<Map<String, Object?>>(
      '/learning-paths/current',
    );
    return LearningPathDto.fromJson(response.data ?? const <String, Object?>{});
  }

  Future<LearningModuleDto> getModule(String moduleId) async {
    final response = await _dio.get<Map<String, Object?>>('/modules/$moduleId');
    return LearningModuleDto.fromJson(response.data ?? const <String, Object?>{});
  }

  Future<QuizSessionDto> startQuiz(String moduleId) async {
    final response = await _dio.post<Map<String, Object?>>(
      '/quizzes',
      data: {'module_id': moduleId},
    );
    return QuizSessionDto.fromJson(response.data ?? const <String, Object?>{});
  }

  Future<void> saveQuizAnswer({
    required String quizSessionId,
    required String questionId,
    required String selectedOptionId,
    required int responseTimeMs,
    required String idempotencyKey,
  }) async {
    await _dio.post<void>(
      '/quizzes/$quizSessionId/answers',
      data: {
        'question_id': questionId,
        'selected_option_id': selectedOptionId,
        'response_time_ms': responseTimeMs,
        'idempotency_key': idempotencyKey,
      },
    );
  }

  Future<QuizEvaluationDto> submitQuiz(String quizSessionId) async {
    final response = await _dio.post<Map<String, Object?>>(
      '/quizzes/$quizSessionId/submit',
    );
    return QuizEvaluationDto.fromJson(
      response.data ?? const <String, Object?>{},
    );
  }
}

