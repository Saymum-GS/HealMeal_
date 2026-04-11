import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class BrandLockup extends StatelessWidget {
  const BrandLockup({
    super.key,
    this.onDark = false,
    this.iconSize = 34,
    this.showTagline = false,
    this.center = false,
  });

  final bool onDark;
  final double iconSize;
  final bool showTagline;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final Color primaryText = onDark ? AppColors.white : AppColors.textDark;
    final Color accentText = onDark ? AppColors.primaryMid : AppColors.primary;
    final Color mutedText = onDark
        ? AppColors.primaryLight
        : AppColors.secondary;

    return Row(
      mainAxisSize: center ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: center
          ? MainAxisAlignment.center
          : MainAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(iconSize * .32),
          child: Image.asset(
            AppAssets.logo,
            height: iconSize,
            width: iconSize,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: iconSize,
              width: iconSize,
              decoration: BoxDecoration(
                color: onDark
                    ? AppColors.white.withOpacity(.12)
                    : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(iconSize * .32),
              ),
              child: Icon(
                Icons.add_rounded,
                size: iconSize * .68,
                color: accentText,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: center
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: <Widget>[
              RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Heal',
                      style: AppTextStyles.h2.copyWith(
                        color: primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: 'Meal',
                      style: AppTextStyles.h2.copyWith(
                        color: accentText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (showTagline)
                Text(
                  'Healthcare at your doorstep',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(color: mutedText),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
