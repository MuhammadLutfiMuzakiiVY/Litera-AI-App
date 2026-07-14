from uuid import UUID

from pydantic import BaseModel


class Classroom(BaseModel):
    id: UUID
    name: str
    academic_year: str


class StudentProgressSummary(BaseModel):
    student_id: UUID
    full_name: str
    average_mastery: float
    risk_level: str


class ClassroomProgress(BaseModel):
    classroom_id: UUID
    students: list[StudentProgressSummary]


class InterventionRecommendation(BaseModel):
    id: UUID
    student_id: UUID
    priority: str
    recommendation_type: str
    rationale: str

