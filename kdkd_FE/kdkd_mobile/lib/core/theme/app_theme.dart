import 'package:flutter/material.dart';
import 'package:kdkd_mobile/core/theme/colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(useMaterial3: true);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),

    scaffoldBackgroundColor: AppColors.grayBG,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      shadowColor: Colors.black26,
      titleTextStyle: TextStyle(
        fontFamily: "Chab",
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    ),
  );
}
