import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/child_main/models/character_model.dart';

class CharacterApi {
  final Dio _dio;

  CharacterApi(this._dio);

  /// 키덕키덕 캐릭터 데이터 조회
  Future<CharacterModel?> getCharacterData() async {
    try {
      final response = await _dio.get('/children/characters');
      return CharacterModel.fromMap(response.data as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }
}

/// CharacterApi Provider
final characterApiProvider = Provider<CharacterApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CharacterApi(dio);
});
