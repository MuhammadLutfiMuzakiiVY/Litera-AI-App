import 'package:hive_flutter/hive_flutter.dart';
import 'package:litera_ai_mobile/features/learning/data/dtos/learning_dtos.dart';

class LearningCacheDataSource {
  const LearningCacheDataSource();

  Box<Object?>? get _box {
    if (!Hive.isBoxOpen('learning_cache')) return null;
    return Hive.box<Object?>('learning_cache');
  }

  Future<void> saveCurrentPath(LearningPathDto path) async {
    await _box?.put('current_path', path.toJson());
  }

  LearningPathDto? readCurrentPath() {
    final cached = _box?.get('current_path');
    if (cached is! Map) return null;
    return LearningPathDto.fromJson(Map<String, Object?>.from(cached));
  }

  Future<void> saveModule(LearningModuleDto module) async {
    await _box?.put('module:${module.id}', module.toJson());
  }

  LearningModuleDto? readModule(String moduleId) {
    final cached = _box?.get('module:$moduleId');
    if (cached is! Map) return null;
    return LearningModuleDto.fromJson(Map<String, Object?>.from(cached));
  }
}
