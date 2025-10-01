import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/parent_main/models/parent_latest_payment_model.dart';

class ParentLatestPaymentApi {
  final Dio dio;

  ParentLatestPaymentApi(this.dio);

  Future<ParentLatestPaymentModel?> getPayment() async {
    try {
      final response = await dio.get('/parents/latest-payment');

      return ParentLatestPaymentModel.fromMap(response.data);
    } catch (e) {
      return null;
    }
  }
}

final parentlatestPaymentApiProvider = Provider<ParentLatestPaymentApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ParentLatestPaymentApi(dio);
});
