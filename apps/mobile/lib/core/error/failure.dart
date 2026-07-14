class Failure {
  const Failure({
    required this.message,
    this.code = 'unknown',
    this.canRetry = true,
  });

  final String code;
  final String message;
  final bool canRetry;
}

