import 'dart:async';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:litera_ai_mobile/core/config/app_config.dart';
import 'package:litera_ai_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:litera_ai_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:litera_ai_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:litera_ai_mobile/features/auth/domain/user_role.dart';

class MockAuthRepository implements AuthRepository {
  AuthUser? _user;

  @override
  Future<AuthUser?> restoreSession() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _user;
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _user = AuthUser(
      id: 'mock-user',
      email: email,
      role: role,
      emailVerified: false,
      profileCompleted: false,
    );
    return AuthSession(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      expiresIn: 900,
      user: _user!,
    );
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final session = await login(email: email, password: password, role: role);
    return session.user;
  }

  @override
  Future<AuthUser> verifyEmail({required String otp}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _user = _requireUser().copyWith(emailVerified: true);
    return _user!;
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
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _user = _requireUser().copyWith(
      fullName: fullName,
      profileCompleted: true,
      role: role,
      photoPath: photoPath,
      schoolName: schoolName,
      educationLevel: educationLevel,
      gender: gender,
    );
    return _user!;
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

    _user = AuthUser(
      id: googleUser.id,
      email: googleUser.email,
      fullName: googleUser.displayName,
      role: role,
      emailVerified: true,
      profileCompleted: false,
    );

    return AuthSession(
      accessToken: 'mock-google-access-token',
      refreshToken: 'mock-google-refresh-token',
      expiresIn: 900,
      user: _user!,
    );
  }

  @override
  Future<void> logout() async {
    _user = null;
  }

  AuthUser _requireUser() {
    final user = _user;
    if (user == null) {
      throw StateError('No mock user is signed in.');
    }
    return user;
  }
}

extension on AuthUser {
  AuthUser copyWith({
    UserRole? role,
    String? fullName,
    bool? emailVerified,
    bool? profileCompleted,
    String? photoPath,
    String? schoolName,
    String? educationLevel,
    String? gender,
  }) {
    return AuthUser(
      id: id,
      email: email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      emailVerified: emailVerified ?? this.emailVerified,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      photoPath: photoPath ?? this.photoPath,
      schoolName: schoolName ?? this.schoolName,
      educationLevel: educationLevel ?? this.educationLevel,
      gender: gender ?? this.gender,
    );
  }
}

