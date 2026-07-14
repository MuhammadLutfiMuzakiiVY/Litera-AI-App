import 'package:litera_ai_mobile/features/auth/domain/user_role.dart';

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.role,
    required this.emailVerified,
    required this.profileCompleted,
    this.fullName,
    this.photoPath,
    this.schoolName,
    this.educationLevel,
    this.gender,
  });

  final String id;
  final String email;
  final UserRole role;
  final String? fullName;
  final bool emailVerified;
  final bool profileCompleted;
  final String? photoPath;
  final String? schoolName;
  final String? educationLevel;
  final String? gender;
}

