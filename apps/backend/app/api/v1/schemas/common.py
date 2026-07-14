from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field


class ErrorResponse(BaseModel):
    code: str
    message: str
    request_id: str | None = None
    details: dict[str, object] = Field(default_factory=dict)


class HealthResponse(BaseModel):
    status: str
    timestamp: datetime


class QuestionOption(BaseModel):
    id: UUID
    label: str
    body: str


class Question(BaseModel):
    id: UUID
    concept_id: UUID
    difficulty: str
    stem: str
    options: list[QuestionOption]


class AnswerRequest(BaseModel):
    question_id: UUID
    selected_option_id: UUID
    response_time_ms: int = Field(ge=0)
    idempotency_key: str = Field(min_length=8)

