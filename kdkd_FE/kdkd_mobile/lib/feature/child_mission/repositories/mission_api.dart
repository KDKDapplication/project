import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/parent_mission/models/mission_model.dart';

class MissionApi {
  final Dio dio;
  MissionApi(this.dio);

  Future<List<MissionModel>> getMissions() async {
    final response = await dio.get(
      "/children/missions/list",
    );

    final List data = response.data as List;
    return data.map((e) => MissionModel.fromMap(e)).toList();
  }
}

// Provider 등록
final missionApiProvider = Provider<MissionApi>((ref) {
  final dio = ref.watch(dioProvider);
  return MissionApi(dio);
});
