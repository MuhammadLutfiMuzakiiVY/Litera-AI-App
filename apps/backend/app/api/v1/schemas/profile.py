from uuid import UUID

from pydantic import BaseModel, Field


class CompleteProfileRequest(BaseModel):
    profile_type: str = Field(pattern="^(student|teacher)$")
    full_name: str = Field(min_length=2)
    school_id: UUID | None = None
    grade_level: str | None = None
    subject_area: str | None = None
    learning_preference: str | None = None

