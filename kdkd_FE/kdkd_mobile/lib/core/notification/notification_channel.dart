import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 중요 알림 채널 (Android 8.0+ 이상에서 필요)
const AndroidNotificationChannel highImportanceChannel = AndroidNotificationChannel(
  'high_importance_channel', // 채널 ID (고유해야 함)
  'High Importance Notifications', // 채널 이름 (설정 > 알림에서 표시됨)
  description: 'Heads-up notifications for important messages',
  importance: Importance.high, // 우선순위 높음 → Heads-up 알림 허용
  playSound: true, // 사운드 기본 허용
);

/// Local Notifications Plugin (전역 싱글톤)
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
