import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';

class SmallVerticalCardWidget extends StatelessWidget {
  const SmallVerticalCardWidget({
    super.key,
    this.accountName,
    this.accountNumber,
    required this.onTap,
  });

  final String? accountName;
  final String? accountNumber;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: AspectRatio(
          aspectRatio: 148 / 216,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xffFFD93D),
                  Color(0xff3DDC97),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.basicShadow,
                  offset: Offset(0, 6),
                  blurRadius: 11.8,
                ),
              ],
            ),
            child: accountNumber == null
                ? Center(
                    child: SvgPicture.asset(
                      'assets/svgs/account_add.svg',
                      width: 48,
                      height: 48,
                    ),
                  )
                : Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              accountName!,
                              style: AppFonts.labelLarge,
                            ),
                            Text(
                              accountNumber!,
                              style: AppFonts.labelSmall,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: -10,
                        bottom: -1,
                        width: 130,
                        child: Image.asset('assets/images/kids_duck.png'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
