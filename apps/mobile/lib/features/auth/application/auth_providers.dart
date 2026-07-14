import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litera_ai_mobile/core/config/app_config.dart';
import 'package:litera_ai_mobile/core/network/api_client.dart';
import 'package:litera_ai_mobile/core/security/secure_token_store.dart';
import 'package:litera_ai_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:litera_ai_mobile/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:litera_ai_mobile/features/auth/data/repositories/remote_auth_repository.dart';
import 'package:litera_ai_mobile/features/auth/domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (AppConfig.current.enableMockAuth) {
    return MockAuthRepository();
  }

  return RemoteAuthRepository(
    remoteDataSource: AuthRemoteDataSource(ref.watch(dioProvider)),
    tokenStore: ref.watch(secureTokenStoreProvider),
  );
});

