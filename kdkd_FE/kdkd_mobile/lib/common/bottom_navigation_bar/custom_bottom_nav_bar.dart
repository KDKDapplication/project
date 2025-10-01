import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      key: ValueKey(currentIndex), // currentIndex가 변경될 때마다 위젯 재생성
      height: 56,
      style: TabStyle.fixedCircle,
      backgroundColor: AppColors.grayBG,
      elevation: 0,
      shadowColor: Colors.black26,
      activeColor: AppColors.darkGray,
      color: AppColors.darkGray,
      items: [
        const TabItem(
          icon: _SvgIcon(asset: 'assets/svgs/home.svg'),
          activeIcon: _SvgIcon(asset: 'assets/svgs/home_selected.svg'),
          title: '홈',
        ),
        const TabItem(
          icon: _SvgIcon(asset: 'assets/svgs/wallet.svg'),
          activeIcon: _SvgIcon(asset: 'assets/svgs/wallet_selected.svg'),
          title: '모으기',
        ),
        TabItem(
          icon: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.grayBG,
                  const Color(0xffDCDCDC),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: _SvgIcon(
                    asset: 'assets/svgs/nfc.svg',
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          title: '송금',
        ),
        // TabItem(icon: Image.asset('assets/images/nfc.png')),
        const TabItem(
          icon: _SvgIcon(asset: 'assets/svgs/mission.svg'),
          activeIcon: _SvgIcon(asset: 'assets/svgs/mission_selected.svg'),
          title: '미션',
        ),
        TabItem(
          icon: Container(
            decoration: BoxDecoration(
              color: AppColors.grayBorder,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Image.asset('assets/images/kids_duck.png'),
          ),
          activeIcon: Container(
            decoration: BoxDecoration(
              color: AppColors.grayMedium,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Image.asset('assets/images/kids_duck.png'),
          ),
          title: '프로필',
        ),
      ],
      onTap: onTap,
      initialActiveIndex: currentIndex,
    );
  }
}

class _SvgIcon extends StatelessWidget {
  final String asset;
  final Color? color;
  final double? size;

  const _SvgIcon({required this.asset, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    final svgColor = color ?? AppColors.darkGray;

    return SizedBox(
      width: size ?? 24,
      height: size ?? 24,
      child: SvgPicture.asset(
        asset,
        colorFilter: ColorFilter.mode(svgColor, BlendMode.srcIn),
        alignment: Alignment.center,
      ),
    );
  }
}
