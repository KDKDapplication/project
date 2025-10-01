import 'package:dio/dio.dart';

import '../models/transaction_history.dart';

class TransactionRepository {
  final Dio _dio;

  TransactionRepository(this._dio);

  static const String _transactionPath = "/transactions";

  /// 거래 내역 조회 (소비내역)
  Future<TransactionHistory> fetchTransactionHistory({
    String? accountNumber,
    String? startDate,
    String? endDate,
    int? page,
    int? size,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (accountNumber != null) queryParams['accountNumber'] = accountNumber;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;

      final response = await _dio.get(
        _transactionPath,
        queryParameters: queryParams,
      );

      return TransactionHistory.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception("거래 내역 조회 실패: ${e.message}");
    } catch (e) {
      throw Exception("알 수 없는 에러 발생 (거래 내역 조회): $e");
    }
  }
}