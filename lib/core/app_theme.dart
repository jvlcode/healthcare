import 'package:flutter/material.dart';
import 'constants/colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,

    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
    ),

    // textTheme: TextTheme(
    //   headline: AppTextStyles.heading,
    //   bodyText2: AppTextStyles.body,
    // ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textLight,
    ),
  );
}
