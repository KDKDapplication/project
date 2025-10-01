import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/padding.dart';
import 'package:kdkd_mobile/routes/app_routes.dart';

class CollectionAnalysisButton extends StatelessWidget {
  const CollectionAnalysisButton({super.key, required this.buttonAreaHeight, required this.buttonAreaMargin});

  final double buttonAreaHeight;
  final double buttonAreaMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: buttonAreaHeight,
      padding: EdgeInsets.symmetric(horizontal: AppConst.padding),
      margin: EdgeInsets.only(bottom: buttonAreaMargin),
      color: AppColors.grayBG,
      child: ElevatedButton(
        onPressed: () {
          context.push(AppRoutes.parentCollectionAnalysis);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violet,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          minimumSize: const Size(double.infinity, 54), // Full width
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '소비패턴 보러가기',
              style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SvgPicture.asset(
              'assets/svgs/arrow2.svg',
              height: 16,
              width: 16,
            ),
          ],
        ),
      ),
    );
  }
}
