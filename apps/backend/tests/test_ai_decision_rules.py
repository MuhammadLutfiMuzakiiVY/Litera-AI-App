from apps.ai.inference.dda_engine import DdaEngine


def test_dda_increases_difficulty_when_mastery_is_stable() -> None:
    decision = DdaEngine().decide(
        mastery_probability=0.86,
        confidence=0.82,
        recent_correctness=0.9,
        previous_difficulty="medium",
    )

    assert decision.reason_code == "increase"
    assert decision.next_difficulty == "hard"


def test_dda_remediates_when_mastery_is_low() -> None:
    decision = DdaEngine().decide(
        mastery_probability=0.42,
        confidence=0.78,
        recent_correctness=0.33,
        previous_difficulty="medium",
    )

    assert decision.reason_code == "remediate"
    assert decision.next_difficulty == "easy"

