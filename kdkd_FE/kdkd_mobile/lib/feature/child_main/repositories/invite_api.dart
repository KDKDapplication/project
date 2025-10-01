import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';

class InviteResponse {
  final bool linked;
  final String relationUuid;

  const InviteResponse({
    required this.linked,
    required this.relationUuid,
  });

  factory InviteResponse.fromJson(Map<String, dynamic> json) => InviteResponse(
        linked: json['linked'] as bool,
        relationUuid: json['relationUuid'] as String,
      );

  Map<String, dynamic> toJson() => {
        'linked': linked,
        'relationUuid': relationUuid,
      };
}

class InviteApi {
  final Dio dio;

  InviteApi(this.dio);

  /// 초대 코드로 부모-자녀 관계 활성화
  ///
  /// [code] 부모가 생성한 초대 코드
  ///
  /// Returns [InviteResponse] 연결 성공 시 관계 정보
  Future<InviteResponse> activateInvite(String code) async {
    try {
      final response = await dio.post(
        'children/invites/activate?code=$code',
      );

      return InviteResponse.fromJson(Map<String, dynamic>.from(response.data));
    } catch (e) {
      rethrow;
    }
  }
}

// Provider 등록
final inviteApiProvider = Provider<InviteApi>((ref) {
  final dio = ref.watch(dioProvider);
  return InviteApi(dio);
});
