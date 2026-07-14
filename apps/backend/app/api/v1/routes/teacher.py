from uuid import UUID

from fastapi import APIRouter, Depends

from app.api.v1.schemas.teacher import (
    Classroom,
    ClassroomProgress,
    InterventionRecommendation,
)
from app.core.security import get_current_user_id
from app.services.mock_store import mock_store

router = APIRouter()


@router.get("/classrooms", response_model=list[Classroom])
def classrooms(user_id: str = Depends(get_current_user_id)) -> list[Classroom]:
    _ = user_id
    return mock_store.classrooms()


@router.get("/classrooms/{classroom_id}/progress", response_model=ClassroomProgress)
def classroom_progress(
    classroom_id: UUID,
    user_id: str = Depends(get_current_user_id),
) -> ClassroomProgress:
    _ = classroom_id, user_id
    return mock_store.classroom_progress()


@router.get(
    "/students/{student_id}/interventions",
    response_model=list[InterventionRecommendation],
)
def student_interventions(
    student_id: UUID,
    user_id: str = Depends(get_current_user_id),
) -> list[InterventionRecommendation]:
    _ = user_id
    return mock_store.interventions(student_id)

