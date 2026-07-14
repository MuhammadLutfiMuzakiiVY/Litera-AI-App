import 'package:dio/dio.dart';
import 'package:litera_ai_mobile/features/auth/data/dtos/auth_dtos.dart';
import 'package:litera_ai_mobile/features/auth/domain/user_role.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthSessionDto> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final response = await _dio.post<Map<String, Object?>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
        'role': role.name,
      },
    );
    return AuthSessionDto.fromJson(response.data ?? const <String, Object?>{});
  }

  Future<UserDto> register({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final response = await _dio.post<Map<String, Object?>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'role': role.name,
      },
    );
    final userJson =
        response.data?['user'] as Map<String, Object?>? ?? const <String, Object?>{};
    return UserDto.fromJson(userJson);
  }

  Future<UserDto> me() async {
    final response = await _dio.get<Map<String, Object?>>('/me');
    final userJson =
        response.data?['user'] as Map<String, Object?>? ?? const <String, Object?>{};
    return UserDto.fromJson(userJson);
  }

  Future<UserDto> verifyEmail({required String otp}) async {
    final response = await _dio.post<Map<String, Object?>>(
      '/auth/verify-email',
      data: {'otp': otp},
    );
    final userJson =
        response.data?['user'] as Map<String, Object?>? ?? const <String, Object?>{};
    return UserDto.fromJson(userJson);
  }

  Future<UserDto> completeProfile({
    required String fullName,
    required UserRole role,
  }) async {
    final response = await _dio.put<Map<String, Object?>>(
      '/profiles/complete',
      data: {
        'profile_type': role.name,
        'full_name': fullName,
        if (role == UserRole.student) 'grade_level': 'SMP-8',
        if (role == UserRole.teacher) 'subject_area': 'language',
      },
    );
    final userJson =
        response.data?['user'] as Map<String, Object?>? ?? const <String, Object?>{};
    return UserDto.fromJson(userJson);
  }

  Future<AuthSessionDto> loginWithGoogle({
    required String idToken,
    required UserRole role,
  }) async {
    final response = await _dio.post<Map<String, Object?>>(
      '/auth/google',
      data: {
        'id_token': idToken,
        'role': role.name,
      },
    );
    return AuthSessionDto.fromJson(response.data ?? const <String, Object?>{});
  }

  Future<void> logout() async {
    await _dio.post<void>('/auth/logout');
  }
}
