from datetime import datetime
from uuid import UUID

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, Numeric, String
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from app.infrastructure.db.base import Base, TimestampMixin, UuidPrimaryKeyMixin


class Question(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "questions"

    concept_id: Mapped[UUID] = mapped_column(ForeignKey("concepts.id"), index=True)
    question_type: Mapped[str] = mapped_column(String(32))
    difficulty: Mapped[str] = mapped_column(String(32), index=True)
    stem: Mapped[str] = mapped_column(String)
    metadata_json: Mapped[dict[str, object]] = mapped_column(JSONB, default=dict)


class QuestionOption(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "question_options"

    question_id: Mapped[UUID] = mapped_column(ForeignKey("questions.id"), index=True)
    label: Mapped[str] = mapped_column(String(8))
    body: Mapped[str] = mapped_column(String)
    is_correct: Mapped[bool] = mapped_column(Boolean, default=False)


class DiagnosticSession(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "diagnostic_sessions"

    student_id: Mapped[UUID] = mapped_column(ForeignKey("users.id"), index=True)
    status: Mapped[str] = mapped_column(String(32), index=True)
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    submitted_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class DiagnosticAnswer(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "diagnostic_answers"

    session_id: Mapped[UUID] = mapped_column(
        ForeignKey("diagnostic_sessions.id"),
        index=True,
    )
    question_id: Mapped[UUID] = mapped_column(ForeignKey("questions.id"))
    selected_option_id: Mapped[UUID] = mapped_column(ForeignKey("question_options.id"))
    response_time_ms: Mapped[int] = mapped_column(Integer)
    is_correct: Mapped[bool] = mapped_column(Boolean)
    idempotency_key: Mapped[str] = mapped_column(String(120), unique=True)


class DiagnosticResult(UuidPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "diagnostic_results"

    session_id: Mapped[UUID] = mapped_column(
        ForeignKey("diagnostic_sessions.id"),
        unique=True,
    )
    model_version: Mapped[str] = mapped_column(String(80))
    literacy_profile: Mapped[str] = mapped_column(String(80))
    numeracy_profile: Mapped[str] = mapped_column(String(80))
    confidence: Mapped[float] = mapped_column(Numeric(5, 4))
    feature_summary: Mapped[dict[str, object]] = mapped_column(JSONB, default=dict)
