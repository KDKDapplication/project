import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';

class PayApi {
  final Dio _dio;

  PayApi(this._dio);

  /// 용돈 송금 API
  Future<bool> sendAllowance({
    required String childUuid,
    required int amount,
  }) async {
    try {
      await _dio.post(
        'tagging/transfer',
        data: {
          'childUuid': childUuid,
          'amount': amount,
        },
      );
      return true;
    } on DioException catch (e) {
      throw _handleDioException(e, "용돈 송금");
    } catch (e) {
      throw Exception("용돈 송금 실패: $e");
    }
  }

  /// 결제 API
  Future<bool> postPay({
    required String childUuid,
    required int amount,
    double? latitude,
    double? longitude,
  }) async {
    try {
      await _dio.post(
        '/qr',
        data: {
          'userUuid': childUuid,
          'payAmount': amount,
          "latitude": latitude ?? 0,
          "longitude": longitude ?? 0,
        },
      );
      return true;
    } on DioException catch (e) {
      throw _handleDioException(e, "결제");
    } catch (e) {
      throw Exception("결제 실패: $e");
    }
  }

  /// DioException 공통 처리
  Exception _handleDioException(DioException e, String operation) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Exception("$operation 실패: 연결 시간 초과");
      case DioExceptionType.sendTimeout:
        return Exception("$operation 실패: 요청 시간 초과");
      case DioExceptionType.receiveTimeout:
        return Exception("$operation 실패: 응답 시간 초과");
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? e.message;
        return Exception("$operation 실패 ($statusCode): $message");
      case DioExceptionType.cancel:
        return Exception("$operation 취소됨");
      case DioExceptionType.unknown:
        return Exception("$operation 실패: 네트워크 연결을 확인해주세요");
      default:
        return Exception("$operation 실패: ${e.message}");
    }
  }
}

final payApiProvider = Provider<PayApi>((ref) {
  final dio = ref.watch(dioProvider);
  return PayApi(dio);
});
