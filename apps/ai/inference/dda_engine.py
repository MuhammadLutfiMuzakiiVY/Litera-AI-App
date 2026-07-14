from apps.ai.inference.schemas import DdaDecision


class DdaEngine:
    """Transparent Dynamic Difficulty Adjustment v1 rule engine."""

    _order = ["foundation", "easy", "medium", "hard", "advanced"]

    def decide(
        self,
        *,
        mastery_probability: float,
        confidence: float,
        recent_correctness: float,
        previous_difficulty: str,
        response_time_trend: str = "normal",
    ) -> DdaDecision:
        if confidence < 0.6:
            return DdaDecision(
                previous_difficulty=previous_difficulty,
                next_difficulty=previous_difficulty,
                reason_code="keep",
                explanation="Confidence rendah, sistem mengumpulkan bukti tambahan.",
            )

        if mastery_probability >= 0.8 and recent_correctness >= 0.8:
            next_difficulty = self._step(previous_difficulty, 1)
            return DdaDecision(
                previous_difficulty=previous_difficulty,
                next_difficulty=next_difficulty,
                reason_code="increase",
                explanation="Mastery dan jawaban terbaru stabil, difficulty dinaikkan.",
            )

        if mastery_probability < 0.55 or recent_correctness < 0.45:
            next_difficulty = self._step(previous_difficulty, -1)
            return DdaDecision(
                previous_difficulty=previous_difficulty,
                next_difficulty=next_difficulty,
                reason_code="remediate",
                explanation="Mastery belum stabil, siswa diarahkan ke remediasi.",
            )

        if response_time_trend == "slow":
            return DdaDecision(
                previous_difficulty=previous_difficulty,
                next_difficulty=previous_difficulty,
                reason_code="keep",
                explanation="Jawaban benar tetapi lambat, difficulty dipertahankan.",
            )

        return DdaDecision(
            previous_difficulty=previous_difficulty,
            next_difficulty=previous_difficulty,
            reason_code="keep",
            explanation="Latihan dilanjutkan pada difficulty saat ini.",
        )

    def _step(self, difficulty: str, delta: int) -> str:
        try:
            index = self._order.index(difficulty)
        except ValueError:
            index = self._order.index("medium")
        next_index = max(0, min(index + delta, len(self._order) - 1))
        return self._order[next_index]

