import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class NotificationPermission {
  /// Android 13+ 런타임 알림 권한 확인 및 요청
  static Future<void> ensurePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }
  }
}
