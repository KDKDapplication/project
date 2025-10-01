import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:kdkd_mobile/common/format/string_format.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';

class CustomCard extends StatelessWidget {
  final String accountName;
  final String accountNumber;
  final int? balance;
  final String? characterImagePath;
  final Color? color;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.accountName,
    required this.accountNumber,
    this.balance,
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
              // 계좌 이름
              Positioned(
                top: 14,
                left: 18,
                child: Text(
                  accountName,
                  style: AppFonts.headlineLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
              // 계좌 번호
              Positioned(
                top: 43,
                left: 18,
                child: Text(
                  accountNumber != "" ? StringFormat.formatAccountNumber(accountNumber) : "계좌가 없습니다.",
                  style: AppFonts.bodySmall.copyWith(color: AppColors.white),
                ),
              ),
              // 잔액
              Positioned(
                bottom: 15,
                left: 18,
                child: Text(
                  balance == null || balance == 0 ? "" : '${NumberFormat('#,###').format(balance)}원',
                  style: AppFonts.headlineMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
