import 'package:flutter/material.dart';
import 'package:kdkd_mobile/common/container/custom_container.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';

class EmptyChildrenState extends StatelessWidget {
  const EmptyChildrenState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(36),
          child: CustomContainer(
            width: double.infinity,
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "등록 된 자녀가 없습니다",
                  style: AppFonts.titleMedium.copyWith(
                    color: AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}