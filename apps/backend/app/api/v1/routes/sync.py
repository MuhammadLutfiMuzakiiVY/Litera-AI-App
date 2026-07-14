from datetime import UTC, datetime

from fastapi import APIRouter, Depends

from app.api.v1.schemas.sync import (
    SyncPullResponse,
    SyncPushRequest,
    SyncPushResponse,
)
from app.core.security import get_current_user_id
from app.services.mock_store import mock_store

router = APIRouter()


@router.get("/pull", response_model=SyncPullResponse)
def pull(
    since: datetime | None = None,
    user_id: str = Depends(get_current_user_id),
) -> SyncPullResponse:
    _ = since, user_id
    return SyncPullResponse(checkpoint=datetime.now(tz=UTC), changes=[])


@router.post("/push", response_model=SyncPushResponse)
def push(
    payload: SyncPushRequest,
    user_id: str = Depends(get_current_user_id),
) -> SyncPushResponse:
    _ = user_id
    accepted = mock_store.accept_sync_events(
        [event.idempotency_key for event in payload.events],
    )
    return SyncPushResponse(accepted=accepted, rejected=[])

