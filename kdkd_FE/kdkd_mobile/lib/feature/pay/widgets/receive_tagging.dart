import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/feature/auth/models/auth_model.dart';
import 'package:kdkd_mobile/feature/auth/providers/auth_provider.dart';

class ReceiveTagging extends ConsumerStatefulWidget {
  const ReceiveTagging({super.key});

  @override
  ConsumerState<ReceiveTagging> createState() => _ReceiveTaggingState();
}

class _ReceiveTaggingState extends ConsumerState<ReceiveTagging> {
  final _blePeripheral = FlutterBlePeripheral();

  // KDKD 앱 전용 서비스 UUID (send_tagging과 동일)
  static const String _serviceUuid = "4B444444-4444-4444-4444-444444444444";

  Timer? _timer;
  int _remainingSeconds = 60;
  bool _isRequesting = true;
  bool _isApproved = false;
  String _approvedAmount = "";
  StreamSubscription<RemoteMessage>? _fcmSubscription;

  @override
  void initState() {
    super.initState();
    debugPrint("🚀 ReceiveTagging 페이지 시작됨!");
    _startAdvertising();
    _startTimer();
    _setupFCMListener();
  }

  void _setupFCMListener() {
    // FCM 메시지 수신 리스너 설정
    _fcmSubscription = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("🔔 FCM 메시지 수신: ${message.data}");

      // 용돈 승인 알림인지 확인
      if (message.data['type'] == 'allowance_approved') {
        setState(() {
          _isApproved = true;
          _isRequesting = false;
          _approvedAmount = message.data['amount'] ?? "0";
        });

        // 타이머 중지 및 BLE 광고 중지
        _timer?.cancel();
        _blePeripheral.stop();

        debugPrint("✅ 용돈 승인됨: $_approvedAmount원");
      }
    });
  }

  Future<void> _startAdvertising() async {
    try {
      // 실제 로그인한 사용자 정보 가져오기
      final ExistingUserAuth authData = (ref.read(authStateProvider) as Success).data;

      // authData에서 실제 사용자 정보 추출
      // AuthModel의 구조에 맞게 수정해야 합니다
      final uuid = authData.userUuid; // 또는 authData.uuid

      // KDKD 앱 식별 데이터: "kdkd|자녀UUID|사용자명"
      final advertisementData = "kdkd|$uuid";

      // 문자열을 UTF-8로 인코딩하여 byte 배열로 변환
      final dataBytes = Uint8List.fromList(utf8.encode(advertisementData));

      final advertiseData = AdvertiseData(
        includeDeviceName: true,
        serviceUuid: _serviceUuid, // KDKD 서비스 UUID 추가
        manufacturerId: 1234,
        manufacturerData: dataBytes,
      );

      debugPrint("🔄 BLE 광고 시작 시도...");
      debugPrint("📡 서비스 UUID: $_serviceUuid");
      debugPrint("📝 광고 데이터: $advertisementData");
      debugPrint("🔢 데이터 바이트: $dataBytes");

      await _blePeripheral.start(advertiseData: advertiseData);
      debugPrint("✅ BLE 광고 시작됨!");
    } catch (e) {
      debugPrint("❌ BLE 광고 에러: $e");
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 60;
      _isRequesting = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isRequesting = false; // 요청 시간 종료
        });
        _blePeripheral.stop();
        debugPrint("⏹️ BLE 광고 종료됨");
      }
    });
  }

  void _retryRequest() {
    setState(() {
      _isApproved = false;
      _approvedAmount = "";
    });
    _startAdvertising();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _blePeripheral.stop();
    _fcmSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '용돈 받기',
          style: AppFonts.headlineLarge.copyWith(color: AppColors.black),
        ),
        const SizedBox(height: 24),
        _isApproved
            ? Column(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '용돈 승인됨!',
                    style: AppFonts.titleLarge.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_approvedAmount원',
                    style: AppFonts.headlineMedium.copyWith(color: AppColors.black),
                  ),
                ],
              )
            : _isRequesting
                ? Text(
                    '요청 중... ($_remainingSeconds초)',
                    style: AppFonts.titleSmall.copyWith(color: AppColors.black),
                  )
                : Column(
                    children: [
                      Text(
                        '시간 초과',
                        style: AppFonts.titleSmall.copyWith(color: AppColors.redError),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _retryRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.violet,
                          foregroundColor: AppColors.black,
                        ),
                        child: const Text("재요청"),
                      ),
                    ],
                  ),
      ],
    );
  }
}
