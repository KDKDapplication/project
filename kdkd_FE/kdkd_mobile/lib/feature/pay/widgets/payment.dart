import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/feature/auth/models/auth_model.dart';
import 'package:kdkd_mobile/feature/auth/models/profile_model.dart';
import 'package:kdkd_mobile/feature/auth/providers/auth_provider.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class Payment extends ConsumerStatefulWidget {
  const Payment({super.key});

  @override
  ConsumerState<Payment> createState() => _PaymentState();
}

class _PaymentState extends ConsumerState<Payment> {
  late QrImage qrImage;

  @override
  void initState() {
    super.initState();
    _initializeQR();
  }

  void _initializeQR() {
    // authStateProvider에서 사용자 UUID 가져오기
    final authState = ref.read(authStateProvider);

    String userUuid = '';
    authState.when(
      idle: () => userUuid = '',
      loading: () => userUuid = '',
      success: (authModel, isFallback, fromCache) {
        if (authModel is ExistingUserAuth) {
          userUuid = authModel.userUuid;
        }
      },
      failure: (error, message) => userUuid = '',
    );

    print('QR 데이터 (사용자 UUID): $userUuid');

    final qrCode = QrCode(
      8,
      QrErrorCorrectLevel.H,
    )..addData(userUuid); // 사용자 UUID를 데이터로 사용

    qrImage = QrImage(qrCode);
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);

    // 부모/자녀 역할 판별
    bool isParent = profileState.when(
      idle: () => true,
      loading: () => true,
      success: (profile, isFallback, fromCache) {
        return profile.r == role.PARENT;
      },
      failure: (error, message) => true,
      refreshing: (prev) => true,
    );

    return Center(
      child: SizedBox(
        width: 280,
        height: 280,
        child: PrettyQrView(
          qrImage: qrImage,
          decoration: const PrettyQrDecoration(
            // 둥글둥글한 심볼 스타일
            shape: PrettyQrSmoothSymbol(
              color: AppColors.white,
              roundFactor: 1, // 최대 둥글게
            ),
            // 로고 이미지 삽입
            image: PrettyQrDecorationImage(
              image: AssetImage('assets/images/kids_duck.png'),
              position: PrettyQrDecorationImagePosition.embedded, // 중앙 삽입
            ),
            // 배경색
          ),
        ),
      ),
    );
  }
}
