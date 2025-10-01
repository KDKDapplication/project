import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/appbar/custom_app_bar.dart';
import 'package:kdkd_mobile/common/bottom_navigation_bar/custom_bottom_nav_bar.dart';
import 'package:kdkd_mobile/feature/child_collection/pages/child_collection_page.dart';
import 'package:kdkd_mobile/feature/child_main/pages/child_main_page.dart';
import 'package:kdkd_mobile/feature/child_main/providers/child_tab_provider.dart';
import 'package:kdkd_mobile/feature/child_mission/pages/child_mission_page.dart';
import 'package:kdkd_mobile/feature/common/pages/profile_page.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

class ChildRootPage extends ConsumerStatefulWidget {
  const ChildRootPage({super.key});

  @override
  ConsumerState<ChildRootPage> createState() => _ChildRootPageState();
}

class _ChildRootPageState extends ConsumerState<ChildRootPage> {
  final PageController _pageController = PageController();

  final List<Widget> _widgetOptions = <Widget>[
    const ChildMainPage(), // 홈
    const ChildCollectionPage(), // 모으기
    const ChildMissionPage(), // 미션
    const ProfilePage(), // 프로필
  ];

  static const List<String> _appBarTitles = [
    '', // 홈
    '모으기 상자',
    '미션천국',
    '마이',
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // NFC는 풀 푸시, index는 그대로 유지
      context.push(AppRoutes.pay);
      return;
    }

    // provider 상태 업데이트 (ref.listen에서 페이지 변경 처리됨)
    ref.read(childTabProvider.notifier).state = index;
  }

  @override
  void initState() {
    super.initState();
    // provider 초기값 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(childTabProvider.notifier).state = 0;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(childTabProvider);

    // provider 상태 구독하여 외부에서 탭 변경 시 처리
    ref.listen<int>(childTabProvider, (previous, next) {
      if (previous != null && previous != next) {
        _pageController.animateToPage(
          next > 2 ? next - 1 : next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    int pageIndex = selectedIndex > 2 ? selectedIndex - 1 : selectedIndex;

    return Scaffold(
      appBar: CustomAppBar(
        isLogo: selectedIndex == 0,
        title: (selectedIndex == 0 || selectedIndex == 2) ? null : _appBarTitles[pageIndex],
        actionType: selectedIndex == 4 ? AppBarActionType.setting : AppBarActionType.notification,
      ),
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (pageIndex) {
          // PageView의 물리적 페이지 변경은 ref.listen에서 처리하므로
          // 여기서는 provider 업데이트 불필요
        },
        children: _widgetOptions,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
