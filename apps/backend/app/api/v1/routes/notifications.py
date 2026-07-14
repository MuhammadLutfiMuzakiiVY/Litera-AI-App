from fastapi import APIRouter, Depends, status

from app.api.v1.schemas.sync import DeviceTokenRequest
from app.core.security import get_current_user_id

router = APIRouter()


@router.post("", status_code=status.HTTP_204_NO_CONTENT)
def register_device_token(
    payload: DeviceTokenRequest,
    user_id: str = Depends(get_current_user_id),
) -> None:
    _ = payload, user_id
    return None

