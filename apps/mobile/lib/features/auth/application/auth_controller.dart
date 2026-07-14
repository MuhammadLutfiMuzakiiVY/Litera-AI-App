import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litera_ai_mobile/core/security/secure_token_store.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_providers.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_state.dart';
import 'package:litera_ai_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:litera_ai_mobile/features/auth/domain/user_role.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.watch(authRepositoryProvider),
    ref.watch(secureTokenStoreProvider),
  );
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository, this._tokenStore) : super(const AuthState.unknown()) {
    unawaited(restoreSession());
  }

  final AuthRepository _repository;
  final SecureTokenStore _tokenStore;

  Future<void> restoreSession() async {
    final startTime = DateTime.now();
    final user = await _repository.restoreSession();
    final onboardingCompleted = await _tokenStore.isOnboardingCompleted();
    
    final elapsed = DateTime.now().difference(startTime);
    final remaining = const Duration(milliseconds: 3000) - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (user == null) {
      state = AuthState(
        status: AuthStatus.guest,
        onboardingCompleted: onboardingCompleted,
      );
      return;
    }
    state = AuthState.fromUser(user: user, onboardingCompleted: true);
  }

  void completeOnboarding() {
    unawaited(_tokenStore.saveOnboardingCompleted());
    state = state.copyWith(
      status: AuthStatus.guest,
      onboardingCompleted: true,
    );
  }

  Future<void> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final session = await _repository.login(
      email: email,
      password: password,
      role: role,
    );
    state = AuthState.fromUser(
      user: session.user,
      onboardingCompleted: true,
    );
  }

  Future<void> loginWithGoogle({required UserRole role}) async {
    final session = await _repository.loginWithGoogle(role: role);
    state = AuthState.fromUser(
      user: session.user,
      onboardingCompleted: true,
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final user = await _repository.register(
      email: email,
      password: password,
      role: role,
    );
    state = AuthState.fromUser(user: user, onboardingCompleted: true);
  }

  Future<void> verifyEmail({required String otp}) async {
    final user = await _repository.verifyEmail(otp: otp);
    state = AuthState.fromUser(user: user, onboardingCompleted: true);
  }

  Future<void> completeProfile({
    required String fullName,
    String? photoPath,
    String? schoolName,
    String? educationLevel,
    String? gender,
  }) async {
    final role = state.role ?? UserRole.student;
    final user = await _repository.completeProfile(
      fullName: fullName,
      role: role,
      photoPath: photoPath,
      schoolName: schoolName,
      educationLevel: educationLevel,
      gender: gender,
    );
    state = AuthState.fromUser(user: user, onboardingCompleted: true);
  }

  void submitDiagnostic() {
    state = state.copyWith(status: AuthStatus.diagnosticResultReady);
  }

  void continueAfterDiagnosticResult() {
    state = state.copyWith(status: AuthStatus.studentReady);
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(
      status: AuthStatus.guest,
      onboardingCompleted: true,
    );
  }
}
