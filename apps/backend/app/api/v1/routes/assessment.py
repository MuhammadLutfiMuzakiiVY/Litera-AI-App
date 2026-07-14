from uuid import UUID

from fastapi import APIRouter, Depends, status

from app.api.v1.schemas.common import AnswerRequest
from app.api.v1.schemas.learning import DiagnosticSession, DiagnosticSubmitResponse
from app.core.security import get_current_user_id
from app.services.mock_store import mock_store

router = APIRouter()


@router.post(
    "/diagnostic-sessions",
    response_model=DiagnosticSession,
    status_code=status.HTTP_201_CREATED,
)
def start_diagnostic(
    user_id: str = Depends(get_current_user_id),
) -> DiagnosticSession:
    _ = user_id
    return mock_store.create_diagnostic_session()


@router.post(
    "/diagnostic-sessions/{session_id}/answers",
    status_code=status.HTTP_202_ACCEPTED,
)
def save_diagnostic_answer(
    session_id: UUID,
    payload: AnswerRequest,
    user_id: str = Depends(get_current_user_id),
) -> dict[str, str]:
    _ = session_id, payload, user_id
    return {"status": "accepted"}


@router.post(
    "/diagnostic-sessions/{session_id}/submit",
    response_model=DiagnosticSubmitResponse,
)
def submit_diagnostic(
    session_id: UUID,
    user_id: str = Depends(get_current_user_id),
) -> DiagnosticSubmitResponse:
    _ = user_id
    return mock_store.submit_diagnostic(session_id)

