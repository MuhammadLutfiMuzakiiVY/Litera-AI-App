sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.value);

  final T value;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure({
    required this.message,
    required this.code,
    this.canRetry = true,
  });

  final String message;
  final String code;
  final bool canRetry;
}

