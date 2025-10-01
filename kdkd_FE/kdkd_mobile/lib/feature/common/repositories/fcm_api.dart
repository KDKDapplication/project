import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/core/network/dio_client.dart';

class FcmApi {
  final Dio dio;

  FcmApi(this.dio);

  Future<void> registerFcm() async {
    try {
      String? token = await getFcmToken();

      await dio.post(
        '/fcm/register',
        data: {
          'token': token,
        },
      );
    } catch (e) {
      print('토큰 저장 실패');
    }
  }

  Future<String?> getFcmToken() async {
    try {
      // iOS에서는 APNS 토큰이 먼저 설정되어야 함
      if (Platform.isIOS) {
        await FirebaseMessaging.instance.getAPNSToken();
      }

      final token = await FirebaseMessaging.instance.getToken();
      return token;
    } catch (e) {
      print("⚠️ FCM Token Error: $e");
    }
    return null;
  }
}

final fcmApiProvider = Provider<FcmApi>((ref) {
  final dio = ref.watch(dioProvider);
  return FcmApi(dio);
});
