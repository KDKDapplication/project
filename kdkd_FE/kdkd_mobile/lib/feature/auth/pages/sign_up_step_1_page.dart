import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/progress/custom_progress_bar.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/feature/auth/models/sign_up_model.dart';
import 'package:kdkd_mobile/feature/auth/providers/sign_up_provider.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

class SignUpStep1Page extends ConsumerWidget {
  const SignUpStep1Page({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '회원가입',
        useBackspace: true,
        actionType: AppBarActionType.none,
      ),
      body: Padding(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomProgressBar(value: 0.5),
            const SizedBox(height: 22),
            Text(
              "당신은 부모인가요, 자녀인가요?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: -1.4,
              ),
            ),
            const SizedBox(height: 54),
            GestureDetector(
              onTap: () {
                // 부모 선택 시 처리
                ref.read(signUpProvider.notifier).setUserRole(UserRole.parent);
                context.push(AppRoutes.signUpStep2);
              },
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.basicShadow,
                        blurRadius: 11.8,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '자녀에게 용돈을 주며 관리할거에요.',
                              style: TextStyle(
                                color: AppColors.white,
                                letterSpacing: -.5,
                              ),
                            ),
                            SizedBox(height: 14),
                            Text(
                              '부모 입니다.',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '시작하기 ->',
                          style: TextStyle(
                            color: AppColors.white,
                            letterSpacing: -.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                // 자녀 선택 시 처리
                ref.read(signUpProvider.notifier).setUserRole(UserRole.child);
                context.push(AppRoutes.signUpStep2);
              },
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.basicShadow,
                        blurRadius: 11.8,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '용돈을 받으며 관리 할래요!',
                              style: TextStyle(
                                color: AppColors.white,
                                letterSpacing: -.5,
                              ),
                            ),
                            SizedBox(height: 14),
                            Text(
                              '자녀 입니다.',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -.5,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '시작하기 ->',
                          style: TextStyle(
                            color: AppColors.white,
                            letterSpacing: -.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
