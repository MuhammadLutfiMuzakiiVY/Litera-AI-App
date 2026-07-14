# Navigation Flow

## 1. Router Choice

GoRouter dipakai untuk declarative routing, deep link readiness, dan guard berdasarkan session/profile/assessment state.

## 2. Route Map

| Route | Screen | Guard |
| --- | --- | --- |
| `/splash` | SplashScreen | None |
| `/onboarding` | OnboardingScreen | Guest only |
| `/auth/login` | LoginScreen | Guest only |
| `/auth/register` | RegisterScreen | Guest only |
| `/auth/verify-email` | VerifyEmailOtpScreen | Auth, email unverified |
| `/profile/complete` | CompleteProfileScreen | Auth, email verified |
| `/assessment/diagnostic` | DiagnosticAssessmentScreen | Student, profile complete |
| `/assessment/result` | DiagnosticResultScreen | Student, assessment submitted |
| `/student` | StudentShell | Student ready |
| `/student/dashboard` | StudentDashboardScreen | Student ready |
| `/student/learning-path` | LearningPathScreen | Student ready |
| `/student/modules/:moduleId` | ModuleDetailScreen | Student ready |
| `/student/quizzes/:moduleId/start` | QuizScreen | Student ready |
| `/student/history` | LearningHistoryScreen | Student ready |
| `/teacher` | TeacherShell | Teacher ready |
| `/teacher/dashboard` | TeacherDashboardScreen | Teacher ready |
| `/teacher/classes/:classroomId` | ClassroomProgressScreen | Teacher ready |
| `/teacher/students/:studentId` | StudentProgressDetailScreen | Teacher ready |
| `/settings` | SettingsScreen | Auth |

## 3. Route Guard Decision Tree

```mermaid
flowchart TD
  START["App Start"] --> SESSION{"Valid session?"}
  SESSION -->|No| ONBOARD{"Onboarding done?"}
  ONBOARD -->|No| ONBOARDING["/onboarding"]
  ONBOARD -->|Yes| LOGIN["/auth/login"]
  SESSION -->|Yes| EMAIL{"Email verified?"}
  EMAIL -->|No| OTP["/auth/verify-email"]
  EMAIL -->|Yes| PROFILE{"Profile complete?"}
  PROFILE -->|No| COMPLETE["/profile/complete"]
  PROFILE -->|Yes| ROLE{"Role"}
  ROLE -->|Student| DIAG{"Diagnostic done?"}
  DIAG -->|No| ASSESS["/assessment/diagnostic"]
  DIAG -->|Yes| STUDENT["/student/dashboard"]
  ROLE -->|Teacher| TEACHER["/teacher/dashboard"]
  ROLE -->|Admin| ADMIN["/admin"]
```

## 4. Main Student Flow

```mermaid
flowchart LR
  SPLASH["Splash"] --> ONBOARD["Onboarding"]
  ONBOARD --> AUTH["Login/Register"]
  AUTH --> OTP["Email OTP"]
  OTP --> PROFILE["Complete Profile"]
  PROFILE --> DIAG["Diagnostic Assessment"]
  DIAG --> RESULT["AI Profile Result"]
  RESULT --> PATH["Learning Path"]
  PATH --> MODULE["Adaptive Module"]
  MODULE --> QUIZ["Adaptive Quiz"]
  QUIZ --> EVAL["Evaluation"]
  EVAL --> DASH["Student Dashboard"]
  DASH --> HISTORY["History"]
  DASH --> SETTINGS["Settings"]
```

## 5. Main Teacher Flow

```mermaid
flowchart LR
  AUTH["Login/Register"] --> OTP["Email OTP"]
  OTP --> PROFILE["Teacher Profile"]
  PROFILE --> DASH["Teacher Dashboard"]
  DASH --> CLASS["Classroom Progress"]
  CLASS --> STUDENT["Student Detail"]
  STUDENT --> INTERVENTION["Recommended Intervention"]
  INTERVENTION --> MONITOR["Monitor Outcome"]
```

## 6. Navigation Shells

Student shell tabs:

- Dashboard.
- Learning Path.
- History.
- Settings.

Teacher shell tabs:

- Dashboard.
- Classes.
- Interventions.
- Settings.

## 7. Deep Links

Supported after MVP:

- `literaai://module/{moduleId}`
- `literaai://quiz/{moduleId}`
- `literaai://teacher/classroom/{classroomId}`
- `literaai://settings/notifications`

Deep link guard must redirect safely if user is not authorized.

## 8. Back Navigation Rules

- Splash cannot be returned to.
- Login/Register can switch freely.
- OTP back returns to login only after confirmation.
- Diagnostic assessment blocks accidental back with save/resume prompt.
- Quiz blocks accidental back with save/resume prompt.
- Dashboard root exits app on Android back after confirmation or double-back pattern.

## 9. Error Routes

- `/error/offline` optional full-screen fallback for first-load failure.
- `/error/forbidden` for RBAC violation.
- `/error/not-found` for missing resources.
- Inline errors preferred for recoverable list/detail failures.
