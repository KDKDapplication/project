sealed class UiState<T> {
  const UiState();
}

class Idle<T> extends UiState<T> {
  const Idle();
}

class Loading<T> extends UiState<T> {
  const Loading();
}

class Refreshing<T> extends UiState<T> {
  final T previous;
  const Refreshing(this.previous);
}

class Success<T> extends UiState<T> {
  final T data;
  final bool isFallback;
  final bool fromCache;
  const Success(this.data, {this.isFallback = false, this.fromCache = false});
}

class Failure<T> extends UiState<T> {
  final Object error;
  final String? message;
  const Failure(this.error, {this.message});
}

extension UiStateX<T> on UiState<T> {
  T? get dataOrNull => this is Success<T> ? (this as Success<T>).data : null;

  R when<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(T data, bool isFallback, bool fromCache) success,
    required R Function(Object e, String? msg) failure,
    R Function(T prev)? refreshing,
  }) {
    final s = this;
    switch (s) {
      case Idle<T>():
        return idle();
      case Loading<T>():
        return loading();
      case Refreshing<T>(:final previous):
        return (refreshing ?? (_) => loading())(previous);
      case Success<T>(:final data, :final isFallback, :final fromCache):
        return success(data, isFallback, fromCache);
      case Failure<T>(:final error, :final message):
        return failure(error, message);
    }
  }
}
