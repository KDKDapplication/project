import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/parent_main/models/connection_code_model.dart';

class ConnectionCodeApi {
  final Dio dio;

  ConnectionCodeApi(this.dio);

  Future<ConnectionCodeModel?> generateCode() async {
    try {
      final response = await dio.post('parents/invites/code');
      final data = Map<String, dynamic>.from(response.data);

      return ConnectionCodeModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}

final connectionCodeApiProvider = Provider<ConnectionCodeApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ConnectionCodeApi(dio);
});
