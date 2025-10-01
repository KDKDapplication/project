import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/child_accounts_provider.dart';
import 'package:kdkd_mobile/feature/pay/repositories/pay_api.dart';

class PayNotifier extends StateNotifier<UiState<bool>> {
  final PayApi _payApi;
  final ChildAccountsController childAccountProvider;

  PayNotifier(this._payApi, this.childAccountProvider) : super(const Idle());

  Future<bool> sendAllowance({
    required String childUuid,
    required int amount,
  }) async {
    state = const Loading();

    try {
      final success = await _payApi.sendAllowance(
        childUuid: childUuid,
        amount: amount,
      );

      if (success) {
        childAccountProvider.fetchChildAccounts();
        state = const Success(true);
        return true;
      } else {
        state = const Failure("전송 실패");
        return false;
      }
    } catch (e) {
      state = Failure(e);
      return false;
    }
  }

  Future<bool> postPay({
    required String childUuid,
    required int amount,
    double? latitude,
    double? longitude,
  }) async {
    state = const Loading();

    try {
      final success = await _payApi.postPay(
        childUuid: childUuid,
        amount: amount,
        latitude: latitude,
        longitude: longitude,
      );
      return success;
    } catch (e) {
      state = Failure(e);
      return false;
    }
  }

  void reset() {
    state = const Idle();
  }
}

final payProvider = StateNotifierProvider<PayNotifier, UiState<bool>>((ref) {
  final payApi = ref.watch(payApiProvider);
  final childAccountProvider = ref.read(childAccountsProvider.notifier);
  return PayNotifier(
    payApi,
    childAccountProvider,
  );
});
