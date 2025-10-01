import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/auth/models/profile_model.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:kdkd_mobile/feature/common/widgets/setting_logout.dart';
import 'package:kdkd_mobile/feature/common/widgets/setting_signout.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

enum SettingItemType { arrow, toggle }

class SettingItem {
  final String title;
  final VoidCallback onTap;
  final String desc;
  final SettingItemType type;

  SettingItem({
    required this.title,
    required this.onTap,
    this.desc = '',
    this.type = SettingItemType.arrow,
  });
}

class SettingPage extends ConsumerWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UiState<Profile> profile = ref.watch(profileProvider);

    final Widget body = profile.when(
      idle: () => Center(
        child: CircularProgressIndicator(),
      ),
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
      failure: (e, msg) => Center(
        child: Text('설정 페이지를 불러올 수 없습니다.'),
      ),
      refreshing: (prev) => Center(
        child: Text('설정 페이지를 불러올 수 없습니다.'),
      ),
      success: (data, isFallback, fromCache) {
        return Column(
          children: [
            _SettingCategory(
              category: '기능',
              items: [
                if (data.r == role.PARENT)
                  SettingItem(
                    title: '부모 코드 생성',
                    onTap: () {
                      context.push(AppRoutes.parentMainCreateCode);
                    },
                  ),
                if (data.r == role.PARENT)
                  SettingItem(
                    title: '자동이체 설정',
                    onTap: () {
                      context.push(AppRoutes.settingAutoDebit);
                    },
                  ),
                if (data.r == role.CHILD)
                  SettingItem(
                    title: '대출하기',
                    // 하단 모달
                    onTap: () {
                      context.push(AppRoutes.childLoanPage);
                    },
                  ),
                SettingItem(
                  title: 'QR Scanner',
                  onTap: () {
                    context.push(AppRoutes.qrScnnerPage);
                  },
                ),
                if (data.r == role.CHILD)
                  SettingItem(
                    title: '키덕이키우기',
                    onTap: () {
                      context.push(AppRoutes.characterDisplay);
                    },
                  ),
              ],
            ),
            _SettingCategory(
              category: '계정',
              items: [
                SettingItem(
                  title: '프로필 수정',
                  onTap: () {
                    context.push(AppRoutes.settingProfile);
                  },
                ),
                SettingLogout(context: context, ref: ref),
                SettingSignout(context: context, ref: ref),
              ],
            ),
          ],
        );
      },
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: "설정",
        useBackspace: true,
        actionType: AppBarActionType.none,
      ),
      body: body,
    );
  }
}

class _SettingCategory extends StatelessWidget {
  const _SettingCategory({
    super.key,
    required this.category,
    required this.items,
  });

  final String category;
  final List<SettingItem> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppConst.padding,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: AppFonts.titleMedium,
          ),
          SizedBox(
            height: 16,
          ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.basicShadow,
                  blurRadius: 11.8,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: items
                  .expand(
                    (item) => [
                      InkWell(
                        onTap: item.onTap,
                        child: Row(
                          children: [
                            Text(
                              item.title,
                              style: AppFonts.bodyMedium,
                            ),
                            Spacer(),
                            Text(
                              item.desc,
                              style: AppFonts.bodyMedium,
                            ),
                            SvgPicture.asset('assets/svgs/right_arrow.svg'),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  )
                  .toList()
                ..removeLast(),
            ),
          ),
        ],
      ),
    );
  }
}
