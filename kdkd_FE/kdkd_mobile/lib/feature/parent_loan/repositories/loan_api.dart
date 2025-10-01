import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/child_loan/models/loan_status_response.dart';

class ParentLoanApi {
  final Dio dio;

  ParentLoanApi(this.dio);

  /// 빌리기 조회(부모) API
  /// GET /parents/loans
  Future<LoanStatusResponse?> getLoanStatus({required String childUuid}) async {
    try {
      final response = await dio.get(
        '/parents/loans',
        queryParameters: {'childUuid': childUuid},
      );
      final data = Map<String, dynamic>.from(response.data);
      return LoanStatusResponse.fromMap(data);
    } catch (e) {
      print('빌리기 조회 실패: $e');
      return null;
    }
  }

  /// 빌리기 수락 API
  /// POST /parents/loans/{loanUuid}/accept
  Future<bool> acceptLoan({required String loanUuid}) async {
    try {
      await dio.post('/parents/loans/$loanUuid/accept');
      return true;
    } catch (e) {
      print('빌리기 수락 실패: $e');
      return false;
    }
  }

  /// 빌리기 거절 API
  /// DELETE /parents/loans/{loanUuid}/reject
  Future<bool> rejectLoan({required String loanUuid}) async {
    try {
      await dio.delete('/parents/loans/$loanUuid/rejcet');
      return true;
    } catch (e) {
      print('빌리기 거절 실패: $e');
      return false;
    }
  }

  /// 빌리기 삭제 API
  /// DELETE /parents/loans/loans/{loanUuid}
  Future<bool> deleteLoan({required String loanUuid}) async {
    try {
      await dio.delete('/parents/loans/loans/$loanUuid');
      return true;
    } catch (e) {
      print('빌리기 삭제 실패: $e');
      return false;
    }
  }
}

final parentLoanApiProvider = Provider<ParentLoanApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ParentLoanApi(dio);
});
