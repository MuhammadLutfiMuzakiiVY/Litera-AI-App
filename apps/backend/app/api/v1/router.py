from fastapi import APIRouter

from app.api.v1.routes import (
    assessment,
    auth,
    health,
    learning,
    notifications,
    profile,
    quiz,
    sync,
    teacher,
)

api_router = APIRouter()
api_router.include_router(health.router, tags=["Health"])
api_router.include_router(auth.router, prefix="/auth", tags=["Auth"])
api_router.include_router(profile.router, tags=["Profile"])
api_router.include_router(assessment.router, prefix="/assessments", tags=["Assessment"])
api_router.include_router(learning.router, tags=["Learning"])
api_router.include_router(quiz.router, prefix="/quizzes", tags=["Quiz"])
api_router.include_router(teacher.router, prefix="/teacher", tags=["Teacher"])
api_router.include_router(sync.router, prefix="/sync", tags=["Sync"])
api_router.include_router(
    notifications.router,
    prefix="/notification-devices",
    tags=["Notifications"],
)

