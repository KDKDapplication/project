import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kdkd_mobile/common/models/pagination_model.dart';
import 'package:kdkd_mobile/feature/parent_common/models/payment_model.dart';
import 'package:kdkd_mobile/feature/parent_common/repositories/child_accounts_api.dart';

class PaymentsNotifier extends StateNotifier<Pagination<PaymentModel>> {
  final ChildAccountsApi _api;

  PaymentsNotifier(this._api) : super(const Pagination<PaymentModel>());

  String _currentChildUuid = '';
  String _currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
  static const int _pageSize = 10;

  Future<void> loadPayments({
    required String childUuid,
    String? month,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = const Pagination<PaymentModel>();
    }

    if (state.isLoading) return;

    _currentChildUuid = childUuid;
    _currentMonth = month ?? _currentMonth;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _api.getSpendingHistory(
        childUuid: _currentChildUuid,
        month: _currentMonth,
        pageNum: refresh ? 0 : state.currentPage,
        display: _pageSize,
      );

      if (response != null) {
        final newData = refresh ? response.payments : [...state.data, ...response.payments];

        state = state.copyWith(
          data: newData,
          isLoading: false,
          hasMoreData: (refresh ? 0 : state.currentPage) + 1 < response.totalPages,
          currentPage: (refresh ? 0 : state.currentPage) + 1,
          totalPages: response.totalPages,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          hasMoreData: false,
          error: '결제 내역을 불러올 수 없습니다',
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
    if (!state.canLoadMore) return;

    await loadPayments(
      childUuid: _currentChildUuid,
      month: _currentMonth,
      refresh: false,
    );
  }

  Future<void> refreshPayments() async {
    await loadPayments(
      childUuid: _currentChildUuid,
      month: _currentMonth,
      refresh: true,
    );
  }

  void changeMonth(String month) {
    _currentMonth = month;
    loadPayments(
      childUuid: _currentChildUuid,
      month: _currentMonth,
      refresh: true,
    );
  }
}

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, Pagination<PaymentModel>>((ref) {
  final api = ref.watch(childAccountsApiProvider);
  return PaymentsNotifier(api);
});
