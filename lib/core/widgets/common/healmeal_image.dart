import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../constants/app_assets.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_text_styles.dart';

class HealMealImage extends StatelessWidget {
  const HealMealImage({
    super.key,
    required this.imageUrl,
    this.label,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.icon = Icons.medication_rounded,
  });

  final String? imageUrl;
  final String? label;
  final double? height;
  final double? width;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData icon;

  bool get _isBase64 {
    final String value = imageUrl ?? '';
    return value.startsWith('data:image') || 
           (value.length > 100 && !value.startsWith('http') && !value.startsWith('assets/'));
  }

  bool get _useFallback {
    final String value = imageUrl ?? '';
    return value.isEmpty ||
        (!_isBase64 && (value.contains('via.placeholder.com') || value.contains('placeholder.com')));
  }

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = borderRadius ?? AppRadius.md;
    
    Widget child;
    if (_useFallback) {
      child = _FallbackImage(label: label, icon: icon);
    } else if (_isBase64) {
      try {
        final String base64Data = imageUrl!.contains(',') 
            ? imageUrl!.split(',').last 
            : imageUrl!;
        child = Image.memory(
          base64Decode(base64Data),
          fit: fit,
          errorBuilder: (_, __, ___) => _FallbackImage(label: label, icon: icon),
        );
      } catch (e) {
        child = _FallbackImage(label: label, icon: icon);
      }
    } else {
      child = CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: fit,
        placeholder: (_, __) => const _FallbackImage(isLoading: true),
        errorWidget: (_, __, ___) =>
            _FallbackImage(label: label, icon: icon),
      );
    }

    return SizedBox(
      height: height,
      width: width,
      child: ClipRRect(borderRadius: radius, child: child),
    );
  }
}

class _FallbackImage extends StatelessWidget {
  const _FallbackImage({
    this.label,
    this.icon = Icons.local_hospital_rounded,
    this.isLoading = false,
  });

  final String? label;
  final IconData icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final String text = (label == null || label!.trim().isEmpty)
        ? 'HealMeal'
        : label!.trim();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool ultraCompact = constraints.maxHeight <= 72;
        final bool compact =
            constraints.maxHeight <= 96 || constraints.maxWidth <= 120;
        final double padding = ultraCompact
            ? AppSpacing.sm
            : (compact ? 10 : AppSpacing.md);
        final double logoSize = ultraCompact ? 18 : (compact ? 20 : 24);
        final double iconSize = ultraCompact ? 20 : (compact ? 22 : 28);

        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[AppColors.primaryLight, Color(0xFFF4FAF8)],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Positioned(
                right: ultraCompact ? -6 : -8,
                top: ultraCompact ? -6 : -8,
                child: Container(
                  width: ultraCompact ? 34 : 48,
                  height: ultraCompact ? 34 : 48,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(.45),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(padding),
                child: ultraCompact
                    ? Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                icon,
                                color: AppColors.primary,
                                size: iconSize,
                              ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.asset(
                                  AppAssets.logo,
                                  height: logoSize,
                                  width: logoSize,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(
                                    icon,
                                    color: AppColors.primary,
                                    size: logoSize,
                                  ),
                                ),
                              ),
                              if (!compact) const SizedBox(width: 8),
                              if (!compact)
                                Flexible(
                                  child: Text(
                                    'HealMeal',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.labelLarge.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          if (isLoading)
                            const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                            )
                          else
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  icon,
                                  color: AppColors.primary,
                                  size: iconSize,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    text,
                                    maxLines: compact ? 1 : 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

