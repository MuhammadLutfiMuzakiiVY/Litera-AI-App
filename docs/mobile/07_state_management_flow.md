# State Management Flow

## 1. State Management Choice

LITERA-AI memakai Riverpod sebagai dependency injection dan state management utama. Pola default:

- `Provider` untuk dependency stateless.
- `FutureProvider` untuk read-only async data ringan.
- `StreamProvider` untuk WebSocket/live progress.
- `AsyncNotifier` untuk screen-level orchestration.
- `StateNotifier` hanya jika butuh state machine kompleks.

## 2. State Layers

```mermaid
flowchart TB
  SCREEN["Screen / Widget"]
  CONTROLLER["Riverpod Controller\nAsyncNotifier"]
  USECASE["Application Use Case"]
  REPO["Domain Repository Contract"]
  IMPL["Data Repository Impl"]
  LOCAL["Local Datasource\nIsar/Hive"]
  REMOTE["Remote Datasource\nDio"]
  SYNC["Sync Service\nOutbox"]

  SCREEN --> CONTROLLER
  CONTROLLER --> USECASE
  USECASE --> REPO
  REPO --> IMPL
  IMPL --> LOCAL
  IMPL --> REMOTE
  IMPL --> SYNC
  LOCAL --> CONTROLLER
```

## 3. Async State Standard

Setiap screen async harus memetakan state berikut:

| State | UI Behavior |
| --- | --- |
| Loading | Skeleton atau progress indicator ringan. |
| Empty | Pesan empty spesifik dan aksi utama. |
| Data | Render data dengan pagination/lazy loading. |
| Error recoverable | Error message, retry button, logging. |
| Error auth | Route ke login atau refresh token flow. |
| Offline | Badge offline, local data, queued action indicator. |

## 4. Global App State

| State | Source | Consumer |
| --- | --- | --- |
| SessionState | Secure token store + `/me` | Route guards, auth interceptor. |
| OnboardingState | Hive app flags | Route guard. |
| ProfileCompletionState | `/me` + local projection | Route guard. |
| ConnectivityState | Connectivity observer | Sync, offline banner. |
| ThemeState | Hive settings | App theme. |
| NotificationPermissionState | OS permission + FCM | Settings, onboarding reminder. |

## 5. Auth State Machine

```mermaid
stateDiagram-v2
  [*] --> Unknown
  Unknown --> Guest: no token
  Unknown --> Authenticated: valid token
  Unknown --> Refreshing: expired access token
  Refreshing --> Authenticated: refresh success
  Refreshing --> Guest: refresh failed
  Guest --> Registering
  Guest --> LoggingIn
  Registering --> EmailUnverified
  LoggingIn --> EmailUnverified: email not verified
  LoggingIn --> ProfileIncomplete: profile missing
  LoggingIn --> Ready: valid user
  EmailUnverified --> ProfileIncomplete: OTP verified
  ProfileIncomplete --> NeedsDiagnostic: student profile completed
  ProfileIncomplete --> Ready: teacher profile completed
  NeedsDiagnostic --> Ready: assessment submitted
  Ready --> Guest: logout
```

## 6. Diagnostic Assessment State

```mermaid
stateDiagram-v2
  [*] --> Idle
  Idle --> LoadingSession
  LoadingSession --> InProgress
  InProgress --> SavingAnswer
  SavingAnswer --> InProgress
  InProgress --> OfflineQueued: no connection
  OfflineQueued --> Syncing: connection restored
  Syncing --> InProgress
  InProgress --> Submitting
  Submitting --> Evaluating
  Evaluating --> ResultReady
  Submitting --> SubmitFailed
  SubmitFailed --> InProgress: retry
```

## 7. Offline Sync State

```mermaid
flowchart LR
  ACTION["User Action"] --> VALIDATE["Validate Locally"]
  VALIDATE --> LOCAL_WRITE["Write Local Projection"]
  LOCAL_WRITE --> OUTBOX["Append Outbox Event"]
  OUTBOX --> TRY_SYNC{"Online?"}
  TRY_SYNC -->|Yes| PUSH["Push to /sync/push"]
  TRY_SYNC -->|No| WAIT["Wait Connectivity"]
  WAIT --> PUSH
  PUSH --> ACK{"Accepted?"}
  ACK -->|Yes| MARK["Mark Synced"]
  ACK -->|No| CONFLICT["Resolve Conflict / Show Retry"]
  MARK --> PULL["Pull Server Delta"]
  PULL --> UPDATE["Update Local Projection"]
```

## 8. Provider Organization

Provider per feature:

- `authRepositoryProvider`
- `loginUserProvider`
- `authControllerProvider`
- `diagnosticRepositoryProvider`
- `diagnosticControllerProvider`
- `learningPathControllerProvider`
- `teacherDashboardControllerProvider`

Cross-cutting providers:

- `dioProvider`
- `secureTokenStoreProvider`
- `isarProvider`
- `hiveProvider`
- `syncServiceProvider`
- `analyticsServiceProvider`
- `crashReporterProvider`
- `connectivityProvider`

## 9. Rebuild Rules

- Gunakan `select` untuk field kecil yang sering berubah.
- Hindari provider global untuk data screen yang tidak perlu global.
- Dispose controller otomatis dengan `autoDispose` untuk screen transient.
- Keep-alive hanya untuk session, theme, config, router, dan cache penting.
- Parsing JSON besar dijalankan di isolate jika mengganggu frame time.

## 10. Error Handling Flow

1. Datasource menangkap error teknis.
2. Repository memetakan error ke `Failure`.
3. Use case menentukan apakah error bisa di-retry.
4. Controller mengubah state menjadi `AsyncError` atau custom view state.
5. UI menampilkan pesan manusiawi dan aksi retry.
6. Logger mencatat error dengan request id, tanpa PII.

## 11. Analytics Events

Event state penting:

- `auth_login_success`
- `profile_completed`
- `diagnostic_started`
- `diagnostic_submitted`
- `learning_path_generated`
- `module_opened`
- `quiz_submitted`
- `dda_decision_applied`
- `teacher_dashboard_opened`
- `offline_sync_completed`
