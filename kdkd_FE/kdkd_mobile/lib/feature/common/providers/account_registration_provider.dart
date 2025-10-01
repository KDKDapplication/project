import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:kdkd_mobile/feature/common/models/account_state.dart';
import 'package:kdkd_mobile/feature/common/providers/user_account_provider.dart';
import 'package:kdkd_mobile/feature/common/repositories/account_repository.dart';

// 계좌 등록 폼 상태 Notifier
class AccountFormNotifier extends StateNotifier<AccountFormState> {
  final AccountRepository _repository;
  final Ref _ref;

  AccountFormNotifier(this._repository, this._ref) : super(const AccountFormState());

  void setBank(String bank) {
    state = state.copyWith(bank: bank, error: null);
  }

  void setAccountNumber(String accountNumber) {
    state = state.copyWith(accountNumber: accountNumber, error: null);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, error: null);
  }

  void setAuthCode(String authCode) {
    state = state.copyWith(authCode: authCode, error: null);
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  void reset() {
    state = const AccountFormState();
  }

  /// 계좌 등록 실행
  Future<bool> registerAccount() async {
    print(state.toString());
    if (!state.isValid) {
      state = state.copyWith(error: "모든 정보를 올바르게 입력해주세요");
      return false;
    }
    print(2);
    state = state.copyWith(isLoading: true, error: null);

    print(3);
    try {
      // 현재 사용자 UUID 가져오기
      final profileState = _ref.read(profileProvider);
      String? userUuid;

      profileState.when(
        idle: () => userUuid = null,
        loading: () => userUuid = null,
        success: (profile, _, __) {
          print(profile);
          userUuid = profile.uuid;
        },
        failure: (_, __) => userUuid = null,
      );

      print(userUuid);

      if (userUuid == null) {
        throw Exception("사용자 정보를 찾을 수 없습니다");
      }

      final bool response = await _repository.registerChildAccount(
        userUuid: userUuid!,
        accountNumber: state.accountNumber.replaceAll(RegExp(r'[^0-9]'), ''),
        accountPassword: state.password,
        bankName: state.bank,
      );

      return response;
    } catch (e) {
      return false;
    }
  }

  /// 계좌 검증
  Future<bool> verifyAccount() async {
    if (state.accountNumber.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
      state = state.copyWith(error: "올바른 계좌번호를 입력해주세요");
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _repository.verifyAccount(
        accountNumber: state.accountNumber.replaceAll(RegExp(r'[^0-9]'), ''),
      );

      state = state.copyWith(isLoading: false);

      if (response.isValid) {
        return true;
      } else {
        state = state.copyWith(error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  String formatAccountNumber(String input) {
    return _repository.formatAccountNumber(input);
  }

  /// 1원 송금
  Future<bool> sendOneWon() async {
    if (state.accountNumber.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
      state = state.copyWith(error: "올바른 계좌번호를 입력해주세요");
      return false;
    }

    try {
      await _repository.oneWonSend(state.accountNumber.replaceAll(RegExp(r'[^0-9]'), ''));
      state = state.copyWith(isOneWonSent: true, error: null);
      return true;
    } catch (e) {
      state = state.copyWith(error: "1원 송금에 실패했습니다");
      return false;
    }
  }

  /// 1원 송금 인증
  Future<bool> verifyOneWon() async {
    try {
      await _repository.oneWonSendVerification(
        state.accountNumber.replaceAll(RegExp(r'[^0-9]'), ''),
        state.authCode,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: "인증번호가 올바르지 않습니다");
      return false;
    }
  }
}

// 계좌 등록 결과 상태 관리 (UiState 패턴 사용)
class AccountRegistrationNotifier extends StateNotifier<UiState<bool>> {
  final AccountRepository _repository;
  final Ref _ref;

  AccountRegistrationNotifier(this._repository, this._ref) : super(const Idle());

  Future<void> register({
    required String bank,
    required String accountNumber,
    required String password,
  }) async {
    state = const Loading();

    try {
      // 현재 사용자 UUID 가져오기
      final profileState = _ref.read(profileProvider);
      String? userUuid;

      profileState.when(
        idle: () => userUuid = null,
        loading: () => userUuid = null,
        success: (profile, _, __) {
          userUuid = profile.uuid;
        },
        failure: (_, __) => userUuid = null,
      );

      if (userUuid == null) {
        state = Failure(Exception("사용자 정보를 찾을 수 없습니다"));
        return;
      }

      final response = await _repository.registerChildAccount(
        userUuid: userUuid!,
        accountNumber: accountNumber.replaceAll(RegExp(r'[^0-9]'), ''),
        accountPassword: password,
        bankName: bank,
      );

      state = Success(response);
    } catch (e) {
      state = Failure(e);
    }
  }
}

// Providers
final accountFormProvider = StateNotifierProvider<AccountFormNotifier, AccountFormState>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return AccountFormNotifier(repository, ref);
});

final accountRegistrationProvider = StateNotifierProvider<AccountRegistrationNotifier, UiState<bool>>((ref) {
  final repository = ref.watch(accountRepositoryProvider);
  return AccountRegistrationNotifier(repository, ref);
});
