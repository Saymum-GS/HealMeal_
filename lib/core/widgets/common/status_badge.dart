import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    Color bg;
    Color fg;
    if (normalized.contains('deliver')) {
      bg = AppColors.successBg;
      fg = AppColors.success;
    } else if (normalized.contains('cancel')) {
      bg = AppColors.errorBg;
      fg = AppColors.error;
    } else if (normalized.contains('dispatch') || normalized.contains('out')) {
      bg = AppColors.infoBg;
      fg = AppColors.info;
    } else if (normalized.contains('process') ||
        normalized.contains('confirm')) {
      bg = AppColors.warningBg;
      fg = AppColors.warning;
    } else {
      bg = AppColors.primaryLight;
      fg = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.pill),
      child: Text(status, style: AppTextStyles.labelSmall.copyWith(color: fg)),
    );
  }
}

