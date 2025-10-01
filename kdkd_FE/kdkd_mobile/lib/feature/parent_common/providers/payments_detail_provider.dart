import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/parent_common/models/payment_detail_model.dart';
import 'package:kdkd_mobile/feature/parent_common/repositories/child_accounts_api.dart';

class PaymentDetailNotifier extends StateNotifier<UiState<PaymentDetailModel>> {
  final ChildAccountsApi _api;

  PaymentDetailNotifier(this._api) : super(const Idle());

  Future<void> getPaymentDetail(String childUuid, int accountItemSeq) async {
    state = const Loading();

    try {
      final paymentDetail = await _api.getPaymentDetail(childUuid, accountItemSeq);

      if (paymentDetail != null) {
        state = Success(paymentDetail);
      } else {
        state = const Failure(
          'PAYMENT_DETAIL_NOT_FOUND',
          message: 'Payment detail not found',
        );
      }
    } catch (e) {
      state = Failure(
        e,
        message: 'Failed to load payment detail',
      );
    }
  }

  void clear() {
    state = const Idle();
  }

  Future<void> refresh(String childUuid, int accountItemSeq) async {
    await getPaymentDetail(childUuid, accountItemSeq);
  }
}

final paymentDetailProvider = StateNotifierProvider<PaymentDetailNotifier, UiState<PaymentDetailModel>>((ref) {
  final api = ref.watch(childAccountsApiProvider);
  return PaymentDetailNotifier(api);
});
