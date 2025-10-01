// lib/common/utils/result.dart
class Result<T> {
  final T data;
  final bool isFallback;
  final bool fromCache;
  const Result(this.data, {this.isFallback = false, this.fromCache = false});
}
