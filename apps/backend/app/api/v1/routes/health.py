from datetime import UTC, datetime

from fastapi import APIRouter

from app.api.v1.schemas.common import HealthResponse

router = APIRouter()


@router.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    return HealthResponse(status="ok", timestamp=datetime.now(tz=UTC))

