from datetime import UTC, datetime
from uuid import UUID, uuid4

from app.api.v1.schemas.auth import UserSchema
from app.api.v1.schemas.common import Question, QuestionOption
from app.api.v1.schemas.learning import (
    AiProfile,
    ConceptMastery,
    DdaDecision,
    DiagnosticSession,
    DiagnosticSubmitResponse,
    LearningPath,
    LearningPathItem,
    ModuleContent,
    ModuleDetail,
    ModulePage,
    ModuleProgress,
    QuizSession,
    QuizSubmitResponse,
)
from app.api.v1.schemas.teacher import (
    Classroom,
    ClassroomProgress,
    InterventionRecommendation,
    StudentProgressSummary,
)


class MockStore:
    """In-memory service for Sprint 1 before PostgreSQL repositories land."""

    def __init__(self) -> None:
        self.users_by_email: dict[str, UserSchema] = {}
        self.users_by_id: dict[str, UserSchema] = {}
        self.synced_events: set[str] = set()
        self.concept_id = UUID("11111111-1111-4111-8111-111111111111")
        self.module_id = UUID("22222222-2222-4222-8222-222222222222")
        self.classroom_id = UUID("33333333-3333-4333-8333-333333333333")
        self.student_id = UUID("44444444-4444-4444-8444-444444444444")

    def get_or_create_user(
        self,
        *,
        email: str,
        role: str,
        full_name: str | None = None,
    ) -> UserSchema:
        normalized_email = email.strip().lower()
        user = self.users_by_email.get(normalized_email)
        if user is not None:
            return user

        user = UserSchema(
            id=uuid4(),
            email=normalized_email,
            role=role,
            full_name=full_name,
            email_verified=False,
            profile_completed=False,
        )
        self.users_by_email[normalized_email] = user
        self.users_by_id[str(user.id)] = user
        return user

    def get_user(self, user_id: str) -> UserSchema:
        user = self.users_by_id.get(user_id)
        if user is not None:
            return user
        return self.get_or_create_user(
            email="demo@litera.ai",
            role="student",
            full_name="Demo User",
        )

    def verify_user_email(self, user_id: str) -> UserSchema:
        user = self.get_user(user_id)
        updated = user.model_copy(update={"email_verified": True})
        self._save_user(updated)
        return updated

    def complete_profile(self, user_id: str, full_name: str) -> UserSchema:
        user = self.get_user(user_id)
        updated = user.model_copy(
            update={"full_name": full_name, "profile_completed": True},
        )
        self._save_user(updated)
        return updated

    def create_diagnostic_session(self) -> DiagnosticSession:
        return DiagnosticSession(
            id=uuid4(),
            status="in_progress",
            questions=self._questions(),
        )

    def submit_diagnostic(self, session_id: UUID) -> DiagnosticSubmitResponse:
        result = AiProfile(
            literacy_profile="developing_reader",
            numeracy_profile="transitional",
            confidence=0.86,
            model_version="cnn-diagnostic-0.1.0",
            generated_at=datetime.now(tz=UTC),
        )
        path = LearningPath(
            id=uuid4(),
            status="active",
            items=[
                LearningPathItem(
                    id=uuid4(),
                    concept_id=self.concept_id,
                    module_id=self.module_id,
                    title="Inferensi Teks dalam STEM",
                    target_difficulty="medium",
                    status="available",
                ),
            ],
        )
        return DiagnosticSubmitResponse(result=result, learning_path=path)

    def current_learning_path(self) -> LearningPath:
        return LearningPath(
            id=uuid4(),
            status="active",
            items=[
                LearningPathItem(
                    id=uuid4(),
                    concept_id=self.concept_id,
                    module_id=self.module_id,
                    title="Inferensi Teks dalam STEM",
                    target_difficulty="medium",
                    status="available",
                ),
                LearningPathItem(
                    id=uuid4(),
                    concept_id=self.concept_id,
                    module_id=self.module_id,
                    title="Penalaran Soal Cerita",
                    target_difficulty="medium",
                    status="locked",
                ),
            ],
        )

    def module_page(self, page: int, page_size: int) -> ModulePage:
        module = self.module_detail(self.module_id)
        return ModulePage(items=[module], page=page, page_size=page_size, total=1)

    def module_detail(self, module_id: UUID) -> ModuleDetail:
        return ModuleDetail(
            id=module_id,
            title="Inferensi Teks dalam STEM",
            difficulty="medium",
            estimated_minutes=12,
            contents=[
                ModuleContent(
                    id=uuid4(),
                    content_type="text",
                    sort_order=1,
                    body={
                        "title": "Membaca data sebelum menyimpulkan",
                        "text": (
                            "Cari pola, bandingkan bukti, lalu tulis simpulan "
                            "yang paling didukung data."
                        ),
                    },
                ),
                ModuleContent(
                    id=uuid4(),
                    content_type="checkpoint",
                    sort_order=2,
                    body={"prompt": "Apa bukti terkuat dari data tersebut?"},
                ),
            ],
        )

    def module_progress(self, module_id: UUID, status: str, progress: int) -> ModuleProgress:
        return ModuleProgress(
            module_id=module_id,
            status=status,
            progress_percent=progress,
        )

    def start_quiz(self, module_id: UUID) -> QuizSession:
        return QuizSession(
            id=uuid4(),
            module_id=module_id,
            difficulty="medium",
            questions=self._questions(),
        )

    def submit_quiz(self) -> QuizSubmitResponse:
        return QuizSubmitResponse(
            score=80,
            mastery=[
                ConceptMastery(
                    concept_id=self.concept_id,
                    mastery_probability=0.74,
                    confidence=0.81,
                ),
            ],
            dda_decision=DdaDecision(
                previous_difficulty="medium",
                next_difficulty="medium",
                reason_code="keep",
                explanation=(
                    "Mastery meningkat, tetapi latihan tambahan dibutuhkan "
                    "agar penguasaan konsep stabil."
                ),
            ),
        )

    def ai_profile(self) -> AiProfile:
        return AiProfile(
            literacy_profile="developing_reader",
            numeracy_profile="transitional",
            confidence=0.86,
            model_version="cnn-diagnostic-0.1.0",
            generated_at=datetime.now(tz=UTC),
        )

    def classrooms(self) -> list[Classroom]:
        return [
            Classroom(
                id=self.classroom_id,
                name="VIII A",
                academic_year="2026/2027",
            ),
        ]

    def classroom_progress(self) -> ClassroomProgress:
        return ClassroomProgress(
            classroom_id=self.classroom_id,
            students=[
                StudentProgressSummary(
                    student_id=self.student_id,
                    full_name="Nadia Putri",
                    average_mastery=0.48,
                    risk_level="high",
                ),
                StudentProgressSummary(
                    student_id=uuid4(),
                    full_name="Fajar Ramadhan",
                    average_mastery=0.65,
                    risk_level="medium",
                ),
            ],
        )

    def interventions(self, student_id: UUID) -> list[InterventionRecommendation]:
        return [
            InterventionRecommendation(
                id=uuid4(),
                student_id=student_id,
                priority="high",
                recommendation_type="remedial_reading",
                rationale=(
                    "Siswa sering salah pada soal inferensi teks dan response "
                    "time tinggi pada soal konteks."
                ),
            ),
        ]

    def accept_sync_events(self, keys: list[str]) -> list[str]:
        accepted: list[str] = []
        for key in keys:
            if key not in self.synced_events:
                self.synced_events.add(key)
            accepted.append(key)
        return accepted

    def _questions(self) -> list[Question]:
        question_id = UUID("55555555-5555-4555-8555-555555555555")
        return [
            Question(
                id=question_id,
                concept_id=self.concept_id,
                difficulty="medium",
                stem=(
                    "Data menunjukkan penggunaan air naik saat hari olahraga. "
                    "Intervensi paling logis adalah..."
                ),
                options=[
                    QuestionOption(
                        id=UUID("66666666-6666-4666-8666-666666666661"),
                        label="A",
                        body="Mengurangi semua kegiatan sekolah.",
                    ),
                    QuestionOption(
                        id=UUID("66666666-6666-4666-8666-666666666662"),
                        label="B",
                        body=(
                            "Menyiapkan titik isi ulang dan jadwal penggunaan "
                            "air saat olahraga."
                        ),
                    ),
                    QuestionOption(
                        id=UUID("66666666-6666-4666-8666-666666666663"),
                        label="C",
                        body="Mengabaikan data karena hanya terjadi satu hari.",
                    ),
                    QuestionOption(
                        id=UUID("66666666-6666-4666-8666-666666666664"),
                        label="D",
                        body="Menyimpulkan tanpa melihat angka.",
                    ),
                ],
            ),
        ]

    def _save_user(self, user: UserSchema) -> None:
        self.users_by_email[user.email] = user
        self.users_by_id[str(user.id)] = user


mock_store = MockStore()

