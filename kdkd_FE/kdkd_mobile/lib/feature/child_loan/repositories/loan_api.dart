import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/child_loan/models/loan_status_response.dart';
import 'package:kdkd_mobile/feature/child_loan/models/request_loan_info.dart';

class LoanApi {
  final Dio dio;

  LoanApi(this.dio);

  /// 빌리기 조회 API
  /// GET /children/loans
  Future<LoanStatusResponse?> getLoanStatus() async {
    try {
      final response = await dio.get('/children/loans');
      final data = Map<String, dynamic>.from(response.data);
      return LoanStatusResponse.fromMap(data);
    } catch (e) {
      print('빌리기 조회 실패: $e');
      return null;
    }
  }

  /// 빌리기 신청 API
  /// POST /children/loans
  Future<bool> applyLoan({
    required RequestLoanInfo requestLoanInfo,
  }) async {
    try {
      await dio.post(
        '/children/loans',
        data: {
          'loanAmount': requestLoanInfo.loanAmount,
          'loanDue': requestLoanInfo.loanDue.toIso8601String().split('T')[0],
          'loanInterest': requestLoanInfo.loanInterest,
          'loanContent': requestLoanInfo.loanContent,
        },
      );
      return true;
    } catch (e) {
      print('빌리기 신청 실패: $e');
      return false;
    }
  }

  /// 빌리기 상환 API
  /// POST /children/loans/{loanUuid}/payback
  Future<String?> paybackLoan({required String loanUuid}) async {
    try {
      final response = await dio.post('/children/loans/$loanUuid/payback');
      return response.data as String?;
    } catch (e) {
      print('빌리기 상환 실패: $e');
      return null;
    }
  }
}

final loanApiProvider = Provider<LoanApi>((ref) {
  final dio = ref.watch(dioProvider);
  return LoanApi(dio);
});
