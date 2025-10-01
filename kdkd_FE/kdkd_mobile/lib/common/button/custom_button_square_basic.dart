import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';

class CustomButtonSquareBasic extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Color? color;
  final Color? textColor;
  final TextStyle? textStyle;

  const CustomButtonSquareBasic({
    super.key,
    this.text = '확인',
    this.onPressed,
    this.width = 88,
    this.height = 36,
    this.color = AppColors.mint,
    this.textColor = AppColors.black,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        shadowColor: AppColors.basicShadow,
        elevation: 6, // drop-shadow 효과를 위해 elevation 값 조정
        fixedSize: (width != null && height != null)
            ? Size(width!, height!)
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle:
            textStyle ??
            AppFonts.labelMedium.copyWith(
              fontSize: 16,
              letterSpacing: -0.04 * 16, // em to logical pixels
            ),
      ),
      child: Text(text),
    );
  }
}
