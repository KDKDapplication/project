import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service.dart';

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

/// FCM 초기화 + 리스너 등록
final fcmProvider = Provider<void>((ref) {
  final fcm = ref.watch(firebaseMessagingProvider);

  FirebaseMessaging.onMessage.listen((message) {
    NotificationService.showNotification(message);
  });
});
