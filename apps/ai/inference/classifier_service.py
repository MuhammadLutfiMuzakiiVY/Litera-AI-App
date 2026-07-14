from apps.ai.inference.schemas import DiagnosticFeatures, DiagnosticPrediction


class CnnDiagnosticClassifier:
    """Deterministic placeholder for the future TensorFlow 1D-CNN model."""

    model_version = "cnn-diagnostic-0.1.0"

    def predict(self, features: DiagnosticFeatures) -> DiagnosticPrediction:
        total = max(len(features.correctness), 1)
        accuracy = sum(features.correctness) / total
        avg_response_time = (
            sum(features.response_time_ms) / max(len(features.response_time_ms), 1)
        )

        if accuracy >= 0.8:
            literacy_profile = "critical_reader"
            numeracy_profile = "logical_contextual"
        elif accuracy >= 0.5:
            literacy_profile = "developing_reader"
            numeracy_profile = "transitional"
        else:
            literacy_profile = "mechanical_reader"
            numeracy_profile = "procedural"

        confidence = 0.72 + min(abs(accuracy - 0.5), 0.28)
        if avg_response_time > 25_000:
            confidence = max(0.55, confidence - 0.08)

        return DiagnosticPrediction(
            literacy_profile=literacy_profile,
            numeracy_profile=numeracy_profile,
            confidence=round(confidence, 2),
            model_version=self.model_version,
        )

