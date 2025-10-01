import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/common/models/history_model.dart';



class HistoryApi {
  final Dio dio;

  HistoryApi(this.dio);

  Future<HistoryModel> getConsumptions({
    required String month,
    String? day,
    SourceType sourceType = SourceType.ALL,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'month': month,
        'sourceType': sourceType.value,
      };

      if (day != null && day.isNotEmpty) {
        queryParameters['day'] = day;
      }

      final response = await dio.get(
        '/api/bank/consumptions',
        queryParameters: queryParameters,
      );

      return HistoryModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

final historyApiProvider = Provider<HistoryApi>((ref) {
  final dio = ref.watch(dioProvider);
  return HistoryApi(dio);
});