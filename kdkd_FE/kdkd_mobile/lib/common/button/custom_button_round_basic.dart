import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';
import 'package:kdkd_mobile/core/theme/fonts.dart';

class CustomButtonRoundBasic extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Color? color;
  final TextStyle? textStyle;
  final double paddingVertical;
  final double paddingHorizontal;

  const CustomButtonRoundBasic({
    super.key,
    this.text = '확인',
    this.onPressed,
    this.width = 76,
    this.height = 31,
    this.color = AppColors.violet,
    this.textStyle,
    this.paddingHorizontal = 14,
    this.paddingVertical = 7,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        animationDuration: const Duration(milliseconds: 200),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed)) {
            final baseColor = color ?? AppColors.violet;
            final hslColor = HSLColor.fromColor(baseColor);
            // 명도(lightness)를 10% 어둡게 조정
            final darkenedColor = hslColor.withLightness(
              (hslColor.lightness - 0.1).clamp(0.0, 1.0),
            );
            return darkenedColor.toColor();
          }
          return color; // 기본 상태 색상
        }),
        foregroundColor: WidgetStateProperty.all(AppColors.white),
        shadowColor: WidgetStateProperty.all(AppColors.btnShadow),
        elevation: WidgetStateProperty.resolveWith<double?>((states) {
          if (states.contains(WidgetState.pressed)) return 2.0; // 눌렸을 때 그림자 깊이 감소
          return 4.0; // 기본 그림자 깊이
        }),
        fixedSize: WidgetStateProperty.all(
          (width != null && height != null) ? Size(width!, height!) : null,
        ),
        padding: WidgetStateProperty.all(
          EdgeInsets.symmetric(
            vertical: paddingVertical,
            horizontal: paddingHorizontal,
          ),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        ),
        textStyle: WidgetStateProperty.all(AppFonts.labelMedium),
      ),
      child: Text(text),
    );
  }
}
