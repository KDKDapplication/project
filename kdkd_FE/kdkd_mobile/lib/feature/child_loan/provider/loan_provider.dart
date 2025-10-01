import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/feature/child_loan/models/loan_status_response.dart';
import 'package:kdkd_mobile/feature/child_loan/models/request_loan_info.dart';
import 'package:kdkd_mobile/feature/child_loan/repositories/loan_api.dart';

final loanStatusProvider = StateNotifierProvider<LoanStatusNotifier, AsyncValue<LoanStatusResponse?>>((ref) {
  final loanApi = ref.watch(loanApiProvider);
  return LoanStatusNotifier(loanApi);
});

class LoanStatusNotifier extends StateNotifier<AsyncValue<LoanStatusResponse?>> {
  final LoanApi _loanApi;

  LoanStatusNotifier(this._loanApi) : super(const AsyncValue.loading()) {
    getLoanStatus();
  }

  Future<void> getLoanStatus() async {
    state = const AsyncValue.loading();
    try {
      final loanStatus = await _loanApi.getLoanStatus();
      state = AsyncValue.data(loanStatus);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<bool> applyLoan(RequestLoanInfo requestLoanInfo) async {
    try {
      final success = await _loanApi.applyLoan(requestLoanInfo: requestLoanInfo);
      if (success) {
        await getLoanStatus();
      }
      return success;
    } catch (error) {
      return false;
    }
  }

  Future<String?> paybackLoan(String loanUuid) async {
    try {
      final result = await _loanApi.paybackLoan(loanUuid: loanUuid);
      if (result != null) {
        await getLoanStatus();
      }
      return result;
    } catch (error) {
      return null;
    }
  }

  void refresh() {
    getLoanStatus();
  }
}
