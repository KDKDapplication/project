import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/modal/custom_popup_modal.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/feature/auth/providers/auth_provider.dart';
import 'package:kdkd_mobile/feature/common/pages/setting_page.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

// 주요 Provider imports
import 'package:kdkd_mobile/feature/common/providers/history_provider.dart';
import 'package:kdkd_mobile/feature/common/providers/notification_provider.dart';

SettingItem SettingLogout({required BuildContext context, required WidgetRef ref}) {
  return SettingItem(
    title: '로그아웃',
    onTap: () {
      CustomPopupModal.show(
        context: context,
        popupType: PopupType.two,
        child: Column(
          children: [
            Text(
              '정말 로그아웃 하시겠습니까?',
              style: AppFonts.bodyLarge.copyWith(
                color: AppColors.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grayBG,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppColors.grayText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '로그아웃 시 변경사항',
                        style: AppFonts.bodySmall.copyWith(
                          color: AppColors.grayText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 다시 로그인이 필요합니다\n• 로컬 캐시 데이터가 삭제됩니다\n• 알림 설정이 초기화됩니다',
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.grayText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        confirmText: '아니요',
        confirmText2: '로그아웃',
        onConfirm: () {
          Navigator.pop(context);
        },
        onConfirm2: () async {
          Navigator.pop(context);

          // 로딩 표시
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          try {
            // 로그아웃 전에 모든 사용자 관련 provider 상태 초기화
            ref.invalidate(historyProvider);
            ref.invalidate(notificationListProvider);

            // 실제 로그아웃 로직
            await ref.read(authStateProvider.notifier).signOut();

            if (context.mounted) {
              Navigator.of(context).pop(); // 로딩 닫기
              context.go(AppRoutes.login);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('성공적으로 로그아웃되었습니다'),
                  backgroundColor: AppColors.mint,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.of(context).pop(); // 로딩 닫기

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('로그아웃 실패: ${e.toString()}'),
                  backgroundColor: AppColors.redError,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
      );
    },
  );
}
