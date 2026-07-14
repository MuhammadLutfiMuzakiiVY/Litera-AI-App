import 'package:litera_ai_mobile/features/auth/domain/user_role.dart';

class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    required this.role,
    required this.emailVerified,
    required this.profileCompleted,
    this.fullName,
  });

  factory UserDto.fromJson(Map<String, Object?> json) {
    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      role: _roleFromString(json['role'] as String? ?? 'student'),
      fullName: json['full_name'] as String? ?? json['fullName'] as String?,
      emailVerified:
          json['email_verified'] as bool? ?? json['emailVerified'] as bool? ?? false,
      profileCompleted: json['profile_completed'] as bool? ??
          json['profileCompleted'] as bool? ??
          false,
    );
  }

  final String id;
  final String email;
  final UserRole role;
  final String? fullName;
  final bool emailVerified;
  final bool profileCompleted;
}

class AuthSessionDto {
  const AuthSessionDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });

  factory AuthSessionDto.fromJson(Map<String, Object?> json) {
    return AuthSessionDto(
      accessToken: json['access_token'] as String? ?? json['accessToken'] as String,
      refreshToken:
          json['refresh_token'] as String? ?? json['refreshToken'] as String,
      expiresIn: json['expires_in'] as int? ?? json['expiresIn'] as int,
      user: UserDto.fromJson(json['user'] as Map<String, Object?>),
    );
  }

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final UserDto user;
}

UserRole _roleFromString(String value) {
  return UserRole.values.firstWhere(
    (role) => role.name == value,
    orElse: () => UserRole.student,
  );
}

