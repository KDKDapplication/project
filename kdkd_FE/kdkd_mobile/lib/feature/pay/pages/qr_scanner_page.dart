import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/button/custom_button_Large.dart';
import 'package:kdkd_mobile/common/text_field/custom_text_field_with_label.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/pay/providers/pay_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends ConsumerStatefulWidget {
  const QrScannerPage({super.key});
  @override
  ConsumerState<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends ConsumerState<QrScannerPage> {
  late MobileScannerController cameraController;
  final TextEditingController _amountController = TextEditingController();
  String? scannedData;
  bool _isScanning = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: [BarcodeFormat.qrCode],
    );
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // 위치 서비스 활성화 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('📍 위치 서비스가 비활성화되어 있습니다.');
        return;
      }

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('📍 위치 권한이 거부되었습니다.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('📍 위치 권한이 영구적으로 거부되었습니다.');
        return;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      print('📍 현재 위치: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('📍 위치 정보 가져오기 실패: $e');
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;

    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        print('🔍 스캔된 QR 데이터: $rawValue');
        print('📱 바코드 타입: ${barcode.type}');
        print('📐 바코드 형식: ${barcode.format}');

        // 중복 스캔 방지
        cameraController.stop();

        setState(() {
          scannedData = rawValue;
          _isScanning = false;
        });

        _processScannedData(rawValue);
        break; // 첫 번째 유효한 QR 코드만 처리
      }
    }
  }

  void _processScannedData(String childUuid) async {
    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("올바른 금액을 입력해주세요")),
      );
      return;
    }

    // 결제 실행
    try {
      final success = await ref.read(payProvider.notifier).postPay(
            childUuid: childUuid,
            amount: amount,
            latitude: _currentPosition?.latitude,
            longitude: _currentPosition?.longitude,
          );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$childUuid 계정의 $amount원 결제 완료되었습니다!")),
        );
        _amountController.clear();
        setState(() {
          scannedData = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("결제에 실패했습니다")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("결제 실패: ${e.toString()}")),
      );
    }
  }

  void _startScan() {
    if (_amountController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("결제할 금액을 입력해주세요")),
      );
      return;
    }

    setState(() {
      _isScanning = true;
      scannedData = null;
    });

    // 카메라 재시작
    cameraController.start();
    print('📷 카메라 스캔 시작됨');
  }

  void _stopScan() {
    setState(() {
      _isScanning = false;
    });
    cameraController.stop();
    print('📷 카메라 스캔 중지됨');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "QR 결제",
        useBackspace: true,
        actionType: AppBarActionType.none,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppConst.padding),
        child: Column(
          children: [
            // 카메라 영역
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isScanning ? AppColors.mint : AppColors.grayBorder,
                  width: 2,
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: MobileScanner(
                      controller: cameraController,
                      onDetect: _onDetect,
                    ),
                  ),
                  // 스캔 전 가이드
                  if (!_isScanning)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Text(
                            "금액 입력 후\n결제하기 버튼을 눌러주세요",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 스캔 중 UI
                  if (_isScanning)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Stack(
                        children: [
                          // 스캔 가이드 박스
                          Center(
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.mint,
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  "QR 코드를\n여기에 맞춰주세요",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 3,
                                        color: Colors.black54,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 손전등 버튼
                          Positioned(
                            top: 16,
                            right: 16,
                            child: GestureDetector(
                              onTap: () => cameraController.toggleTorch(),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.flash_on,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),

                          // 취소 버튼
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: GestureDetector(
                              onTap: _stopScan,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 위치 정보 상태 표시
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _currentPosition != null ? AppColors.mint.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _currentPosition != null ? AppColors.mint : Colors.orange,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _currentPosition != null ? Icons.location_on : Icons.location_off,
                    size: 20,
                    color: _currentPosition != null ? AppColors.mint : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentPosition != null ? "위치 정보 획득 완료" : "위치 정보 획득 중...",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _currentPosition != null ? AppColors.mint : Colors.orange,
                    ),
                  ),
                  const Spacer(),
                  if (_currentPosition == null)
                    GestureDetector(
                      onTap: _getCurrentLocation,
                      child: const Icon(
                        Icons.refresh,
                        size: 20,
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 금액 입력
            CustomTextFieldWithLabel(
              title: "결제 금액",
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {});
              },
            ),

            const SizedBox(height: 32),

            // 스캔하기 버튼
            CustomButtonLarge(
              text: _isScanning ? "결제 중..." : "결제하기",
              onPressed: _isScanning ? null : _startScan,
            ),

            const SizedBox(height: 24),

            // 스캔 결과 표시
            if (scannedData != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mint.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mint),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "결제 완료!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mint,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "결제된 데이터: ${scannedData!.length > 20 ? '${scannedData!.substring(0, 20)}...' : scannedData!}",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.grayText,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
