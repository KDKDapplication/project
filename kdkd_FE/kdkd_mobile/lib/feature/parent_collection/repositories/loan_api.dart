import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/parent_collection/models/loan_model.dart';

class LoanApi {
  final Dio dio;

  LoanApi(this.dio);

  /// 빌리기 조회(부모) API
  Future<LoanModel?> getLoanStatus({required String childUuid}) async {
    try {
      final response = await dio.get(
        '/parents/loans',
        queryParameters: {'childUuid': childUuid},
      );
      final data = Map<String, dynamic>.from(response.data);

      return LoanModel.fromMap(data);
    } catch (e) {
      print('빌리기 조회 에러: $e');
      return null;
    }
  }

  /// 빌리기 수락 API
  Future<bool> acceptLoan({required String loanUuid}) async {
    try {
      await dio.post('/parents/loans/$loanUuid/accept');
      return true;
    } catch (e) {
      print('빌리기 수락 에러: $e');
      return false;
    }
  }

  /// 빌리기 거절 API
  Future<bool> rejectLoan({required String loanUuid}) async {
    try {
      await dio.delete('/parents/loans/$loanUuid/reject');
      return true;
    } catch (e) {
      print('빌리기 거절 에러: $e');
      return false;
    }
  }

  /// 빌리기 삭제 API
  Future<bool> deleteLoan({required String loanUuid}) async {
    try {
      await dio.delete('/parents/loans/loans/$loanUuid');
      return true;
    } catch (e) {
      print('빌리기 삭제 에러: $e');
      return false;
    }
  }
}

final loanApiProvider = Provider<LoanApi>((ref) {
  final dio = ref.watch(dioProvider);
  return LoanApi(dio);
});
