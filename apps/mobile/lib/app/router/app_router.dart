import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:litera_ai_mobile/app/router/route_guards.dart';
import 'package:litera_ai_mobile/app/router/route_names.dart';
import 'package:litera_ai_mobile/features/adaptive_module/presentation/screens/module_detail_screen.dart';
import 'package:litera_ai_mobile/features/adaptive_quiz/presentation/screens/quiz_screen.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_controller.dart';
import 'package:litera_ai_mobile/features/auth/application/auth_state.dart';
import 'package:litera_ai_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:litera_ai_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:litera_ai_mobile/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/presentation/screens/diagnostic_assessment_screen.dart';
import 'package:litera_ai_mobile/features/diagnostic_assessment/presentation/screens/diagnostic_result_screen.dart';
import 'package:litera_ai_mobile/features/learning_history/presentation/screens/learning_history_screen.dart';
import 'package:litera_ai_mobile/features/learning_path/presentation/screens/learning_path_screen.dart';
import 'package:litera_ai_mobile/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:litera_ai_mobile/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:litera_ai_mobile/features/onboarding/presentation/screens/intro_video_screen.dart';
import 'package:litera_ai_mobile/features/profile/presentation/screens/complete_profile_screen.dart';
import 'package:litera_ai_mobile/features/settings/presentation/screens/settings_screen.dart';
import 'package:litera_ai_mobile/features/settings/presentation/screens/help_center_screen.dart';
import 'package:litera_ai_mobile/features/profile/presentation/screens/ai_profile_screen.dart';
import 'package:litera_ai_mobile/features/profile/presentation/screens/bookmarks_screen.dart';
import 'package:litera_ai_mobile/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:litera_ai_mobile/features/search/presentation/screens/search_screen.dart';
import 'package:litera_ai_mobile/features/student_dashboard/presentation/screens/student_dashboard_screen.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/presentation/screens/classroom_progress_screen.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/presentation/screens/student_progress_detail_screen.dart';
import 'package:litera_ai_mobile/features/teacher_dashboard/presentation/screens/teacher_dashboard_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: _RouterRefreshNotifier(ref),
    redirect: (context, state) {
      return AppRouteGuard.redirect(auth, state.uri.path);
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.introVideo,
        builder: (context, state) => const IntroVideoScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.verifyEmail,
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: RouteNames.completeProfile,
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.diagnostic,
        builder: (context, state) => const DiagnosticAssessmentScreen(),
      ),
      GoRoute(
        path: RouteNames.diagnosticResult,
        builder: (context, state) => const DiagnosticResultScreen(),
      ),
      GoRoute(
        path: RouteNames.studentDashboard,
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.learningPath,
        builder: (context, state) => const LearningPathScreen(),
      ),
      GoRoute(
        path: RouteNames.moduleDetail,
        builder: (context, state) {
          return ModuleDetailScreen(
            moduleId: state.pathParameters['moduleId'] ?? 'demo-module',
          );
        },
      ),
      GoRoute(
        path: RouteNames.quiz,
        builder: (context, state) {
          return QuizScreen(
            moduleId: state.pathParameters['moduleId'] ?? 'demo-module',
          );
        },
      ),
      GoRoute(
        path: RouteNames.learningHistory,
        builder: (context, state) => const LearningHistoryScreen(),
      ),
      GoRoute(
        path: RouteNames.teacherDashboard,
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: RouteNames.classroomProgress,
        builder: (context, state) {
          return ClassroomProgressScreen(
            classroomId: state.pathParameters['classroomId'] ?? 'demo-class',
          );
        },
      ),
      GoRoute(
        path: RouteNames.studentProgress,
        builder: (context, state) {
          return StudentProgressDetailScreen(
            studentId: state.pathParameters['studentId'] ?? 'demo-student',
          );
        },
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: RouteNames.aiProfile,
        builder: (context, state) => const AiProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: RouteNames.bookmarks,
        builder: (context, state) => const BookmarksScreen(),
      ),
      GoRoute(
        path: RouteNames.helpCenter,
        builder: (context, state) => const HelpCenterScreen(),
      ),
    ],
  );
});



class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(this.ref) {
    ref.listen<AuthState>(
      authControllerProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref ref;
}
