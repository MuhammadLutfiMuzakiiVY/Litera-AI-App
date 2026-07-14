# LITERA-AI

LITERA-AI (Literacy Intelligent Assistant) is an adaptive learning mobile application for Android and iOS. It combines Flutter, FastAPI, PostgreSQL, Redis, and predictive AI models for diagnostic assessment, knowledge tracing, and dynamic difficulty adjustment.

## Workspace

```text
apps/
  mobile/   Flutter application
  backend/  FastAPI backend
  ai/       AI inference/training package
docs/       Design and planning artifacts
infra/      Docker, Nginx, CI/CD support
```

For mobile development, open only `apps/mobile` as the Flutter project. The mobile app files are unified there: `lib`, `assets`, `test`, and `pubspec.yaml`.

## Current Status

The workspace now contains a production-oriented starter implementation:

- Mobile app shell, Material 3 theme, dark mode, GoRouter, and Riverpod state flow.
- Auth, onboarding, profile completion, diagnostic assessment, adaptive learning, adaptive quiz, history, settings, and teacher monitoring screens.
- Offline/online mobile mode with Hive cache, persistent outbox queue, sync banner, and manual sync action.
- FastAPI backend skeleton with versioned REST routes, mock store, SQLAlchemy models, Alembic migration, and sync endpoints.
- AI inference package for diagnostic classification, knowledge tracing, and DDA decision logic.
- Docker, Nginx, CI workflow, and design/planning documentation.

## Local Development

Flutter SDK is required to run the mobile app:

```bash
cd apps/mobile
flutter pub get
flutter run
```

Python/FastAPI dependencies are required to run the backend:

```bash
cd apps/backend
python -m venv .venv
pip install -e ".[dev]"
uvicorn app.main:app --reload
```
