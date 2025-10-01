import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/parent_common/models/child_account_model.dart';
import 'package:kdkd_mobile/feature/parent_common/models/payment_detail_model.dart';
import 'package:kdkd_mobile/feature/parent_common/models/payment_model.dart';

class ChildAccountsApi {
  final Dio dio;

  ChildAccountsApi(this.dio);

  // 자녀 계좌 목록 조회
  Future<List<ChildAccountModel>?> getChildAccounts() async {
    try {
      final response = await dio.get('/parents/children/accounts');
      final data = response.data as List<dynamic>;

      final accounts = data.map((item) => ChildAccountModel.fromMap(item as Map<String, dynamic>)).toList();

      return accounts;
    } catch (e) {
      print('에러 발생: $e');
      return null;
    }
  }

  /// 부모 계좌 결제 내역 조회 (페이지네이션)
  /// {
  //   "totalPages": 0,
  //   "childUuid": "string",
  //   "payments": [
  //     {
  //       "accountItemSeq": 0,
  //       "merchantName": "string",
  //       "paymentBalance": 0,
  //       "transactedAt": "2025-09-22T03:40:26.003Z"
  //     }
  //   ]
  // }
  Future<PaymentResponse?> getSpendingHistory({
    required String childUuid,
    required String month,
    required int pageNum,
    required int display,
  }) async {
    try {
      final response = await dio.get(
        '/parents/$childUuid/payments',
        queryParameters: {
          'month': month,
          'pageNum': pageNum,
          'display': display,
        },
      );
      final data = Map<String, dynamic>.from(response.data);

      return PaymentResponse.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  /// 용돈 지급 내역 조회 (페이지네이션)
  Future<PaymentResponse?> getAllowancePayments({
    required String month,
    required int pageNum,
    required int display,
  }) async {
    try {
      final response = await dio.get(
        '/parents/allowances',
        queryParameters: {
          'month': month,
          'pageNum': pageNum,
          'display': display,
        },
      );
      final data = Map<String, dynamic>.from(response.data);

      return PaymentResponse.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<PaymentDetailModel?> getPaymentDetail(String childUuid, int accountItemSeq) async {
    try {
      final response = await dio.get(
        '/parents/$childUuid/payments/$accountItemSeq',
      );

      return PaymentDetailModel.fromMap(response.data as Map<String, dynamic>);
    } catch (e) {
      print(e);
      return null;
    }
  }
}

final childAccountsApiProvider = Provider<ChildAccountsApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ChildAccountsApi(dio);
});
