import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';

import '../models/account_balance.dart';
import '../models/account_info.dart';
import '../repositories/account_repository.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final dio = ref.watch(dioProvider); // 최신 토큰 & 설정 반영된 Dio
  return AccountRepository(dio);
});

// 계좌 목록 상태 관리를 위한 Notifier
class AccountListNotifier extends StateNotifier<UiState<List<AccountInfo>>> {
  final AccountRepository _repository;

  AccountListNotifier(this._repository) : super(const Idle());

  // 계좌 목록을 불러오는 메소드
  Future<void> fetchAccountList() async {
    state = const Loading();
    try {
      final accounts = await _repository.fetchAccounts();
      state = Success(accounts);
    } catch (e, st) {
      state = Failure(e);
    }
  }
}

// 계좌 목록 상태를 제공하는 Provider
final accountListProvider =
    StateNotifierProvider<AccountListNotifier, UiState<List<AccountInfo>>>(
        (ref) {
  return AccountListNotifier(ref.watch(accountRepositoryProvider));
});

// 특정 계좌의 잔액 상태 관리를 위한 Notifier
class AccountBalanceNotifier extends StateNotifier<UiState<AccountBalance>> {
  final AccountRepository _repository;

  AccountBalanceNotifier(this._repository) : super(const Idle());

  // 특정 계좌의 잔액을 불러오는 메소드
  Future<void> fetchBalance(String accountNumber) async {
    state = const Loading();
    try {
      final balance = await _repository.fetchBalance(accountNumber);
      state = Success(balance);
    } catch (e, st) {
      state = Failure(e);
    }
  }
}

// 특정 계좌의 잔액 상태를 제공하는 Provider
final accountBalanceProvider =
    StateNotifierProvider<AccountBalanceNotifier, UiState<AccountBalance>>(
        (ref) {
  return AccountBalanceNotifier(ref.watch(accountRepositoryProvider));
});
