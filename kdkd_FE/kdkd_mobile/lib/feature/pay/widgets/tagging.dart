import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kdkd_mobile/common/state/ui_state.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/feature/auth/models/profile_model.dart';
import 'package:kdkd_mobile/feature/auth/providers/profile_provider.dart';
import 'package:kdkd_mobile/feature/pay/widgets/receive_tagging.dart';
import 'package:kdkd_mobile/feature/pay/widgets/send_tagging.dart';

class Tagging extends ConsumerWidget {
  const Tagging({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    Color svgColor = isParent ? AppColors.white : AppColors.primary;

    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                profileState.when(
                  idle: () => const SizedBox(),
                  loading: () => const CircularProgressIndicator(),
                  success: (profile, isFallback, fromCache) {
                    return Column(
                      children: [
                        SvgPicture.asset(
                          color: svgColor,
                          profile.r == role.PARENT ? 'assets/svgs/post.svg' : 'assets/svgs/get.svg',
                        ),
                        const SizedBox(height: 40),
                        if (profile.r == role.PARENT) const SendTagging() else const ReceiveTagging(),
                      ],
                    );
                  },
                  failure: (error, message) => const SizedBox(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
