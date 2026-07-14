from fastapi import APIRouter, Depends

from app.api.v1.schemas.auth import UserEnvelope
from app.api.v1.schemas.profile import CompleteProfileRequest
from app.core.security import get_current_user_id
from app.services.mock_store import mock_store

router = APIRouter()


@router.get("/me", response_model=UserEnvelope)
def me(user_id: str = Depends(get_current_user_id)) -> UserEnvelope:
    return UserEnvelope(user=mock_store.get_user(user_id))


@router.put("/profiles/complete", response_model=UserEnvelope)
def complete_profile(
    payload: CompleteProfileRequest,
    user_id: str = Depends(get_current_user_id),
) -> UserEnvelope:
    _ = payload.profile_type
    return UserEnvelope(
        user=mock_store.complete_profile(user_id, full_name=payload.full_name),
    )

