# LITERA-AI Backend

FastAPI backend for authentication, diagnostic assessment, adaptive learning, quiz, teacher dashboard, sync, and notification devices.

## Run Locally

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e ".[dev]"
uvicorn app.main:app --reload
```

On Windows PowerShell:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -e ".[dev]"
uvicorn app.main:app --reload
```

## Docker

```bash
docker compose -f ../../infra/docker/docker-compose.yml up --build
```

## Migrations

```bash
alembic upgrade head
alembic revision --autogenerate -m "describe change"
```

## Current Implementation

Sprint 1 uses an in-memory `MockStore` for API integration. SQLAlchemy models and the initial Alembic schema are already present so repository-backed persistence can replace the mock service in the next sprint.

