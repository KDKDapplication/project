import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/parent_common/models/child_account_model.dart';
import 'package:kdkd_mobile/feature/parent_common/repositories/child_accounts_api.dart';

final childAccountsProvider = StateNotifierProvider<ChildAccountsController, UiState<List<ChildAccountModel>>>(
  (ref) => ChildAccountsController(ref),
);

class ChildAccountsController extends StateNotifier<UiState<List<ChildAccountModel>>> {
  final Ref ref;

  ChildAccountsController(this.ref) : super(const Idle()) {
    fetchChildAccounts();
  }

  Future<void> fetchChildAccounts() async {
    state = const Loading();
    try {
      final api = ref.read(childAccountsApiProvider);
      final accounts = await api.getChildAccounts();

      if (accounts != null) {
        state = Success(accounts);
      } else {
        state = const Failure('자녀 계좌 정보를 불러올 수 없습니다');
      }
    } catch (e) {
      state = Failure(e);
    }
  }

  Future<void> refreshChildAccounts() async {
    if (state is Success) {
      state = Refreshing((state as Success).data);
    } else {
      state = const Loading();
    }

    try {
      final api = ref.read(childAccountsApiProvider);
      final accounts = await api.getChildAccounts();

      if (accounts != null) {
        state = Success(accounts);
      } else {
        state = const Failure('자녀 계좌 정보를 새로고침할 수 없습니다');
      }
    } catch (e) {
      state = Failure(e);
    }
  }

  void clearAccounts() {
    state = const Idle();
  }

  List<ChildAccountModel> get accounts => state.when(
        idle: () => [],
        loading: () => [],
        success: (accounts, isFallback, fromCache) => accounts,
        failure: (error, message) => [],
      );

  bool get hasAccounts => accounts.isNotEmpty;

  ChildAccountModel? getAccountByChildUuid(String childUuid) {
    try {
      return accounts.firstWhere((account) => account.childUuid == childUuid);
    } catch (e) {
      return null;
    }
  }
}
