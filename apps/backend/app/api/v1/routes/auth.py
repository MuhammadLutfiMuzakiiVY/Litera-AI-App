from fastapi import APIRouter, Depends, status

from app.api.v1.schemas.auth import (
    AuthBootstrapResponse,
    AuthTokenResponse,
    LoginRequest,
    RefreshTokenRequest,
    RegisterRequest,
    UserEnvelope,
    VerifyEmailRequest,
)
from app.core.config import settings
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    get_current_user_id,
)
from app.services.mock_store import mock_store

router = APIRouter()


@router.post(
    "/register",
    response_model=AuthBootstrapResponse,
    status_code=status.HTTP_201_CREATED,
)
def register(payload: RegisterRequest) -> AuthBootstrapResponse:
    user = mock_store.get_or_create_user(
        email=payload.email,
        role=payload.role,
        full_name=payload.full_name,
    )
    return AuthBootstrapResponse(user=user)


@router.post("/login", response_model=AuthTokenResponse)
def login(payload: LoginRequest) -> AuthTokenResponse:
    user = mock_store.get_or_create_user(
        email=payload.email,
        role=payload.role,
        full_name=None,
    )
    return AuthTokenResponse(
        access_token=create_access_token(subject=str(user.id), role=user.role),
        refresh_token=create_refresh_token(subject=str(user.id), role=user.role),
        expires_in=settings.access_token_minutes * 60,
        user=user,
    )


@router.post("/verify-email", response_model=UserEnvelope)
def verify_email(
    payload: VerifyEmailRequest,
    user_id: str = Depends(get_current_user_id),
) -> UserEnvelope:
    _ = payload
    return UserEnvelope(user=mock_store.verify_user_email(user_id))


@router.post("/resend-otp", status_code=status.HTTP_202_ACCEPTED)
def resend_otp(user_id: str = Depends(get_current_user_id)) -> dict[str, str]:
    _ = user_id
    return {"status": "queued"}


@router.post("/refresh", response_model=AuthTokenResponse)
def refresh(payload: RefreshTokenRequest) -> AuthTokenResponse:
    decoded = decode_token(payload.refresh_token)
    user = mock_store.get_user(str(decoded["sub"]))
    return AuthTokenResponse(
        access_token=create_access_token(subject=str(user.id), role=user.role),
        refresh_token=create_refresh_token(subject=str(user.id), role=user.role),
        expires_in=settings.access_token_minutes * 60,
        user=user,
    )


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(user_id: str = Depends(get_current_user_id)) -> None:
    _ = user_id
    return None

