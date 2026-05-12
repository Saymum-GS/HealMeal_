import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

ThemeData buildDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'NotoSansBengali',
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentTeal,
      secondary: AppColors.accentPurple,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPri,
      error: AppColors.error,
    ),
  );

  return base.copyWith(
    primaryColorLight: AppColors.primary.withOpacity(0.15),
    primaryColorDark: AppColors.primaryDark,
    cardColor: AppColors.darkCard,
    dividerColor: AppColors.darkBorder,
    splashColor: AppColors.accentTeal.withOpacity(0.08),
    highlightColor: AppColors.accentTeal.withOpacity(0.04),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPri,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTextStyles.h2.copyWith(
        color: AppColors.darkTextPri,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.lg,
        side: BorderSide(color: AppColors.darkBorder.withOpacity(0.5)),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedColor: AppColors.primaryDark,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: AppColors.darkTextPri,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.pill,
      ),
      side: BorderSide(color: AppColors.darkBorder),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkCard,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: AppRadius.md,
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.md,
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.md,
        borderSide: const BorderSide(color: AppColors.accentTeal, width: 1.5),
      ),
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkMuted),
      labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkTextSec),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.accentTeal,
      unselectedItemColor: AppColors.darkMuted,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentTeal,
        foregroundColor: AppColors.darkBg,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accentTeal,
        side: const BorderSide(color: AppColors.accentTeal),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
      backgroundColor: AppColors.darkCard,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.accentTeal,
      unselectedLabelColor: AppColors.darkMuted,
      indicatorColor: AppColors.accentTeal,
      labelStyle: AppTextStyles.labelLarge,
      unselectedLabelStyle: AppTextStyles.bodyMedium,
      dividerHeight: 0,
    ),
    textTheme:
        const TextTheme(
          headlineLarge: AppTextStyles.h1,
          headlineMedium: AppTextStyles.h2,
          headlineSmall: AppTextStyles.h3,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.labelLarge,
          labelMedium: AppTextStyles.labelMedium,
          labelSmall: AppTextStyles.labelSmall,
        ).apply(
          bodyColor: AppColors.darkTextPri,
          displayColor: AppColors.darkTextPri,
        ),
  );
}

