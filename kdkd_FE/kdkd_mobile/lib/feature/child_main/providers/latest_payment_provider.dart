import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/child_main/models/child_latest_payment_model.dart';
import 'package:kdkd_mobile/feature/child_main/repositories/latest_payment_api.dart';

class ChildLatestPaymentNotifier extends StateNotifier<UiState<ChildLatestPaymentModel>> {
  final ChildLatestPaymentApi _api;

  ChildLatestPaymentNotifier(this._api) : super(const Idle());

  Future<void> getLatestPayment() async {
    state = const Loading();
    try {
      final result = await _api.getPayment();
      if (result != null) {
        state = Success(result);
      } else {
        state = const Failure('최신 결제 정보를 불러올 수 없습니다');
      }
    } catch (e) {
      state = Failure(e);
    }
  }
}

final childLatestPaymentProvider =
    StateNotifierProvider<ChildLatestPaymentNotifier, UiState<ChildLatestPaymentModel>>((ref) {
  final api = ref.watch(childlatestPaymentApiProvider);
  return ChildLatestPaymentNotifier(api);
});
