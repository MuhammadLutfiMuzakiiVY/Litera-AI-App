import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litera_ai_mobile/core/config/app_config.dart';
import 'package:litera_ai_mobile/core/network/api_client.dart';
import 'package:litera_ai_mobile/features/learning/data/datasources/learning_cache_datasource.dart';
import 'package:litera_ai_mobile/features/learning/data/datasources/learning_remote_datasource.dart';
import 'package:litera_ai_mobile/features/learning/data/repositories/mock_learning_repository.dart';
import 'package:litera_ai_mobile/features/learning/data/repositories/remote_learning_repository.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/learning_module.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/learning_path.dart';
import 'package:litera_ai_mobile/features/learning/domain/entities/student_progress.dart';
import 'package:litera_ai_mobile/features/learning/domain/repositories/learning_repository.dart';

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  if (AppConfig.current.enableMockAuth) {
    return MockLearningRepository();
  }
  return RemoteLearningRepository(
    remoteDataSource: LearningRemoteDataSource(ref.watch(dioProvider)),
    cacheDataSource: const LearningCacheDataSource(),
  );
});

final studentProgressProvider = FutureProvider<StudentProgress>((ref) {
  return ref.watch(learningRepositoryProvider).getStudentProgress();
});

final currentLearningPathProvider = FutureProvider<LearningPath>((ref) {
  return ref.watch(learningRepositoryProvider).getCurrentPath();
});

final moduleDetailProvider =
    FutureProvider.family<LearningModule, String>((ref, moduleId) {
  return ref.watch(learningRepositoryProvider).getModule(moduleId);
});
