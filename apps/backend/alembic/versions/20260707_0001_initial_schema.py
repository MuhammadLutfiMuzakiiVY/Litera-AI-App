"""Initial LITERA-AI schema.

Revision ID: 20260707_0001
Revises:
Create Date: 2026-07-07
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "20260707_0001"
down_revision: str | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def _timestamps() -> list[sa.Column]:
    return [
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
    ]


def _uuid_pk() -> sa.Column:
    return sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True)


def upgrade() -> None:
    op.create_table(
        "users",
        _uuid_pk(),
        sa.Column("email", sa.String(length=320), nullable=False),
        sa.Column("password_hash", sa.String(length=255), nullable=False),
        sa.Column("role", sa.String(length=32), nullable=False),
        sa.Column("full_name", sa.String(length=160), nullable=True),
        sa.Column("email_verified", sa.Boolean(), nullable=False),
        sa.Column("profile_completed", sa.Boolean(), nullable=False),
        *_timestamps(),
        sa.UniqueConstraint("email"),
    )
    op.create_index("ix_users_email", "users", ["email"])
    op.create_index("ix_users_role", "users", ["role"])

    op.create_table(
        "schools",
        _uuid_pk(),
        sa.Column("name", sa.String(length=180), nullable=False),
        sa.Column("city", sa.String(length=120), nullable=True),
        sa.Column("province", sa.String(length=120), nullable=True),
        *_timestamps(),
    )
    op.create_index("ix_schools_name", "schools", ["name"])

    op.create_table(
        "concepts",
        _uuid_pk(),
        sa.Column("code", sa.String(length=80), nullable=False),
        sa.Column("domain", sa.String(length=40), nullable=False),
        sa.Column("name", sa.String(length=160), nullable=False),
        sa.Column("description", sa.String(), nullable=True),
        *_timestamps(),
        sa.UniqueConstraint("code"),
    )
    op.create_index("ix_concepts_code", "concepts", ["code"])
    op.create_index("ix_concepts_domain", "concepts", ["domain"])

    op.create_table(
        "classrooms",
        _uuid_pk(),
        sa.Column("school_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("name", sa.String(length=120), nullable=False),
        sa.Column("academic_year", sa.String(length=16), nullable=False),
        sa.Column("created_by", postgresql.UUID(as_uuid=True), nullable=True),
        *_timestamps(),
        sa.ForeignKeyConstraint(["school_id"], ["schools.id"]),
        sa.ForeignKeyConstraint(["created_by"], ["users.id"]),
    )

    op.create_table(
        "student_profiles",
        _uuid_pk(),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("school_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("grade_level", sa.String(length=32), nullable=False),
        sa.Column("learning_preference", sa.String(length=32), nullable=True),
        *_timestamps(),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["school_id"], ["schools.id"]),
        sa.UniqueConstraint("user_id"),
    )

    op.create_table(
        "teacher_profiles",
        _uuid_pk(),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("school_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("subject_area", sa.String(length=64), nullable=False),
        *_timestamps(),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["school_id"], ["schools.id"]),
        sa.UniqueConstraint("user_id"),
    )

    op.create_table(
        "classroom_members",
        _uuid_pk(),
        sa.Column("classroom_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("user_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("member_role", sa.String(length=32), nullable=False),
        *_timestamps(),
        sa.ForeignKeyConstraint(["classroom_id"], ["classrooms.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.UniqueConstraint("classroom_id", "user_id", name="uq_classroom_user"),
    )

    op.create_table(
        "learning_modules",
        _uuid_pk(),
        sa.Column("concept_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("title", sa.String(length=180), nullable=False),
        sa.Column("difficulty", sa.String(length=32), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False),
        sa.Column("estimated_minutes", sa.Integer(), nullable=False),
        *_timestamps(),
        sa.ForeignKeyConstraint(["concept_id"], ["concepts.id"]),
    )
    op.create_index("ix_learning_modules_concept_id", "learning_modules", ["concept_id"])
    op.create_index("ix_learning_modules_difficulty", "learning_modules", ["difficulty"])
    op.create_index("ix_learning_modules_status", "learning_modules", ["status"])

    op.create_table(
        "questions",
        _uuid_pk(),
        sa.Column("concept_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("question_type", sa.String(length=32), nullable=False),
        sa.Column("difficulty", sa.String(length=32), nullable=False),
        sa.Column("stem", sa.String(), nullable=False),
        sa.Column("metadata_json", postgresql.JSONB(), nullable=False),
        *_timestamps(),
        sa.ForeignKeyConstraint(["concept_id"], ["concepts.id"]),
    )
    op.create_index("ix_questions_concept_id", "questions", ["concept_id"])
    op.create_index("ix_questions_difficulty", "questions", ["difficulty"])

    op.create_table(
        "module_contents",
        _uuid_pk(),
        sa.Column("module_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("content_type", sa.String(length=32), nullable=False),
        sa.Column("sort_order", sa.Integer(), nullable=False),
        sa.Column("body", postgresql.JSONB(), nullable=False),
        sa.Column("asset_url", sa.String(), nullable=True),
        *_timestamps(),
        sa.ForeignKeyConstraint(["module_id"], ["learning_modules.id"]),
    )

    op.create_table(
        "question_options",
        _uuid_pk(),
        sa.Column("question_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("label", sa.String(length=8), nullable=False),
        sa.Column("body", sa.String(), nullable=False),
        sa.Column("is_correct", sa.Boolean(), nullable=False),
        *_timestamps(),
        sa.ForeignKeyConstraint(["question_id"], ["questions.id"]),
    )
    op.create_index("ix_question_options_question_id", "question_options", ["question_id"])

    op.create_table(
        "diagnostic_sessions",
        _uuid_pk(),
        sa.Column("student_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("submitted_at", sa.DateTime(timezone=True), nullable=True),
        *_timestamps(),
        sa.ForeignKeyConstraint(["student_id"], ["users.id"]),
    )
    op.create_index("ix_diagnostic_sessions_status", "diagnostic_sessions", ["status"])
    op.create_index(
        "ix_diagnostic_sessions_student_id",
        "diagnostic_sessions",
        ["student_id"],
    )

    op.create_table(
        "diagnostic_answers",
        _uuid_pk(),
        sa.Column("session_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("question_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("selected_option_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("response_time_ms", sa.Integer(), nullable=False),
        sa.Column("is_correct", sa.Boolean(), nullable=False),
        sa.Column("idempotency_key", sa.String(length=120), nullable=False),
        *_timestamps(),
        sa.ForeignKeyConstraint(["session_id"], ["diagnostic_sessions.id"]),
        sa.ForeignKeyConstraint(["question_id"], ["questions.id"]),
        sa.ForeignKeyConstraint(["selected_option_id"], ["question_options.id"]),
        sa.UniqueConstraint("idempotency_key"),
    )
    op.create_index("ix_diagnostic_answers_session_id", "diagnostic_answers", ["session_id"])

    op.create_table(
        "diagnostic_results",
        _uuid_pk(),
        sa.Column("session_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("model_version", sa.String(length=80), nullable=False),
        sa.Column("literacy_profile", sa.String(length=80), nullable=False),
        sa.Column("numeracy_profile", sa.String(length=80), nullable=False),
        sa.Column("confidence", sa.Numeric(5, 4), nullable=False),
        sa.Column("feature_summary", postgresql.JSONB(), nullable=False),
        *_timestamps(),
        sa.ForeignKeyConstraint(["session_id"], ["diagnostic_sessions.id"]),
        sa.UniqueConstraint("session_id"),
    )

    op.create_table(
        "learning_paths",
        _uuid_pk(),
        sa.Column("student_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("diagnostic_result_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("status", sa.String(length=32), nullable=False),
        sa.Column("generated_at", sa.DateTime(timezone=True), nullable=False),
        *_timestamps(),
        sa.ForeignKeyConstraint(["student_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["diagnostic_result_id"], ["diagnostic_results.id"]),
    )
    op.create_index("ix_learning_paths_status", "learning_paths", ["status"])
    op.create_index("ix_learning_paths_student_id", "learning_paths", ["student_id"])

    op.create_table(
        "learning_path_items",
        _uuid_pk(),
        sa.Column("learning_path_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("concept_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("module_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("sort_order", sa.Integer(), nullable=False),
        sa.Column("target_difficulty", sa.String(length=32), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False),
        *_timestamps(),
        sa.ForeignKeyConstraint(["learning_path_id"], ["learning_paths.id"]),
        sa.ForeignKeyConstraint(["concept_id"], ["concepts.id"]),
        sa.ForeignKeyConstraint(["module_id"], ["learning_modules.id"]),
        sa.UniqueConstraint("learning_path_id", "sort_order", name="uq_path_sort"),
    )
    op.create_index("ix_learning_path_items_status", "learning_path_items", ["status"])

    op.create_table(
        "quiz_sessions",
        _uuid_pk(),
        sa.Column("student_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("module_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("difficulty", sa.String(length=32), nullable=False),
        sa.Column("status", sa.String(length=32), nullable=False),
        sa.Column("started_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("submitted_at", sa.DateTime(timezone=True), nullable=True),
        *_timestamps(),
        sa.ForeignKeyConstraint(["student_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["module_id"], ["learning_modules.id"]),
    )
    op.create_index("ix_quiz_sessions_status", "quiz_sessions", ["status"])
    op.create_index("ix_quiz_sessions_student_id", "quiz_sessions", ["student_id"])

    op.create_table(
        "quiz_answers",
        _uuid_pk(),
        sa.Column("quiz_session_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("question_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("selected_option_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("response_time_ms", sa.Integer(), nullable=False),
        sa.Column("is_correct", sa.Boolean(), nullable=False),
        sa.Column("idempotency_key", sa.String(length=120), nullable=False),
        *_timestamps(),
        sa.ForeignKeyConstraint(["quiz_session_id"], ["quiz_sessions.id"]),
        sa.ForeignKeyConstraint(["question_id"], ["questions.id"]),
        sa.ForeignKeyConstraint(["selected_option_id"], ["question_options.id"]),
        sa.UniqueConstraint("idempotency_key"),
    )

    op.create_table(
        "learning_events",
        _uuid_pk(),
        sa.Column("student_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("concept_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("module_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("quiz_session_id", postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column("event_type", sa.String(length=80), nullable=False),
        sa.Column("payload", postgresql.JSONB(), nullable=False),
        sa.Column("occurred_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("idempotency_key", sa.String(length=120), nullable=False),
        *_timestamps(),
        sa.ForeignKeyConstraint(["student_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["concept_id"], ["concepts.id"]),
        sa.ForeignKeyConstraint(["module_id"], ["learning_modules.id"]),
        sa.ForeignKeyConstraint(["quiz_session_id"], ["quiz_sessions.id"]),
        sa.UniqueConstraint("idempotency_key"),
    )
    op.create_index("ix_learning_events_event_type", "learning_events", ["event_type"])
    op.create_index("ix_learning_events_occurred_at", "learning_events", ["occurred_at"])
    op.create_index("ix_learning_events_student_id", "learning_events", ["student_id"])

    op.create_table(
        "concept_mastery",
        _uuid_pk(),
        sa.Column("student_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("concept_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("model_version", sa.String(length=80), nullable=False),
        sa.Column("mastery_probability", sa.Numeric(5, 4), nullable=False),
        sa.Column("confidence", sa.Numeric(5, 4), nullable=False),
        *_timestamps(),
        sa.ForeignKeyConstraint(["student_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["concept_id"], ["concepts.id"]),
        sa.UniqueConstraint(
            "student_id",
            "concept_id",
            name="uq_student_concept_mastery",
        ),
    )
    op.create_index("ix_concept_mastery_concept_id", "concept_mastery", ["concept_id"])
    op.create_index("ix_concept_mastery_student_id", "concept_mastery", ["student_id"])

    op.create_table(
        "dda_decisions",
        _uuid_pk(),
        sa.Column("student_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("concept_id", postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column("previous_difficulty", sa.String(length=32), nullable=False),
        sa.Column("next_difficulty", sa.String(length=32), nullable=False),
        sa.Column("reason_code", sa.String(length=40), nullable=False),
        sa.Column("decision_context", postgresql.JSONB(), nullable=False),
        sa.Column("decided_at", sa.DateTime(timezone=True), nullable=False),
        *_timestamps(),
        sa.ForeignKeyConstraint(["student_id"], ["users.id"]),
        sa.ForeignKeyConstraint(["concept_id"], ["concepts.id"]),
    )
    op.create_index("ix_dda_decisions_concept_id", "dda_decisions", ["concept_id"])
    op.create_index("ix_dda_decisions_decided_at", "dda_decisions", ["decided_at"])
    op.create_index("ix_dda_decisions_reason_code", "dda_decisions", ["reason_code"])
    op.create_index("ix_dda_decisions_student_id", "dda_decisions", ["student_id"])


def downgrade() -> None:
    for table_name in [
        "dda_decisions",
        "concept_mastery",
        "learning_events",
        "quiz_answers",
        "quiz_sessions",
        "learning_path_items",
        "learning_paths",
        "diagnostic_results",
        "diagnostic_answers",
        "diagnostic_sessions",
        "question_options",
        "module_contents",
        "questions",
        "learning_modules",
        "classroom_members",
        "teacher_profiles",
        "student_profiles",
        "classrooms",
        "concepts",
        "schools",
        "users",
    ]:
        op.drop_table(table_name)

