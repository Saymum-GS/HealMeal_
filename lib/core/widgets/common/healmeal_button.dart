import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../constants/app_spacing.dart';

enum ButtonType { filled, outlined, text }

enum ButtonSize { large, medium, small }

class HealMealButton extends StatelessWidget {
  const HealMealButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = ButtonType.filled,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.prefixIcon,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final IconData? prefixIcon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  double get _height => switch (size) {
    ButtonSize.large => 52,
    ButtonSize.medium => 44,
    ButtonSize.small => 36,
  };

  @override
  Widget build(BuildContext context) {
    final Color filledBackground = backgroundColor ?? AppColors.primary;
    final Brightness brightness = ThemeData.estimateBrightnessForColor(
      filledBackground,
    );
    final Color resolvedFilledForeground =
        foregroundColor ??
        (brightness == Brightness.dark ? AppColors.white : AppColors.textDark);
    final Color resolvedLineForeground = foregroundColor ?? AppColors.primary;

    final child = AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: isLoading
          ? SizedBox(
              key: const ValueKey('loader'),
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: type == ButtonType.filled
                    ? resolvedFilledForeground
                    : resolvedLineForeground,
              ),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Text(label),
              ],
            ),
    );

    final filledStyle = FilledButton.styleFrom(
      minimumSize: Size(double.infinity, _height),
      backgroundColor: filledBackground,
      foregroundColor: resolvedFilledForeground,
      disabledBackgroundColor: AppColors.subtle,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
      textStyle: AppTextStyles.labelLarge,
    );

    final outlinedStyle = OutlinedButton.styleFrom(
      minimumSize: Size(double.infinity, _height),
      side: const BorderSide(color: AppColors.primary),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
      textStyle: AppTextStyles.labelLarge,
      foregroundColor: resolvedLineForeground,
    );

    final textStyle = TextButton.styleFrom(
      minimumSize: Size(double.infinity, _height),
      textStyle: AppTextStyles.labelLarge,
      foregroundColor: resolvedLineForeground,
    );

    return switch (type) {
      ButtonType.filled => FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: filledStyle,
        child: child,
      ),
      ButtonType.outlined => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: outlinedStyle,
        child: child,
      ),
      ButtonType.text => TextButton(
        onPressed: isLoading ? null : onPressed,
        style: textStyle,
        child: child,
      ),
    };
  }
}

