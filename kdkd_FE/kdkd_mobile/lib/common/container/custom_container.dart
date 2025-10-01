// kdkd_mobile/lib/common/container/custom_container.dart

import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';

class CustomContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? color;
  final Widget? child;
  final Clip clipBehavior; // 1. 이 줄을 추가하세요.

  const CustomContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.color = AppColors.white,
    this.child,
    this.clipBehavior = Clip.none, // 2. 기본값을 설정합니다.
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: clipBehavior, // 3. 여기에 추가된 속성을 전달합니다.
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.basicShadow,
            blurRadius: 11.8,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
