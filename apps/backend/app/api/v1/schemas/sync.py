from datetime import datetime

from pydantic import BaseModel, Field


class SyncEvent(BaseModel):
    idempotency_key: str = Field(min_length=8)
    event_type: str
    payload: dict[str, object]
    occurred_at: datetime


class SyncPullResponse(BaseModel):
    checkpoint: datetime
    changes: list[dict[str, object]]


class SyncPushRequest(BaseModel):
    events: list[SyncEvent]


class SyncPushResponse(BaseModel):
    accepted: list[str]
    rejected: list[dict[str, object]]


class DeviceTokenRequest(BaseModel):
    token: str
    platform: str
    app_version: str | None = None

