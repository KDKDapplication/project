import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';
import 'package:kdkd_mobile/feature/common/models/notification_list_model.dart';

class NotificationApi {
  final Dio dio;

  NotificationApi(this.dio);

  /// 알림 목록 조회
  Future<NotificationListResponse?> getNotificationList({
    required int pageNum,
    required int display,
  }) async {
    try {
      final response = await dio.get(
        '/alert/list',
        queryParameters: {
          'pageNum': pageNum,
          'display': display,
        },
      );

      final data = Map<String, dynamic>.from(response.data);
      return NotificationListResponse.fromMap(data);
      // return NotificationMockData.getMockNotifications();
    } catch (e) {
      print('알림 조회 실패: $e');
      return null;
    }
  }

  /// 알림 전체 삭제
  Future<void> deleteNotificationList() async {
    try {
      await dio.delete(
        '/alert',
      );
    } catch (e) {
      print('알림 제거 실패: $e');
      return;
    }
  }
}

final notificationApiProvider = Provider<NotificationApi>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationApi(dio);
});
