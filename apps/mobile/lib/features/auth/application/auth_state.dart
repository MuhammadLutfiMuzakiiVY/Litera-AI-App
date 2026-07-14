import 'package:litera_ai_mobile/features/auth/domain/user_role.dart';
import 'package:litera_ai_mobile/features/auth/domain/entities/auth_user.dart';

enum AuthStatus {
  unknown,
  guest,
  emailUnverified,
  profileIncomplete,
  needsDiagnostic,
  diagnosticResultReady,
  studentReady,
  teacherReady,
  adminReady,
}

class AuthState {
  const AuthState({
    required this.status,
    required this.onboardingCompleted,
    this.role,
    this.email,
    this.fullName,
    this.photoPath,
    this.schoolName,
    this.educationLevel,
    this.gender,
  });

  const AuthState.unknown()
      : status = AuthStatus.unknown,
        onboardingCompleted = false,
        role = null,
        email = null,
        fullName = null,
        photoPath = null,
        schoolName = null,
        educationLevel = null,
        gender = null;

  final AuthStatus status;
  final bool onboardingCompleted;
  final UserRole? role;
  final String? email;
  final String? fullName;
  final String? photoPath;
  final String? schoolName;
  final String? educationLevel;
  final String? gender;

  bool get isAuthenticated =>
      status != AuthStatus.unknown && status != AuthStatus.guest;

  bool get isStudentReady => status == AuthStatus.studentReady;

  bool get isTeacherReady => status == AuthStatus.teacherReady;

  static AuthState fromUser({
    required AuthUser user,
    required bool onboardingCompleted,
  }) {
    final status = _statusFromUser(user);
    return AuthState(
      status: status,
      onboardingCompleted: onboardingCompleted,
      role: user.role,
      email: user.email,
      fullName: user.fullName,
      photoPath: user.photoPath,
      schoolName: user.schoolName,
      educationLevel: user.educationLevel,
      gender: user.gender,
    );
  }

  AuthState copyWith({
    AuthStatus? status,
    bool? onboardingCompleted,
    UserRole? role,
    String? email,
    String? fullName,
    String? photoPath,
    String? schoolName,
    String? educationLevel,
    String? gender,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      role: clearUser ? null : role ?? this.role,
      email: clearUser ? null : email ?? this.email,
      fullName: clearUser ? null : fullName ?? this.fullName,
      photoPath: clearUser ? null : photoPath ?? this.photoPath,
      schoolName: clearUser ? null : schoolName ?? this.schoolName,
      educationLevel: clearUser ? null : educationLevel ?? this.educationLevel,
      gender: clearUser ? null : gender ?? this.gender,
    );
  }
}

AuthStatus _statusFromUser(AuthUser user) {
  if (!user.emailVerified) return AuthStatus.emailUnverified;
  if (!user.profileCompleted) return AuthStatus.profileIncomplete;

  switch (user.role) {
    case UserRole.student:
      return AuthStatus.needsDiagnostic;
    case UserRole.teacher:
      return AuthStatus.teacherReady;
    case UserRole.admin:
      return AuthStatus.adminReady;
  }
}
