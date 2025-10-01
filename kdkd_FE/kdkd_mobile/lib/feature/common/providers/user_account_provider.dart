import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/common/models/user_account_model.dart';
import 'package:kdkd_mobile/feature/common/repositories/account_repository.dart';

// 사용자 계좌 정보 관리 NotifierProvider
class UserAccountNotifier extends StateNotifier<UiState<UserAccountModel>> {
  final AccountRepository _repository;

  UserAccountNotifier(this._repository) : super(const Idle()) {
    loadUserAccount();
  }

  Future<void> loadUserAccount() async {
    state = const Loading();
    try {
      final account = await _repository.getUserAccount();
      if (account != null) {
        state = Success(account);
      } else {
        state = const Failure("계좌 정보를 불러올 수 없습니다");
      }
    } catch (e) {
      state = Failure(e);
    }
  }

  Future<void> refreshUserAccount() async {
    if (state is Success<UserAccountModel>) {
      state = Refreshing((state as Success<UserAccountModel>).data);
    } else {
      state = const Loading();
    }

    try {
      final account = await _repository.getUserAccount();
      if (account != null) {
        state = Success(account);
      } else {
        state = const Failure("계좌 정보를 불러올 수 없습니다");
      }
    } catch (e) {
      state = Failure(e);
    }
  }

  int? get money => state.when(
        idle: () => null,
        loading: () => null,
        success: (data, isFallback, fromCache) => data.balance,
        failure: (e, msg) => null,
      );
}

// 사용자 계좌 Provider
final userAccountProvider = StateNotifierProvider<UserAccountNotifier, UiState<UserAccountModel>>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return UserAccountNotifier(repository);
});

// Repository Provider (다른 provider들에서도 사용)
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AccountRepository(dio, ref);
});
