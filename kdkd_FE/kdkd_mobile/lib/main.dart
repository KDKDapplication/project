import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kdkd_mobile/core/theme/app_theme.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/config/app_config.dart';
import 'core/notification/notification_permission.dart';
import 'core/notification/notification_service.dart';
import 'firebase_options.dart';

/// 백그라운드 메시지 핸들러 (최상위 함수)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // TODO: 서버 동기화, 로깅 등
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 환경변수 로드
  await dotenv.load(fileName: ".env");

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 알림 권한 요청
  await NotificationPermission.ensurePermission();

  await dotenv.load(fileName: ".env");

  await initializeDateFormatting('ko_KR');

  // BLE 권한
  await requestBlePermissions();

  // 네이버 지도 초기화
  await FlutterNaverMap().init(
    clientId: '2r0an6fpqn',
    onAuthFailed: (ex) {
      switch (ex) {
        case NQuotaExceededException(:final message):
          print("사용량 초과 (message: $message)");
          break;
        case NUnauthorizedClientException() || NClientUnspecifiedException() || NAnotherAuthFailedException():
          print("인증 실패: $ex");
          break;
      }
    },
  );

  final container = ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(
        const AppConfig(
          baseUrl: 'http://j13e106.p.ssafy.io:8080/',
          enableLog: true,
        ),
      ),
    ],
  );

  // FCM 알림 서비스 초기화 (ProviderContainer 전달)
  await NotificationService.initialize(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  void debugPrintFcmToken() async {
    try {
      // iOS에서는 APNS 토큰이 먼저 설정되어야 함
      if (Platform.isIOS) {
        await FirebaseMessaging.instance.getAPNSToken();
      }

      final token = await FirebaseMessaging.instance.getToken();
      // print("✅ FCM Token: $token");
    } catch (e) {
      print("⚠️ FCM Token Error: $e");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrintFcmToken();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: buildAppTheme(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('ko', 'KR'),
    );
  }
}

Future<void> requestBlePermissions() async {
  await [
    Permission.bluetoothScan,
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect,
    Permission.location,
  ].request();
}
