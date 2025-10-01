import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';

class CustomButtonLarge extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Color? color;
  final Color? textColor;
  final TextStyle? textStyle;
  final bool showIcon;

  const CustomButtonLarge({
    super.key,
    required this.text,
    this.onPressed,
    this.width = 320,
    this.height = 61,
    this.color = AppColors.violet,
    this.textColor = AppColors.black,
    this.textStyle,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        shadowColor: AppColors.basicShadow,
        elevation: 6,
        fixedSize: (width != null && height != null)
            ? Size(width!, height!)
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle:
            textStyle ??
            AppFonts.titleSmall.copyWith(fontWeight: FontWeight.w500),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text),
          if (showIcon) const SizedBox(width: 8),
          if (showIcon) const Icon(Icons.arrow_forward, size: 20),
        ],
      ),
    );
  }
}
