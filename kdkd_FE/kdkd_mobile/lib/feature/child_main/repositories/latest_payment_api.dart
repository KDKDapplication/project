import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/child_main/models/child_latest_payment_model.dart';

class ChildLatestPaymentApi {
  final Dio dio;

  ChildLatestPaymentApi(this.dio);

  Future<ChildLatestPaymentModel?> getPayment() async {
    try {
      final response = await dio.get('/children/latest-payment');

      return ChildLatestPaymentModel.fromMap(response.data);
    } catch (e) {
      print("err : $e");
      return null;
    }
  }
}

final childlatestPaymentApiProvider = Provider<ChildLatestPaymentApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ChildLatestPaymentApi(dio);
});
