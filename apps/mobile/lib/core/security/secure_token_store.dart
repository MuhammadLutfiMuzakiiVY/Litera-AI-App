import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureTokenStoreProvider = Provider<SecureTokenStore>((ref) {
  return const SecureTokenStore(FlutterSecureStorage());
});

class SecureTokenStore {
  const SecureTokenStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _onboardingCompletedKey = 'onboarding_completed';

  Future<String?> readAccessToken() {
    return _storage.read(key: _accessTokenKey);
  }

  Future<String?> readRefreshToken() {
    return _storage.read(key: _refreshTokenKey);
  }

  Future<bool> isOnboardingCompleted() async {
    final val = await _storage.read(key: _onboardingCompletedKey);
    return val == 'true';
  }

  Future<void> saveOnboardingCompleted() async {
    await _storage.write(key: _onboardingCompletedKey, value: 'true');
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}

