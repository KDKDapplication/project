import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/feature/parent_common/models/payment_model.dart';
import 'package:kdkd_mobile/feature/parent_common/repositories/child_accounts_api.dart';
import 'package:intl/intl.dart';

class AllowancePaymentsState {
  final List<PaymentModel> payments;
  final bool isLoading;
  final bool hasMoreData;
  final int currentPage;
  final int totalPages;
  final String? error;

  const AllowancePaymentsState({
    this.payments = const [],
    this.isLoading = false,
    this.hasMoreData = true,
    this.currentPage = 0,
    this.totalPages = 0,
    this.error,
  });

  AllowancePaymentsState copyWith({
    List<PaymentModel>? payments,
    bool? isLoading,
    bool? hasMoreData,
    int? currentPage,
    int? totalPages,
    String? error,
  }) {
    return AllowancePaymentsState(
      payments: payments ?? this.payments,
      isLoading: isLoading ?? this.isLoading,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      error: error,
    );
  }
}

class AllowancePaymentsNotifier extends StateNotifier<AllowancePaymentsState> {
  final ChildAccountsApi _api;

  AllowancePaymentsNotifier(this._api) : super(const AllowancePaymentsState());

  String _currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
  static const int _pageSize = 10;

  Future<void> loadAllowancePayments({
    String? month,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = const AllowancePaymentsState();
    }

    if (state.isLoading) return;

    _currentMonth = month ?? _currentMonth;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.getAllowancePayments(
        month: _currentMonth,
        pageNum: refresh ? 0 : state.currentPage,
        display: _pageSize,
      );

      if (response != null) {
        final newPayments = refresh
            ? response.payments
            : [...state.payments, ...response.payments];

        state = state.copyWith(
          payments: newPayments,
          isLoading: false,
          hasMoreData: (refresh ? 0 : state.currentPage) + 1 < response.totalPages,
          currentPage: (refresh ? 0 : state.currentPage) + 1,
          totalPages: response.totalPages,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          hasMoreData: false,
          error: '용돈 지급 내역을 불러올 수 없습니다',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasMoreData: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMorePayments() async {
    if (!state.hasMoreData || state.isLoading) return;

    await loadAllowancePayments(
      month: _currentMonth,
      refresh: false,
    );
  }

  Future<void> refreshPayments() async {
    await loadAllowancePayments(
      month: _currentMonth,
      refresh: true,
    );
  }

  void changeMonth(String month) {
    _currentMonth = month;
    loadAllowancePayments(
      month: _currentMonth,
      refresh: true,
    );
  }
}

final allowancePaymentsProvider = StateNotifierProvider<AllowancePaymentsNotifier, AllowancePaymentsState>((ref) {
  final api = ref.watch(childAccountsApiProvider);
  return AllowancePaymentsNotifier(api);
});