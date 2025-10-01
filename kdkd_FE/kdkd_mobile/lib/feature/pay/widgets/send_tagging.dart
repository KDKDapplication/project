import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/text_field/custom_text_field.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/feature/parent_common/providers/child_accounts_provider.dart';
import 'package:kdkd_mobile/feature/pay/providers/pay_provider.dart';

class SendTagging extends ConsumerStatefulWidget {
  const SendTagging({super.key});

  @override
  ConsumerState<SendTagging> createState() => _SendTaggingState();
}

class _SendTaggingState extends ConsumerState<SendTagging> {
  final _ble = FlutterReactiveBle();
  final TextEditingController _amountController = TextEditingController();

  // KDKD 앱 전용 서비스 UUID (kdkd를 기반으로 생성)
  static const String _serviceUuid = "4B444444-4444-4444-4444-444444444444";
  final int rssiThreshold = -42;
  StreamSubscription<DiscoveredDevice>? _scanSub;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isScanning = false;

  @override
  void dispose() {
    _scanSub?.cancel();
    _timer?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  void _startScan() {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("보낼 금액을 입력하세요")),
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _remainingSeconds = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _stopScan();
      }
    });

    _scanSub = _ble.scanForDevices(withServices: [Uuid.parse(_serviceUuid)]).listen((device) {
      if (device.rssi > rssiThreshold) {
        _stopScan();
        _confirmScan(device);
      }
    });
  }

  void _stopScan() {
    _scanSub?.cancel();
    _timer?.cancel();
    setState(() {
      _isScanning = false;
    });
  }

  void _confirmScan(DiscoveredDevice device) {
    final manufacturerData = _parseManufacturerData(device.manufacturerData);

    if (!manufacturerData['isKdkdApp']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("KDKD 앱이 아닙니다.")),
      );
      return;
    }

    final childUuid = manufacturerData['childUuid'];
    if (childUuid == null || childUuid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("자녀 정보를 확인할 수 없습니다.")),
      );
      return;
    }

    final childAccountsController = ref.read(childAccountsProvider.notifier);
    final childAccount = childAccountsController.getAccountByChildUuid(childUuid);

    if (childAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("등록되지 않은 자녀입니다.")),
      );
      return;
    }

    _sendMoneyToChild(childUuid, childAccount.childName);
  }

  Map<String, dynamic> _parseManufacturerData(List<int> data) {
    if (data.isEmpty) {
      return {'isKdkdApp': false};
    }

    try {
      final actualData = data.length > 2 ? data.sublist(2) : data;

      String dataString;
      try {
        dataString = utf8.decode(actualData);
      } catch (e) {
        dataString = String.fromCharCodes(actualData);
      }

      final parts = dataString.split('|');
      final isKdkdApp = parts.isNotEmpty && parts[0] == 'kdkd';

      return {
        'isKdkdApp': isKdkdApp,
        'childUuid': parts.length > 1 ? parts[1] : null,
      };
    } catch (e) {
      return {'isKdkdApp': false};
    }
  }

  Future<void> _sendMoneyToChild(String childUuid, String childName) async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("송금할 금액을 입력해주세요.")),
      );
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("올바른 금액을 입력해주세요.")),
      );
      return;
    }

    try {
      final success = await ref.read(payProvider.notifier).sendAllowance(
            childUuid: childUuid,
            amount: amount,
          );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$childName님에게 $amount원 송금이 완료되었습니다!")),
        );
        _amountController.clear();
        _stopScan();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("송금에 실패했습니다. 다시 시도해주세요.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("송금 실패: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '용돈 보내기',
          style: AppFonts.headlineLarge.copyWith(color: AppColors.white),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _amountController,
          placeholder: "보낼 금액을 입력하세요",
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        _isScanning
            ? Column(
                children: [
                  Text(
                    "요청 중... ($_remainingSeconds초)",
                    style: AppFonts.titleSmall.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _stopScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redError,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text("취소"),
                  ),
                ],
              )
            : ElevatedButton(
                onPressed: _startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet,
                  foregroundColor: AppColors.white,
                ),
                child: const Text("전송"),
              ),
      ],
    );
  }
}
