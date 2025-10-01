import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/parent_main/models/parent_latest_payment_model.dart';
import 'package:kdkd_mobile/feature/parent_main/repositories/latest_payment_api.dart';

class ParentLatestPaymentNotifier extends StateNotifier<UiState<ParentLatestPaymentModel>> {
  final ParentLatestPaymentApi _api;

  ParentLatestPaymentNotifier(this._api) : super(const Idle());

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

final parentLatestPaymentProvider =
    StateNotifierProvider<ParentLatestPaymentNotifier, UiState<ParentLatestPaymentModel>>((ref) {
  final api = ref.watch(parentlatestPaymentApiProvider);
  return ParentLatestPaymentNotifier(api);
});
