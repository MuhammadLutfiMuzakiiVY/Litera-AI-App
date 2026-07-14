import 'package:litera_ai_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:litera_ai_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:litera_ai_mobile/features/auth/domain/user_role.dart';

abstract interface class AuthRepository {
  Future<AuthUser?> restoreSession();

  Future<AuthSession> login({
    required String email,
    required String password,
    required UserRole role,
  });

  Future<AuthUser> register({
    required String email,
    required String password,
    required UserRole role,
  });

  Future<AuthUser> verifyEmail({required String otp});

  Future<AuthUser> completeProfile({
    required String fullName,
    required UserRole role,
    String? photoPath,
    String? schoolName,
    String? educationLevel,
    String? gender,
  });

  Future<AuthSession> loginWithGoogle({required UserRole role});

  Future<void> logout();
}

