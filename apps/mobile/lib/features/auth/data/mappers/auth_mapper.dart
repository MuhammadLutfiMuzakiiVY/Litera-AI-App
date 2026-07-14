import 'package:litera_ai_mobile/features/auth/data/dtos/auth_dtos.dart';
import 'package:litera_ai_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:litera_ai_mobile/features/auth/domain/entities/auth_user.dart';

extension UserDtoMapper on UserDto {
  AuthUser toDomain() {
    return AuthUser(
      id: id,
      email: email,
      role: role,
      fullName: fullName,
      emailVerified: emailVerified,
      profileCompleted: profileCompleted,
    );
  }
}

extension AuthSessionDtoMapper on AuthSessionDto {
  AuthSession toDomain() {
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      user: user.toDomain(),
    );
  }
}

