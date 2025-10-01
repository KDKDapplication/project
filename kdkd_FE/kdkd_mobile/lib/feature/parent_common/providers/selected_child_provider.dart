import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/feature/child_loan/models/loan_status_response.dart';
import 'package:kdkd_mobile/feature/parent_collection/repositories/loan_api.dart';
import 'package:kdkd_mobile/feature/parent_common/models/child_account_model.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/auto_debit_provider.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/child_accounts_provider.dart';

final selectedChildProvider = StateNotifierProvider<SelectedChildController, ChildAccountModel?>((ref) {
  return SelectedChildController(ref);
});

class SelectedChildController extends StateNotifier<ChildAccountModel?> {
  final Ref ref;

  SelectedChildController(this.ref) : super(null) {
    _initializeSelectedChild();
  }

  void _initializeSelectedChild() {
    // 자녀 계좌 목록을 감시하고 첫 번째 자녀를 기본값으로 설정
    ref.listen(childAccountsProvider, (previous, next) {
      next.when(
        idle: () {},
        loading: () {},
        success: (accounts, isFallback, fromCache) {
          _setDefaultChildIfNeeded(accounts);
        },
        failure: (error, message) {},
      );
    });

    // 자동이체 목록 변경을 감시하고 선택된 자녀 정보 업데이트
    ref.listen(autoDebitListProvider, (previous, next) {
      next.when(
        idle: () {},
        loading: () {},
        success: (autoDebits, isFallback, fromCache) {
          if (state != null) {
            _updateAutoDebitInfo(autoDebits, state!.childUuid, state!.childName);
          }
        },
        failure: (error, message) {},
      );
    });

    // 초기 자녀 설정
    _setInitialChild();
  }

  void _setInitialChild() {
    final childAccountsState = ref.read(childAccountsProvider);
    childAccountsState.when(
      idle: () {},
      loading: () {},
      success: (accounts, isFallback, fromCache) {
        _setDefaultChildIfNeeded(accounts);
      },
      failure: (error, message) {},
    );
  }

  void _setDefaultChildIfNeeded(List<ChildAccountModel> accounts) {
    if (state == null && accounts.isNotEmpty) {
      state = accounts.first;
      // 다음 프레임에서 실행하여 순환 의존성 방지
      Future.microtask(() {
        _fetchLoanStatusForChild(accounts.first.childUuid);
        _fetchAutoDebitStatusForChild(accounts.first.childUuid, accounts.first.childName);
      });
    }
  }

  void selectChild(String? childUuid) {
    if (childUuid != null) {
      final childAccounts = ref.read(childAccountsProvider.notifier).accounts;
      try {
        final child = childAccounts.firstWhere((child) => child.childUuid == childUuid);
        state = child;
        _fetchLoanStatusForChild(childUuid);
        _fetchAutoDebitStatusForChild(childUuid, child.childName);
      } catch (e) {
        state = null;
      }
    } else {
      state = null;
    }
  }

  void updateAutoDebit(bool isEnabled) {
    if (state != null) {
      state = state!.copyWith(isAutoDebit: isEnabled);
    }
  }

  void clearSelection() {
    state = null;
  }

  // 선택된 자녀의 UUID를 가져오는 getter
  String? get selectedChildUuid => state?.childUuid;

  // 선택된 자녀의 이름을 가져오는 getter
  String? get selectedChildName => state?.childName;

  // 빌리기 상태를 조회하고 자녀 정보를 업데이트
  Future<void> _fetchLoanStatusForChild(String childUuid) async {
    try {
      final loanApi = ref.read(loanApiProvider);
      final loanModel = await loanApi.getLoanStatus(childUuid: childUuid);

      if (loanModel != null && state != null) {
        // API에서 받은 빌리기 정보로 자녀 모델 업데이트
        state = state!.copyWith(
          loanStatus: LoanStatusExtension.fromMap(loanModel.loanStatus),
          loanUuid: loanModel.loanUuid,
          loanMoney: loanModel.loanAmount,
          loanDay: loanModel.loanDate,
        );
      }
    } catch (e) {
      // 에러 발생시 빌리기 상태를 NOT_APPLIED로 설정
      if (state != null) {
        state = state!.copyWith(
          loanStatus: LoanStatus.NOT_APPLIED,
          loanMoney: null,
          loanDay: null,
        );
      }
    }
  }

  // 자동이체 상태를 조회하고 자녀 정보를 업데이트
  Future<void> _fetchAutoDebitStatusForChild(String childUuid, String childName) async {
    try {
      // 자동이체 목록을 가져와서 해당 자녀의 정보 찾기
      final autoDebitState = ref.read(autoDebitListProvider);

      autoDebitState.when(
        idle: () => Future.microtask(() => _fetchAutoDebitList()),
        loading: () {},
        success: (autoDebits, isFallback, fromCache) {
          _updateAutoDebitInfo(autoDebits, childUuid, childName);
        },
        failure: (error, message) {
          // 자동이체 목록을 새로 가져오기
          Future.microtask(() => _fetchAutoDebitList());
        },
      );
    } catch (e) {
      // 에러 발생시 자동이체 상태를 false로 설정
      if (state != null) {
        state = state!.copyWith(
          isAutoDebit: false,
          autoDebitMoney: null,
          autoDebitDay: null,
        );
      }
    }
  }

  // 자동이체 목록을 가져오고 해당 자녀 정보 업데이트
  Future<void> _fetchAutoDebitList() async {
    try {
      await ref.read(autoDebitListProvider.notifier).fetchAutoDebitList();

      // 다시 자동이체 정보 업데이트 시도
      final autoDebitState = ref.read(autoDebitListProvider);
      autoDebitState.when(
        idle: () {},
        loading: () {},
        success: (autoDebits, isFallback, fromCache) {
          if (state != null) {
            _updateAutoDebitInfo(autoDebits, state!.childUuid, state!.childName);
          }
        },
        failure: (error, message) {},
      );
    } catch (e) {
      // 자동이체 목록 가져오기 실패
      if (state != null) {
        state = state!.copyWith(
          isAutoDebit: false,
          autoDebitMoney: null,
          autoDebitDay: null,
        );
      }
    }
  }

  // 자동이체 정보로 자녀 모델 업데이트
  void _updateAutoDebitInfo(List<dynamic> autoDebits, String childUuid, String childName) {
    if (state == null) return;

    try {
      // AutoDebitInfo 타입으로 캐스팅하여 자동이체 정보 찾기
      dynamic foundAutoDebit;
      for (final debit in autoDebits) {
        if (debit.childUuid == childUuid || debit.childUuid == childName || debit.childName == childName) {
          foundAutoDebit = debit;
          break;
        }
      }

      if (foundAutoDebit != null) {
        // 자동이체가 설정되어 있는 경우
        state = state!.copyWith(
          isAutoDebit: foundAutoDebit.isActive,
          autoDebitMoney: foundAutoDebit.amount,
          autoDebitDay: foundAutoDebit.date,
          autoDebitTime: foundAutoDebit.hour,
        );
      } else {
        // 자동이체가 설정되지 않은 경우
        state = state!.copyWith(
          isAutoDebit: false,
          autoDebitMoney: null,
          autoDebitDay: null,
        );
      }
    } catch (e) {
      // 자동이체 정보를 찾지 못한 경우
      state = state!.copyWith(
        isAutoDebit: false,
        autoDebitMoney: null,
        autoDebitDay: null,
      );
    }
  }
}
