import 'package:litera_ai_mobile/features/learning/data/datasources/learning_remote_datasource.dart';
import 'package:litera_ai_mobile/features/learning/data/datasources/learning_cache_datasource.dart';
import 'package:litera_ai_mobile/features/learning/data/mappers/learning_mapper.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/learning_module.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/learning_path.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/quiz.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/student_progress.dart';
import 'package:litera_ai_mobile/features/learning/domain/repositories/learning_repository.dart';

class RemoteLearningRepository implements LearningRepository {
  const RemoteLearningRepository({
    required LearningRemoteDataSource remoteDataSource,
    required LearningCacheDataSource cacheDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _cacheDataSource = cacheDataSource;

  final LearningRemoteDataSource _remoteDataSource;
  final LearningCacheDataSource _cacheDataSource;

  @override
  Future<StudentProgress> getStudentProgress() async {
    final path = await getCurrentPath();
    return StudentProgress(
      averageMastery: 0.0,
      weeklyProgressLabel:
          'Learning path aktif dengan ${path.items.length} modul tersedia.',
      priorityConcepts: path.items.map((item) => item.title).take(3).toList(),
    );
  }

  @override
  Future<LearningPath> getCurrentPath() async {
    try {
      final path = await _remoteDataSource.getCurrentPath();
      await _cacheDataSource.saveCurrentPath(path);
      return path.toDomain();
    } on Object {
      final cached = _cacheDataSource.readCurrentPath();
      if (cached != null) return cached.toDomain();
      rethrow;
    }
  }

  @override
  Future<LearningModule> getModule(String moduleId) async {
    try {
      final module = await _remoteDataSource.getModule(moduleId);
      await _cacheDataSource.saveModule(module);
      return module.toDomain();
    } on Object {
      final cached = _cacheDataSource.readModule(moduleId);
      if (cached != null) return cached.toDomain();
      rethrow;
    }
  }

  @override
  Future<QuizSession> startQuiz(String moduleId) async {
    return (await _remoteDataSource.startQuiz(moduleId)).toDomain();
  }

  @override
  Future<void> saveQuizAnswer({
    required String quizSessionId,
    required String questionId,
    required String selectedOptionId,
    required int responseTimeMs,
    required String idempotencyKey,
  }) {
    return _remoteDataSource.saveQuizAnswer(
      quizSessionId: quizSessionId,
      questionId: questionId,
      selectedOptionId: selectedOptionId,
      responseTimeMs: responseTimeMs,
      idempotencyKey: idempotencyKey,
    );
  }

  @override
  Future<QuizEvaluation> submitQuiz(String quizSessionId) async {
    return (await _remoteDataSource.submitQuiz(quizSessionId)).toDomain();
  }
}
