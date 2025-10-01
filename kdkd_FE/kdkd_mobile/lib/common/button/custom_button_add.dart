import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';

class CustomButtonAdd extends StatelessWidget {
  final VoidCallback? onPressed;

  const CustomButtonAdd({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violet,
          shadowColor: AppColors.basicShadow,
          elevation: 6,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Icon(Icons.add, color: AppColors.white, size: 24),
      ),
    );
  }
}
