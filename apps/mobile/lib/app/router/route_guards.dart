import 'package:litera_ai_mobile/app/router/route_names.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_state.dart';

class AppRouteGuard {
  const AppRouteGuard._();

  static String? redirect(AuthState auth, String location) {
    if (location == RouteNames.splash || location == RouteNames.introVideo) {
      return null;
    }

    if (auth.status == AuthStatus.unknown) {
      return RouteNames.splash;
    }

    if (!auth.onboardingCompleted) {
      return location == RouteNames.onboarding ? null : RouteNames.onboarding;
    }

    if (location == RouteNames.onboarding) {
      return RouteNames.login;
    }

    switch (auth.status) {
      case AuthStatus.unknown:
        return RouteNames.splash;
      case AuthStatus.guest:
        if (_isGuestRoute(location)) return null;
        return RouteNames.login;
      case AuthStatus.emailUnverified:
        return location == RouteNames.verifyEmail ? null : RouteNames.verifyEmail;
      case AuthStatus.profileIncomplete:
        return location == RouteNames.completeProfile
            ? null
            : RouteNames.completeProfile;
      case AuthStatus.needsDiagnostic:
        return location == RouteNames.diagnostic ? null : RouteNames.diagnostic;
      case AuthStatus.diagnosticResultReady:
        return location == RouteNames.diagnosticResult
            ? null
            : RouteNames.diagnosticResult;
      case AuthStatus.studentReady:
        if (_isStudentRoute(location) || location == RouteNames.settings) {
          return null;
        }
        return RouteNames.studentDashboard;
      case AuthStatus.teacherReady:
        if (_isTeacherRoute(location) || location == RouteNames.settings) {
          return null;
        }
        return RouteNames.teacherDashboard;
      case AuthStatus.adminReady:
        return null;
    }
  }

  static bool _isGuestRoute(String location) {
    return location == RouteNames.login ||
        location == RouteNames.register;
  }

  static bool _isStudentRoute(String location) {
    return location.startsWith('/student') ||
        location.startsWith('/assessment/result');
  }

  static bool _isTeacherRoute(String location) {
    return location.startsWith('/teacher');
  }
}
