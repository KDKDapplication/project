import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';

class CustomButtonHalfRound extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final TextStyle? textStyle;
  final double? height;

  const CustomButtonHalfRound({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.textStyle,
    this.height = 63,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: AppColors.white,
          shape: LinearBorder(),
          // const RoundedRectangleBorder(
          //   borderRadius: BorderRadius.vertical(bottom: Radius.circular(31.5)),
          // ),
          textStyle: textStyle ?? AppFonts.labelLarge.copyWith(height: 1.2),
        ),
        child: Text(text),
      ),
    );
  }
}
