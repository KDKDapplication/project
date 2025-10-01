import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/parent_mission/models/mission_model.dart';

class MissionApi {
  final Dio _dio;

  MissionApi(this._dio);

  // 미션 목록 조회
  Future<List<MissionModel>> getMissionList(String childUuid) async {
    try {
      final response = await _dio.get('/parents/missions/list', queryParameters: {"childUuid": childUuid});

      final List<dynamic> data = response.data as List<dynamic>;
      return data.map((json) => MissionModel.fromMap(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Error get mission: $e');
    }
  }

  // 미션 생성
  Future<void> createMission({
    required String childUuid,
    required String missionName,
    required String missionContent,
    required int reward,
    required DateTime endAt,
  }) async {
    try {
      await _dio.post(
        '/parents/missions',
        data: {
          'childUuid': childUuid,
          'missionTitle': missionName,
          'missionContent': missionContent,
          'reward': reward,
          'endAt': endAt.toIso8601String(),
        },
      );
    } catch (e) {
      throw Exception('Error creating mission: $e');
    }
  }

  // 미션 성공 처리
  Future<void> successMission({
    required String missionUuid,
  }) async {
    try {
      await _dio.post(
        '/parents/missions/$missionUuid/success',
      );
    } catch (e) {
      throw Exception('Error success mission: $e');
    }
  }

  // 미션 삭제
  Future<void> deleteMission({
    required String missionUuid,
  }) async {
    try {
      await _dio.delete(
        '/parents/missions/$missionUuid',
      );
    } catch (e) {
      throw Exception('Error delete mission: $e');
    }
  }
}

final missionApiProvider = Provider<MissionApi>((ref) {
  final dio = ref.watch(dioProvider);
  return MissionApi(dio);
});
