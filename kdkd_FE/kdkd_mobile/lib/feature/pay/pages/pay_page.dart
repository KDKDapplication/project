import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/common/toggle/custom_toggle.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/feature/auth/models/profile_model.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:kdkd_mobile/feature/pay/widgets/payment.dart';
import 'package:kdkd_mobile/feature/pay/widgets/tagging.dart';

class PayPage extends ConsumerStatefulWidget {
  const PayPage({super.key});

  @override
  ConsumerState<PayPage> createState() => _PayPageState();
}

class _PayPageState extends ConsumerState<PayPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const Payment(),
    const Tagging(),
  ];

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

    // 역할에 따른 배경색 설정
    Color backgroundColor = AppColors.primary;
    Color textColor = isParent ? AppColors.white : AppColors.black;

    if (_selectedIndex == 1 && isParent == false) {
      backgroundColor = const Color.fromARGB(255, 255, 243, 135);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsetsGeometry.only(left: AppConst.padding),
          child: Text(
            '키득 페이 NFC',
            style: AppFonts.headlineMedium.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Padding(
              padding: EdgeInsetsGeometry.only(right: AppConst.padding),
              child: SvgPicture.asset(
                'assets/svgs/close.svg',
                color: textColor,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
            CustomToggle(
              textColor: textColor,
              backgroundColor: backgroundColor,
              isParent: isParent,
              selectedIndex: _selectedIndex,
              onToggle: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
            const SizedBox(height: 65),
          ],
        ),
      ),
    );
  }
}
