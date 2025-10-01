import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../feature/parent_common/providers/selected_child_provider.dart';
import '../../feature/parent_loan/providers/loan_provider.dart';
import 'notification_channel.dart';

class NotificationService with WidgetsBindingObserver {
  static final FlutterLocalNotificationsPlugin _plugin = flutterLocalNotificationsPlugin;
  static bool _isAppInForeground = true;
  static NotificationService? _instance;
  static ProviderContainer? _container;

  /// 초기화 (앱 실행 시 1회 호출)
  static Future<void> initialize(ProviderContainer container) async {
    _instance ??= NotificationService();
    _container = container;
    WidgetsBinding.instance.addObserver(_instance!);
    const androidInit = AndroidInitializationSettings('@drawable/ic_stat_notification');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(initSettings);

    // Android 알림 채널 생성
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(highImportanceChannel);
    }

    // iOS 포그라운드 표시 옵션 (배너/소리/배지 허용)
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // 포그라운드 메시지 자동 알림 표시
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isAppInForeground = true;
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        _isAppInForeground = false;
        break;
      case AppLifecycleState.hidden:
        _isAppInForeground = false;
        break;
    }
  }

  /// 앱이 포그라운드인지 확인
  static bool get isAppInForeground => _isAppInForeground;

  /// 정리 (필요시 호출)
  static void dispose() {
    if (_instance != null) {
      WidgetsBinding.instance.removeObserver(_instance!);
      _instance = null;
    }
    _container = null;
  }

  /// FCM 메시지 처리
  static Future<void> _handleMessage(RemoteMessage message) async {
    // 앱이 포그라운드에 있을 때만 처리
    if (_isAppInForeground && _container != null) {
      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';

      // "빌리기 신청하였습니다" 메시지 감지
      if (body.contains('빌리기 신청하였습니다') || title.contains('빌리기 신청하였습니다')) {
        await _refreshLoanData();
      }
    }

    // 기본 알림 표시
    await showNotification(message);
  }

  /// 빌리기 데이터 새로고침
  static Future<void> _refreshLoanData() async {
    if (_container == null) return;

    try {
      // 선택된 자녀가 있으면 빌리기 상태 새로고침
      final selectedChild = _container!.read(selectedChildProvider);
      if (selectedChild != null) {
        // 방법 1: parent_loan_provider 직접 새로고침
        await _container!.read(parentLoanProvider.notifier).getLoanStatus(selectedChild.childUuid);

        // 방법 2: selected_child_provider 새로고침으로 연쇄 효과 (필요시 활성화)
        // _container!.read(selectedChildProvider.notifier).selectChild(selectedChild.childUuid);

        print('빌리기 신청 알림 감지 - ${selectedChild.childName} 데이터 새로고침');
      } else {
        print('빌리기 신청 알림 감지 - 선택된 자녀가 없어 새로고침 건너뜀');
      }
    } catch (e) {
      print('빌리기 데이터 새로고침 실패: $e');
    }
  }

  /// 로컬 알림 표시
  static Future<void> showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // 앱이 포그라운드에 있을 때만 로컬 알림 표시하지 않도록 설정 (선택사항)
    // if (_isAppInForeground) return;

    final androidDetails = AndroidNotificationDetails(
      highImportanceChannel.id,
      highImportanceChannel.name,
      channelDescription: highImportanceChannel.description,
      priority: Priority.high,
      importance: Importance.high,
    );

    const iosDetails = DarwinNotificationDetails();

    await _plugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: message.data.toString(),
    );
  }
}
