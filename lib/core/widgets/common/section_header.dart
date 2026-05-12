import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onSeeAll,
    this.showSeeAll = true,
    this.trailing,
  });

  final String title;
  final VoidCallback? onSeeAll;
  final bool showSeeAll;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(title, style: AppTextStyles.h2)),
        if (trailing != null) ...<Widget>[trailing!, const SizedBox(width: 8)],
        if (showSeeAll && onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'See All →',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

