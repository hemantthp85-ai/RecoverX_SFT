// ============================================================
// RecoverX — Result / Either wrapper
// A lightweight functional wrapper so service methods can return
// Result<T> instead of throwing, keeping UI code clean.
// ============================================================

sealed class Result<T> {
  const Result();
}

final class ResultSuccess<T> extends Result<T> {
  const ResultSuccess(this.data);
  final T data;
}

final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.error);
  final Exception error;
}

// ── Convenience extension ─────────────────────────────────────
extension ResultX<T> on Result<T> {
  bool get isSuccess => this is ResultSuccess<T>;
  bool get isFailure => this is ResultFailure<T>;

  T get data => (this as ResultSuccess<T>).data;
  Exception get error => (this as ResultFailure<T>).error;

  R when<R>({
    required R Function(T data) success,
    required R Function(Exception error) failure,
  }) {
    return switch (this) {
      ResultSuccess<T> s => success(s.data),
      ResultFailure<T> f => failure(f.error),
    };
  }
}
