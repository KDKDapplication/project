import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';

class AutoTransferApi {
  final Dio _dio;

  AutoTransferApi(this._dio);

  /// 매월 용돈 얼마받는지 조회
  Future<int?> fetchAutoTransfer() async {
    try {
      final response = await _dio.get('/accounts/auto-transfer/children');
      print(response);

      // 응답이 숫자 문자열인 경우 int로 파싱
      if (response.data is String) {
        return int.tryParse(response.data);
      } else if (response.data is int) {
        return response.data;
      }

      return null;
    } catch (e) {
      throw Exception("$e");
    }
  }
}

// Provider 등록
final autoTransferApiProvider = Provider<AutoTransferApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AutoTransferApi(dio);
});
