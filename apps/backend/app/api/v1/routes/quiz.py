from uuid import UUID

from fastapi import APIRouter, Depends, status

from app.api.v1.schemas.common import AnswerRequest
from app.api.v1.schemas.learning import (
    QuizSession,
    QuizSubmitResponse,
    StartQuizRequest,
)
from app.core.security import get_current_user_id
from app.services.mock_store import mock_store

router = APIRouter()


@router.post("", response_model=QuizSession, status_code=status.HTTP_201_CREATED)
def start_quiz(
    payload: StartQuizRequest,
    user_id: str = Depends(get_current_user_id),
) -> QuizSession:
    _ = user_id
    return mock_store.start_quiz(payload.module_id)


@router.post("/{quiz_session_id}/answers", status_code=status.HTTP_202_ACCEPTED)
def save_quiz_answer(
    quiz_session_id: UUID,
    payload: AnswerRequest,
    user_id: str = Depends(get_current_user_id),
) -> dict[str, str]:
    _ = quiz_session_id, payload, user_id
    return {"status": "accepted"}


@router.post("/{quiz_session_id}/submit", response_model=QuizSubmitResponse)
def submit_quiz(
    quiz_session_id: UUID,
    user_id: str = Depends(get_current_user_id),
) -> QuizSubmitResponse:
    _ = quiz_session_id, user_id
    return mock_store.submit_quiz()

