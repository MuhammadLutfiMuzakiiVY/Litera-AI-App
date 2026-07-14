from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field

from app.api.v1.schemas.common import Question


class AiProfile(BaseModel):
    literacy_profile: str
    numeracy_profile: str
    confidence: float = Field(ge=0, le=1)
    model_version: str
    generated_at: datetime


class DiagnosticSession(BaseModel):
    id: UUID
    status: str
    questions: list[Question]


class LearningPathItem(BaseModel):
    id: UUID
    concept_id: UUID
    module_id: UUID
    title: str
    target_difficulty: str
    status: str


class LearningPath(BaseModel):
    id: UUID
    status: str
    items: list[LearningPathItem]


class DiagnosticSubmitResponse(BaseModel):
    result: AiProfile
    learning_path: LearningPath


class ModuleSummary(BaseModel):
    id: UUID
    title: str
    difficulty: str
    estimated_minutes: int


class ModuleContent(BaseModel):
    id: UUID
    content_type: str
    sort_order: int
    body: dict[str, object]
    asset_url: str | None = None


class ModuleDetail(ModuleSummary):
    contents: list[ModuleContent]


class ModulePage(BaseModel):
    items: list[ModuleSummary]
    page: int
    page_size: int
    total: int


class ModuleProgressRequest(BaseModel):
    status: str
    progress_percent: int = Field(ge=0, le=100)
    idempotency_key: str = Field(min_length=8)


class ModuleProgress(BaseModel):
    module_id: UUID
    status: str
    progress_percent: int


class StartQuizRequest(BaseModel):
    module_id: UUID


class QuizSession(BaseModel):
    id: UUID
    module_id: UUID
    difficulty: str
    questions: list[Question]


class ConceptMastery(BaseModel):
    concept_id: UUID
    mastery_probability: float = Field(ge=0, le=1)
    confidence: float = Field(ge=0, le=1)


class DdaDecision(BaseModel):
    previous_difficulty: str
    next_difficulty: str
    reason_code: str
    explanation: str


class QuizSubmitResponse(BaseModel):
    score: float
    mastery: list[ConceptMastery]
    dda_decision: DdaDecision

