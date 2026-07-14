class RouteNames {
  const RouteNames._();

  static const splash = '/splash';
  static const introVideo = '/intro-video';
  static const onboarding = '/onboarding';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const verifyEmail = '/auth/verify-email';
  static const completeProfile = '/profile/complete';
  static const diagnostic = '/assessment/diagnostic';
  static const diagnosticResult = '/assessment/result';
  static const studentDashboard = '/student/dashboard';
  static const learningPath = '/student/learning-path';
  static const moduleDetail = '/student/modules/:moduleId';
  static const quiz = '/student/quizzes/:moduleId/start';
  static const learningHistory = '/student/history';
  static const teacherDashboard = '/teacher/dashboard';
  static const classroomProgress = '/teacher/classes/:classroomId';
  static const studentProgress = '/teacher/students/:studentId';
  static const search = '/student/search';
  static const aiProfile = '/student/profile/ai';
  static const bookmarks = '/student/bookmarks';
  static const notifications = '/student/notifications';
  static const settings = '/settings';
  static const helpCenter = '/settings/help';
}

