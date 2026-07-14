import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litera_ai_mobile/core/config/app_config.dart';
import 'package:litera_ai_mobile/core/network/api_client.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/data/datasources/diagnostic_remote_datasource.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/data/repositories/mock_diagnostic_assessment_repository.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/data/repositories/remote_diagnostic_assessment_repository.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/domain/repositories/diagnostic_assessment_repository.dart';

final diagnosticAssessmentRepositoryProvider =
    Provider<DiagnosticAssessmentRepository>((ref) {
  if (AppConfig.current.enableMockAuth) {
    return MockDiagnosticAssessmentRepository();
  }
  return RemoteDiagnosticAssessmentRepository(
    DiagnosticRemoteDataSource(ref.watch(dioProvider)),
  );
});

