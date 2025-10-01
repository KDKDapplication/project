import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

enum AppBarActionType { notification, setting, edit, none }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.useBackspace = false,
    this.title,
    this.isLogo = false,
    this.actionType = AppBarActionType.notification,
    this.centerTitle = true,
    this.onActionPressed,
  });

  /// 뒤로가기 버튼 사용 여부
  final bool useBackspace;

  /// 일반 텍스트 타이틀 (isLogo가 false일 때 사용)
  final String? title;

  /// 로고 텍스트("키득키득")를 표시할지 여부
  final bool isLogo;

  /// AppBar 우측 액션 버튼 타입 (알림 / 설정)
  final AppBarActionType? actionType;

  /// 타이틀 가운데 정렬 여부
  final bool centerTitle;

  /// 액션 버튼 클릭 시 호출될 콜백
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    Widget appBarTitle = isLogo
        ? const Text(
            "키득키득",
            style: TextStyle(
              fontFamily: "Chab",
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          )
        : Text(
            title ?? '',
            style: const TextStyle(
              fontFamily: "Pretendard",
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          );

    List<Widget>? appBarActions = [];

    switch (actionType) {
      case AppBarActionType.notification:
        appBarActions.add(
          IconButton(
            icon: SvgPicture.asset(
              'assets/svgs/notification.svg',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              context.push(AppRoutes.notification);
            },
          ),
        );
        break;
      case AppBarActionType.setting:
        appBarActions.add(
          IconButton(
            icon: SvgPicture.asset(
              'assets/svgs/setting.svg',
              width: 24,
              height: 24,
            ),
            onPressed: () {
              context.push(AppRoutes.setting);
            },
          ),
        );
        break;
      case AppBarActionType.edit:
        appBarActions.add(
          IconButton(
            icon: SvgPicture.asset(
              'assets/svgs/edit.svg',
              width: 24,
              height: 24,
            ),
            onPressed: onActionPressed,
          ),
        );
        break;
      case AppBarActionType.none:
        appBarActions = null;
      default:
        appBarActions = null;
    }

    return AppBar(
      leading: useBackspace
          ? IconButton(
              onPressed: () {
                context.pop();
              },
              icon: SvgPicture.asset(
                'assets/svgs/backspace.svg',
                width: 24,
                height: 24,
              ),
            )
          : null,
      centerTitle: centerTitle,
      title: appBarTitle,
      actions: appBarActions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
