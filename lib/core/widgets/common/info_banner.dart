import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';

enum InfoBannerType { info, success, warning, error }

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.title,
    required this.body,
    this.type = InfoBannerType.info,
    this.trailing,
  });

  final String title;
  final String body;
  final InfoBannerType type;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (type) {
      InfoBannerType.info => (
        AppColors.infoBg,
        AppColors.info,
        Icons.info_outline_rounded,
      ),
      InfoBannerType.success => (
        AppColors.successBg,
        AppColors.success,
        Icons.check_circle_outline_rounded,
      ),
      InfoBannerType.warning => (
        AppColors.warningBg,
        AppColors.warning,
        Icons.warning_amber_rounded,
      ),
      InfoBannerType.error => (
        AppColors.errorBg,
        AppColors.error,
        Icons.error_outline_rounded,
      ),
    };
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(color: fg),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(body, style: AppTextStyles.bodySmall.copyWith(color: fg)),
              ],
            ),
          ),
          if (trailing case final widget?) widget,
        ],
      ),
    );
  }
}
