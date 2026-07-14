# LITERA-AI Mobile

Flutter mobile app for Android and iOS.

## First SDK Setup

This repository already contains the Dart source, routing, theme, and feature screens. If the `android/` and `ios/` folders are not present yet, generate platform scaffolding with Flutter:

```bash
cd apps/mobile
flutter create . --platforms=android,ios --org id.literaai
flutter pub get
flutter run
```

## Development

```bash
flutter analyze
flutter test
```

## Implemented Mobile Scope

- App shell with Material 3 theme, dark mode, GoRouter, and Riverpod.
- Onboarding, login, register, email OTP, profile completion, logout.
- Diagnostic assessment with loading, error, retry, answer selection, submit, and result routing.
- Student dashboard, learning path, adaptive module, adaptive quiz, evaluation, and history.
- Teacher dashboard, classroom progress, student detail, and intervention recommendation.
- Auth, diagnostic, learning, quiz, and teacher feature layers with domain entities, repositories, remote datasources, mock datasources, and providers.
- Secure token store, Dio API client, sync service, analytics/crash/notification service abstractions.

## Unified Mobile Folder

All Flutter mobile source is intentionally unified under this folder:

```text
apps/mobile/
  lib/
  assets/
  test/
  pubspec.yaml
```

Backend and AI code stay outside this Flutter project because they run as services, not as mobile source. This keeps Android/iOS generation clean when `flutter create .` is executed inside `apps/mobile`.

## Offline and Online Mode

The app supports both modes at source level:

- `Settings > Mode Offline` toggles offline/online behavior.
- `NetworkStatusBanner` appears when offline or when there are pending sync events.
- Diagnostic answers and quiz answers are saved to a persistent Hive-backed outbox queue when offline.
- Learning path and module detail are cached in Hive after successful online loads.
- Offline diagnostic and quiz results are generated locally as temporary results.
- When online, pending events can be synchronized through the Sync button.
- Remote datasources are already wired for FastAPI when `ENABLE_MOCK_AUTH=false`.

## Pending SDK-Dependent Steps

These require a local Flutter SDK:

```bash
flutter create . --platforms=android,ios --org id.literaai
flutter pub get
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/v1
```

## Environment

Use `--dart-define` to point to the backend:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/v1
```
