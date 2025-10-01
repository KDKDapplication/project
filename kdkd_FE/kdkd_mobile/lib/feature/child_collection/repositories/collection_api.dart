import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http_parser/http_parser.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/child_collection/models/collection_model.dart';
import 'package:kdkd_mobile/feature/child_collection/models/create_collection_request.dart';
import 'package:path/path.dart' as p;

class CollectionApi {
  final Dio dio;

  CollectionApi(this.dio);

  /// 모으기 상자 상세 조회
  ///
  /// [boxUuid] 조회할 상자의 UUID
  ///
  /// Returns [CollectionModel] 모으기 상자 상세 정보
  Future<CollectionModel> getCollectionDetail(String boxUuid) async {
    try {
      final response = await dio.get('/children/boxes/$boxUuid');

      final collection = CollectionModel.fromJson(response.data as Map<String, dynamic>);

      return collection;
    } catch (e) {
      print('모으기 상자 상세 조회 API 에러: $e');
      rethrow;
    }
  }

  /// 모으기 상자 목록 조회
  ///
  /// [boxStatus] 필터링할 상태 (IN_PROGRESS, SUCCESS) - 선택사항
  ///
  /// Returns [List<CollectionModel>] 모으기 상자 목록
  Future<List<CollectionModel>> getCollections({
    CollectionStatus? boxStatus,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (boxStatus != null) {
        queryParams['boxStatus'] = boxStatus.value;
      }

      final response = await dio.get(
        '/children/boxes/list',
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data as List<dynamic>;

      final collections = data.map((json) => CollectionModel.fromJson(json as Map<String, dynamic>)).toList();

      return collections;
    } catch (e) {
      print(' 모으기 상자 조회 API 에러: $e');
      rethrow;
    }
  }

  /// 모으기 상자 생성
  ///
  /// [request] 모으기 상자 생성 요청 데이터
  /// [imageFilePath] 상자 이미지 파일 경로 (선택사항)
  ///
  /// Returns [String] 생성 결과 메시지
  Future<String> createCollection({
    required CreateCollectionRequest request,
    String? imageFilePath,
  }) async {
    try {
      // 1) JSON 파트: 반드시 application/json 으로 보냅니다.
      final jsonBytes = utf8.encode(
        jsonEncode({
          'boxName': request.boxName,
          'saving': request.saving,
          'target': request.target,
        }),
      );

      final formData = FormData.fromMap({
        'requestSaveBoxInfo': MultipartFile.fromBytes(
          jsonBytes,
          filename: 'request.json', // 임의 이름
          contentType: MediaType('application', 'json'),
        ),
        // 파일이 있으면 file 파트 추가
        if (imageFilePath != null && imageFilePath.isNotEmpty)
          'file': await MultipartFile.fromFile(
            imageFilePath,
            filename: p.basename(imageFilePath),
            // 이미지가 아닐 수 있으면 MIME을 적절히 바꾸세요.
            contentType: MediaType('image', 'jpeg'),
          ),
      });

      // FormData 요청에서는 contentType을 명시적으로 제거
      final tempOptions = Options()..contentType = null;
      final response = await dio.post(
        '/children/boxes',
        data: formData,
        options: tempOptions,
      );

      return response.data as String;
    } catch (e) {
      print('모으기 상자 생성 API 에러: $e');
      rethrow;
    }
  }

  /// 모으기 상자 수정
  ///
  /// [boxUuid] 수정할 상자의 UUID
  /// [request] 수정할 데이터
  /// [imageFilePath] 새로운 이미지 파일 경로 (선택사항)
  ///
  /// Returns [String] 수정 결과 메시지
  Future<String> updateCollection({
    required String boxUuid,
    required CreateCollectionRequest request,
    String? imageFilePath,
  }) async {
    try {
      final jsonBytes = utf8.encode(
        jsonEncode({
          'boxName': request.boxName,
          'saving': request.saving,
          'target': request.target,
        }),
      );

      final formData = FormData.fromMap({
        'requestSaveBoxInfo': MultipartFile.fromBytes(
          jsonBytes,
          filename: 'request.json',
          contentType: MediaType('application', 'json'),
        ),
        if (imageFilePath != null && imageFilePath.isNotEmpty)
          'file': await MultipartFile.fromFile(
            imageFilePath,
            filename: p.basename(imageFilePath),
            contentType: MediaType('image', 'jpeg'),
          ),
      });

      // FormData 요청에서는 contentType을 명시적으로 제거
      final tempOptions = Options()..contentType = null;
      final response = await dio.put(
        '/children/boxes/$boxUuid',
        data: formData,
        options: tempOptions,
      );

      return response.data as String;
    } catch (e) {
      print('모으기 상자 수정 API 에러: $e');
      rethrow;
    }
  }

  Future<void> deleteCollection({
    required String boxUuid,
  }) async {
    try {
      await dio.delete(
        '/children/boxes/$boxUuid',
      );

      return;
    } catch (e) {
      print('모으기 상자 해지 API 에러: $e');
      rethrow;
    }
  }
}

// Provider 등록
final collectionApiProvider = Provider<CollectionApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CollectionApi(dio);
});
