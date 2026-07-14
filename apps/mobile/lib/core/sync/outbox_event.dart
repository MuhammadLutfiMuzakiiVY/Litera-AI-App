class OutboxEvent {
  const OutboxEvent({
    required this.idempotencyKey,
    required this.eventType,
    required this.payload,
    required this.occurredAt,
    this.retryCount = 0,
  });

  final String idempotencyKey;
  final String eventType;
  final Map<String, Object?> payload;
  final DateTime occurredAt;
  final int retryCount;

  factory OutboxEvent.fromJson(Map<String, Object?> json) {
    return OutboxEvent(
      idempotencyKey: json['idempotencyKey'] as String,
      eventType: json['eventType'] as String,
      payload: Map<String, Object?>.from(json['payload'] as Map),
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'idempotencyKey': idempotencyKey,
      'eventType': eventType,
      'payload': payload,
      'occurredAt': occurredAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  OutboxEvent incrementRetry() {
    return OutboxEvent(
      idempotencyKey: idempotencyKey,
      eventType: eventType,
      payload: payload,
      occurredAt: occurredAt,
      retryCount: retryCount + 1,
    );
  }
}
