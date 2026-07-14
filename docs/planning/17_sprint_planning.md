# Sprint Planning

## 1. Delivery Model

Method: ADDIE integrated with Agile.

- Analysis: proposal, SRS, PRD, risks, success metrics.
- Design: architecture, database, API, UI/UX, AI workflow.
- Development: iterative feature sprints.
- Implementation: pilot testing in controlled class/school.
- Evaluation: technical, usability, pedagogical, AI metrics.

Sprint length: 1 week for competition prototype, 2 weeks for production continuation.

## 2. Milestones

| Milestone | Outcome |
| --- | --- |
| M0 Design Approval | All planning artifacts reviewed. |
| M1 App Foundation | Flutter shell, backend shell, CI, lint, env config. |
| M2 Auth/Profile | Register, login, OTP, profile completion. |
| M3 Diagnostic | Assessment engine and 1D-CNN integration stub. |
| M4 Learning Path | Learning path, module reader, local cache. |
| M5 Quiz/DDA | Quiz, evaluation, DDA v1. |
| M6 Teacher Dashboard | Classroom progress and interventions. |
| M7 AI Hardening | Model training/evaluation, TFLite option, audit logs. |
| M8 Pilot Readiness | Offline sync, security hardening, QA, demo assets. |

## 3. Sprint 0 - Design and Setup

Goals:

- Approve docs.
- Choose version pins.
- Create repository and branch policy.
- Configure secrets strategy.

Deliverables:

- Final docs in `docs/`.
- Initial GitHub repo.
- Issue tracker/backlog.
- Definition of Done.

## 4. Sprint 1 - Foundation

Scope:

- Scaffold Flutter app with Very Good CLI style.
- Scaffold FastAPI backend.
- Configure lint, formatting, env config.
- Add app theme, router shell, dependency providers.
- Add Docker compose for backend dependencies.
- Add GitHub Actions for lint/test.

Acceptance:

- App runs on Android/iOS simulator.
- Backend health endpoint works.
- CI passes lint and unit tests.

## 5. Sprint 2 - Auth and Profile

Scope:

- Register/login.
- OTP verification.
- Refresh token flow.
- Secure storage.
- Profile completion.
- Route guards.

Acceptance:

- User can complete auth flow.
- Tokens refresh automatically.
- Logout revokes session.
- Loading/error/empty states covered.

## 6. Sprint 3 - Diagnostic Assessment

Scope:

- Question bank schema and seed.
- Start/resume diagnostic session.
- Save answers with idempotency.
- Submit diagnostic.
- AI classifier interface with mock then real model.

Acceptance:

- Student completes assessment.
- Result saved with model version/confidence.
- Learning path generated.

## 7. Sprint 4 - Adaptive Learning

Scope:

- Learning path screen.
- Module detail.
- Content rendering.
- Cached images.
- Module progress.
- Offline content cache.

Acceptance:

- Student opens recommended module.
- Progress persists locally and remotely.
- Offline cached module opens.

## 8. Sprint 5 - Quiz, DKT, and DDA

Scope:

- Adaptive quiz session.
- Answer save/submit.
- Evaluation result.
- LSTM-DKT service interface.
- DDA v1 rule engine.

Acceptance:

- Quiz updates mastery.
- DDA returns next difficulty with rationale.
- Dashboard reflects update.

## 9. Sprint 6 - Teacher Dashboard

Scope:

- Classroom list.
- Progress aggregate.
- Student detail.
- Risk flag.
- Intervention recommendation panel.
- WebSocket or polling refresh.

Acceptance:

- Teacher sees priority students.
- Teacher can inspect rationale.
- Empty/error states work.

## 10. Sprint 7 - Offline Sync and Notifications

Scope:

- Outbox queue.
- Sync pull/push.
- Conflict policy.
- FCM device registration.
- Local reminders.

Acceptance:

- Offline learning event syncs after reconnect.
- Failed events can retry.
- Notification permission flow works.

## 11. Sprint 8 - Hardening and Pilot

Scope:

- Security audit.
- Performance profiling.
- Accessibility pass.
- Crashlytics and analytics validation.
- Model evaluation report.
- Demo screenshots/video support.

Acceptance:

- No critical/high security issues.
- Startup p95 target measured.
- Crash-free pilot build ready.

## 12. Definition of Done

For every feature:

- Code follows Clean Architecture.
- Unit tests for use case and mapper.
- Widget tests for important states.
- API contract tests for backend endpoint.
- Loading, empty, error, retry states implemented.
- Logs and analytics added without PII.
- Accessibility labels for interactive UI.
- Documentation updated.

## 13. Backlog Priority

P0:

- Auth, profile, assessment, learning path, module, quiz, DDA, teacher dashboard.

P1:

- Offline sync, notifications, TFLite edge inference, analytics.

P2:

- Admin tools, advanced reports, model A/B testing.
