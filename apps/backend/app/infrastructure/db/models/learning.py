from datetime import datetime
from uuid import UUID

from sqlalchemy import (
    Boolean,
    DateTime,
    ForeignKey,
    Integer,
    Numeric,
    String,
    UniqueConstraint,
)
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.infrastructure.db.base import Base, TimestampMixin, UuidPrimaryKeyMixin


class Concept(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "concepts"

    code: Mapped[str] = mapped_column(String(80), unique=True, index=True)
    domain: Mapped[str] = mapped_column(String(40), index=True)
    name: Mapped[str] = mapped_column(String(160))
    description: Mapped[str | None] = mapped_column(String)


class LearningModule(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "learning_modules"

    concept_id: Mapped[UUID] = mapped_column(ForeignKey("concepts.id"), index=True)
    title: Mapped[str] = mapped_column(String(180))
    difficulty: Mapped[str] = mapped_column(String(32), index=True)
    status: Mapped[str] = mapped_column(String(32), index=True)
    estimated_minutes: Mapped[int] = mapped_column(Integer)


class ModuleContent(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "module_contents"

    module_id: Mapped[UUID] = mapped_column(ForeignKey("learning_modules.id"))
    content_type: Mapped[str] = mapped_column(String(32))
    sort_order: Mapped[int] = mapped_column(Integer)
    body: Mapped[dict[str, object]] = mapped_column(JSONB)
    asset_url: Mapped[str | None] = mapped_column(String)


class LearningPath(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "learning_paths"

    student_id: Mapped[UUID] = mapped_column(ForeignKey("users.id"), index=True)
    diagnostic_result_id: Mapped[UUID | None] = mapped_column(
        ForeignKey("diagnostic_results.id"),
    )
    status: Mapped[str] = mapped_column(String(32), index=True)
    generated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class LearningPathItem(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "learning_path_items"
    __table_args__ = (
        UniqueConstraint("learning_path_id", "sort_order", name="uq_path_sort"),
    )

    learning_path_id: Mapped[UUID] = mapped_column(ForeignKey("learning_paths.id"))
    concept_id: Mapped[UUID] = mapped_column(ForeignKey("concepts.id"))
    module_id: Mapped[UUID] = mapped_column(ForeignKey("learning_modules.id"))
    sort_order: Mapped[int] = mapped_column(Integer)
    target_difficulty: Mapped[str] = mapped_column(String(32))
    status: Mapped[str] = mapped_column(String(32), index=True)


class QuizSession(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "quiz_sessions"

    student_id: Mapped[UUID] = mapped_column(ForeignKey("users.id"), index=True)
    module_id: Mapped[UUID] = mapped_column(ForeignKey("learning_modules.id"))
    difficulty: Mapped[str] = mapped_column(String(32))
    status: Mapped[str] = mapped_column(String(32), index=True)
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    submitted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class QuizAnswer(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "quiz_answers"

    quiz_session_id: Mapped[UUID] = mapped_column(ForeignKey("quiz_sessions.id"))
    question_id: Mapped[UUID] = mapped_column(ForeignKey("questions.id"))
    selected_option_id: Mapped[UUID] = mapped_column(ForeignKey("question_options.id"))
    response_time_ms: Mapped[int] = mapped_column(Integer)
    is_correct: Mapped[bool] = mapped_column(Boolean)
    idempotency_key: Mapped[str] = mapped_column(String(120), unique=True)


class LearningEvent(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "learning_events"

    student_id: Mapped[UUID] = mapped_column(ForeignKey("users.id"), index=True)
    concept_id: Mapped[UUID | None] = mapped_column(ForeignKey("concepts.id"))
    module_id: Mapped[UUID | None] = mapped_column(ForeignKey("learning_modules.id"))
    quiz_session_id: Mapped[UUID | None] = mapped_column(ForeignKey("quiz_sessions.id"))
    event_type: Mapped[str] = mapped_column(String(80), index=True)
    payload: Mapped[dict[str, object]] = mapped_column(JSONB, default=dict)
    occurred_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)
    idempotency_key: Mapped[str] = mapped_column(String(120), unique=True)


class ConceptMastery(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "concept_mastery"
    __table_args__ = (
        UniqueConstraint("student_id", "concept_id", name="uq_student_concept_mastery"),
    )

    student_id: Mapped[UUID] = mapped_column(ForeignKey("users.id"), index=True)
    concept_id: Mapped[UUID] = mapped_column(ForeignKey("concepts.id"), index=True)
    model_version: Mapped[str] = mapped_column(String(80))
    mastery_probability: Mapped[float] = mapped_column(Numeric(5, 4))
    confidence: Mapped[float] = mapped_column(Numeric(5, 4))


class DdaDecision(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "dda_decisions"

    student_id: Mapped[UUID] = mapped_column(ForeignKey("users.id"), index=True)
    concept_id: Mapped[UUID] = mapped_column(ForeignKey("concepts.id"), index=True)
    previous_difficulty: Mapped[str] = mapped_column(String(32))
    next_difficulty: Mapped[str] = mapped_column(String(32))
    reason_code: Mapped[str] = mapped_column(String(40), index=True)
    decision_context: Mapped[dict[str, object]] = mapped_column(JSONB, default=dict)
    decided_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)
