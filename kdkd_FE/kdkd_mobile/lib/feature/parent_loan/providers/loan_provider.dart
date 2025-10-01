import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/feature/child_loan/models/loan_status_response.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/selected_child_provider.dart';
import 'package:kdkd_mobile/feature/parent_loan/repositories/loan_api.dart';

class ParentLoanNotifier extends AsyncNotifier<LoanStatusResponse?> {
  @override
  Future<LoanStatusResponse?> build() async {
    return null;
  }

  /// 특정 자녀의 빌리기 상태 조회
  Future<void> getLoanStatus(String childUuid) async {
    state = const AsyncValue.loading();

    final api = ref.read(parentLoanApiProvider);
    final result = await api.getLoanStatus(childUuid: childUuid);

    if (result != null) {
      state = AsyncValue.data(result);
    } else {
      state = const AsyncValue.error('빌리기 상태 조회에 실패했습니다', StackTrace.empty);
    }
  }

  /// 빌리기 수락
  Future<bool> acceptLoan(String loanUuid) async {
    final api = ref.read(parentLoanApiProvider);
    final success = await api.acceptLoan(loanUuid: loanUuid);

    if (success) {
      // 선택된 자녀의 빌리기 상태 새로고침
      final selectedChild = ref.read(selectedChildProvider);
      if (selectedChild != null) {
        // selected_child_provider에서 빌리기 상태를 다시 가져오도록 함
        ref.read(selectedChildProvider.notifier).selectChild(selectedChild.childUuid);
      }
    }

    return success;
  }

  /// 빌리기 거절
  Future<bool> rejectLoan(String loanUuid) async {
    final api = ref.read(parentLoanApiProvider);
    final success = await api.rejectLoan(loanUuid: loanUuid);

    if (success) {
      // 선택된 자녀의 빌리기 상태 새로고침
      final selectedChild = ref.read(selectedChildProvider);
      if (selectedChild != null) {
        ref.read(selectedChildProvider.notifier).selectChild(selectedChild.childUuid);
      }
    }

    return success;
  }

  /// 빌리기 삭제
  Future<bool> deleteLoan(String loanUuid) async {
    final api = ref.read(parentLoanApiProvider);
    final success = await api.deleteLoan(loanUuid: loanUuid);

    if (success) {
      // 선택된 자녀의 빌리기 상태 새로고침
      final selectedChild = ref.read(selectedChildProvider);
      if (selectedChild != null) {
        ref.read(selectedChildProvider.notifier).selectChild(selectedChild.childUuid);
      }
    }

    return success;
  }

  /// 상태 새로고침
  Future<void> refresh(String childUuid) async {
    await getLoanStatus(childUuid);
  }
}

final parentLoanProvider = AsyncNotifierProvider<ParentLoanNotifier, LoanStatusResponse?>(() {
  return ParentLoanNotifier();
});

/// 특정 자녀의 빌리기 상태를 가져오는 패밀리 프로바이더
final parentLoanStatusProvider = FutureProvider.family<LoanStatusResponse?, String>((ref, childUuid) async {
  final api = ref.read(parentLoanApiProvider);
  return await api.getLoanStatus(childUuid: childUuid);
});
