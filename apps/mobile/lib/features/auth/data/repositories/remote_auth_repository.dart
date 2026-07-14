import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:litera_ai_mobile/core/config/app_config.dart';
import 'package:litera_ai_mobile/core/security/secure_token_store.dart';
import 'package:litera_ai_mobile/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:litera_ai_mobile/features/auth/data/mappers/auth_mapper.dart';
import 'package:litera_ai_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:litera_ai_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:litera_ai_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:litera_ai_mobile/features/auth/domain/user_role.dart';

class RemoteAuthRepository implements AuthRepository {
  const RemoteAuthRepository({
    required AuthRemoteDataSource remoteDataSource,
    required SecureTokenStore tokenStore,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStore = tokenStore;

  final AuthRemoteDataSource _remoteDataSource;
  final SecureTokenStore _tokenStore;

  @override
  Future<AuthUser?> restoreSession() async {
    final token = await _tokenStore.readAccessToken();
    if (token == null || token.isEmpty) return null;
    try {
      return (await _remoteDataSource.me()).toDomain();
    } on Object {
      await _tokenStore.clear();
      return null;
    }
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final session = (await _remoteDataSource.login(
      email: email,
      password: password,
      role: role,
    ))
        .toDomain();
    await _tokenStore.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    return session;
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final user = (await _remoteDataSource.register(
      email: email,
      password: password,
      role: role,
    ))
        .toDomain();
    await login(email: email, password: password, role: role);
    return user;
  }

  @override
  Future<AuthUser> verifyEmail({required String otp}) async {
    return (await _remoteDataSource.verifyEmail(otp: otp)).toDomain();
  }

  @override
  Future<AuthUser> completeProfile({
    required String fullName,
    required UserRole role,
    String? photoPath,
    String? schoolName,
    String? educationLevel,
    String? gender,
  }) async {
    return (await _remoteDataSource.completeProfile(
      fullName: fullName,
      role: role,
    ))
        .toDomain();
  }

  @override
  Future<AuthSession> loginWithGoogle({required UserRole role}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: Platform.isIOS ? AppConfig.current.googleClientId : null,
      scopes: ['email', 'profile'],
    );

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In dibatalkan oleh pengguna.');
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Gagal mendapatkan ID Token dari Google.');
    }

    final session = (await _remoteDataSource.loginWithGoogle(
      idToken: idToken,
      role: role,
    )).toDomain();

    await _tokenStore.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );

    return session;
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } finally {
      await _tokenStore.clear();
    }
  }
}

