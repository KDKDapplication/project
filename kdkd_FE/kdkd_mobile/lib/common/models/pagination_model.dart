class Pagination<T> {
  final List<T> data;
  final bool isLoading;
  final bool hasMoreData;
  final int currentPage;
  final int totalPages;
  final String? error;

  const Pagination({
    this.data = const [],
    this.isLoading = false,
    this.hasMoreData = true,
    this.currentPage = 0,
    this.totalPages = 0,
    this.error,
  });

  Pagination<T> copyWith({
    List<T>? data,
    bool? isLoading,
    bool? hasMoreData,
    int? currentPage,
    int? totalPages,
    String? error,
  }) {
    return Pagination<T>(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      error: error,
    );
  }

  bool get canLoadMore => hasMoreData && !isLoading && error == null;
}