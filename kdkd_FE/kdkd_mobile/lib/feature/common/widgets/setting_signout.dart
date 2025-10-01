import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/modal/custom_popup_modal.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/feature/common/pages/setting_page.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

SettingItem SettingSignout({required BuildContext context, required WidgetRef ref}) {
  return SettingItem(
    title: '회원 탈퇴',
    onTap: () {
      CustomPopupModal.show(
        context: context,
        popupType: PopupType.two,
        child: Column(
          children: [
            Text(
              '정말로 회원 탈퇴를 하시겠습니까?',
              style: AppFonts.bodyLarge.copyWith(
                color: AppColors.darkGray,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.redError.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.redError.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16,
                        color: AppColors.redError,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '삭제되는 데이터',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.redError,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 모든 계좌 정보 및 거래 내역\n• 자녀/부모 연결 정보\n• 미션 및 용돈 기록\n• 프로필 및 개인설정\n• 앱 내 모든 활동 데이터',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.redError,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '⚠️ 탈퇴 후 데이터 복구가 불가능합니다',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.redError,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        confirmText: '유지하기',
        confirmText2: '탈퇴하기',
        onConfirm: () {
          Navigator.pop(context);
        },
        onConfirm2: () async {
          Navigator.pop(context);

          // 최종 확인 다이얼로그
          final bool? finalConfirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                '최종 확인',
                style: AppFonts.headlineSmall.copyWith(
                  color: AppColors.redError,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                '정말로 탈퇴하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
                style: AppFonts.bodyMedium.copyWith(
                  color: AppColors.darkGray,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    '아니요',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.grayText,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.redError,
                    foregroundColor: AppColors.white,
                  ),
                  child: Text(
                    '네, 탈퇴합니다',
                    style: AppFonts.bodyMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );

          if (finalConfirm == true) {
            // 로딩 표시
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: CircularProgressIndicator(),
              ),
            );

            try {
              // TODO: 실제 회원 탈퇴 API 호출
              await Future.delayed(const Duration(seconds: 2)); // 임시 딜레이

              if (context.mounted) {
                Navigator.of(context).pop(); // 로딩 닫기
                context.go(AppRoutes.login);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('회원 탈퇴가 완료되었습니다'),
                    backgroundColor: AppColors.redError,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.of(context).pop(); // 로딩 닫기

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('회원 탈퇴 실패: ${e.toString()}'),
                    backgroundColor: AppColors.redError,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          }
        },
      );
    },
  );
}
