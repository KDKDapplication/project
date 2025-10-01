import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';

class CustomButtonDate extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Color? color;
  final Color? textColor;
  final TextStyle? textStyle;

  const CustomButtonDate({
    super.key,
    required this.text,
    this.onPressed,
    this.width = 31,
    this.height = 31,
    this.color = AppColors.violet,
    this.textColor = AppColors.black,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          shadowColor: AppColors.basicShadow,
          elevation: 6,
          padding: EdgeInsets.zero,

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle:
              textStyle ??
              AppFonts.labelMedium.copyWith(fontSize: 13, letterSpacing: 0.5),
        ),
        child: Text(text),
      ),
    );
  }
}
