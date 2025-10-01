import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';

class CustomCardInitial extends StatelessWidget {
  final String? characterImagePath;
  final Color? color;
  final VoidCallback? onTap;

  const CustomCardInitial({
    super.key,
    this.characterImagePath,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          clipBehavior: Clip.antiAlias, // overflow: hidden
          decoration: BoxDecoration(
            color: color ?? AppColors.violet,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.basicShadow,
                blurRadius: 11.8,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 캐릭터 이미지 (characterImagePath가 있을 경우에만 표시)
              if (characterImagePath != null)
                Positioned(
                  top: -15,
                  right: -35,
                  child: Transform.rotate(
                    angle: -13.72 * (math.pi / 180),
                    child: characterImagePath!.toLowerCase().endsWith('.svg')
                        ? SvgPicture.asset(
                            characterImagePath!,
                            width: 249,
                            height: 249,
                          )
                        : Image.asset(
                            characterImagePath!,
                            width: 249,
                            height: 249,
                          ),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SvgPicture.asset(
                    'assets/svgs/account_add.svg',
                    width: 44,
                    height: 44,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "계좌를 등록해주세요",
                    textAlign: TextAlign.center,
                    style: AppFonts.bodySmall.copyWith(
                      color: AppColors.grayBG,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
