from uuid import UUID

from fastapi import APIRouter, Depends, Query

from app.api.v1.schemas.learning import (
    AiProfile,
    LearningPath,
    ModuleDetail,
    ModulePage,
    ModuleProgress,
    ModuleProgressRequest,
)
from app.core.security import get_current_user_id
from app.services.mock_store import mock_store

router = APIRouter()


@router.get("/learning-paths/current", response_model=LearningPath)
def current_learning_path(user_id: str = Depends(get_current_user_id)) -> LearningPath:
    _ = user_id
    return mock_store.current_learning_path()


@router.get("/modules", response_model=ModulePage)
def modules(
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=50, alias="pageSize"),
    user_id: str = Depends(get_current_user_id),
) -> ModulePage:
    _ = user_id
    return mock_store.module_page(page=page, page_size=page_size)


@router.get("/modules/{module_id}", response_model=ModuleDetail)
def module_detail(
    module_id: UUID,
    user_id: str = Depends(get_current_user_id),
) -> ModuleDetail:
    _ = user_id
    return mock_store.module_detail(module_id)


@router.put("/modules/{module_id}/progress", response_model=ModuleProgress)
def update_module_progress(
    module_id: UUID,
    payload: ModuleProgressRequest,
    user_id: str = Depends(get_current_user_id),
) -> ModuleProgress:
    _ = user_id
    return mock_store.module_progress(
        module_id=module_id,
        status=payload.status,
        progress=payload.progress_percent,
    )


@router.get("/ai/profile", response_model=AiProfile)
def ai_profile(user_id: str = Depends(get_current_user_id)) -> AiProfile:
    _ = user_id
    return mock_store.ai_profile()

