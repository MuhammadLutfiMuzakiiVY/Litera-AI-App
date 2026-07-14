from dataclasses import dataclass


@dataclass(frozen=True)
class DiagnosticFeatures:
    correctness: list[int]
    response_time_ms: list[int]
    difficulty: list[str]


@dataclass(frozen=True)
class DiagnosticPrediction:
    literacy_profile: str
    numeracy_profile: str
    confidence: float
    model_version: str


@dataclass(frozen=True)
class KnowledgeTraceEvent:
    concept_id: str
    is_correct: bool
    difficulty: str
    response_time_ms: int


@dataclass(frozen=True)
class MasteryPrediction:
    concept_id: str
    mastery_probability: float
    confidence: float


@dataclass(frozen=True)
class DdaDecision:
    previous_difficulty: str
    next_difficulty: str
    reason_code: str
    explanation: str

