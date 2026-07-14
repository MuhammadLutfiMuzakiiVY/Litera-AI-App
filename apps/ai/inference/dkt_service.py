from collections import defaultdict

from apps.ai.inference.schemas import KnowledgeTraceEvent, MasteryPrediction


class LstmDktService:
    """Rule-backed DKT placeholder until the TensorFlow LSTM model is trained."""

    model_version = "lstm-dkt-0.1.0"

    def predict_mastery(
        self,
        events: list[KnowledgeTraceEvent],
    ) -> list[MasteryPrediction]:
        grouped: dict[str, list[KnowledgeTraceEvent]] = defaultdict(list)
        for event in events:
            grouped[event.concept_id].append(event)

        predictions: list[MasteryPrediction] = []
        for concept_id, concept_events in grouped.items():
            total = len(concept_events)
            correct = sum(1 for event in concept_events if event.is_correct)
            recent = concept_events[-3:]
            recent_correct = sum(1 for event in recent if event.is_correct)
            mastery = (0.35 + (correct / total) * 0.45 + (recent_correct / 3) * 0.2)
            predictions.append(
                MasteryPrediction(
                    concept_id=concept_id,
                    mastery_probability=round(min(mastery, 0.99), 2),
                    confidence=round(min(0.62 + total * 0.04, 0.9), 2),
                ),
            )
        return predictions

