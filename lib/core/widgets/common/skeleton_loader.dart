import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_spacing.dart';

class _SkeletonBase extends StatelessWidget {
  const _SkeletonBase({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.subtle,
      highlightColor: AppColors.white,
      child: child,
    );
  }
}

class SkeletonProductCard extends StatelessWidget {
  const SkeletonProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return _SkeletonBase(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.md,
        ),
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppRadius.md,
              ),
            ),
            const SizedBox(height: 12),
            Container(height: 12, color: AppColors.border),
            const SizedBox(height: 8),
            Container(height: 12, width: 100, color: AppColors.border),
            const Spacer(),
            Container(
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: AppRadius.md,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonOrderCard extends StatelessWidget {
  const SkeletonOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SkeletonBase(
      child: ListTile(
        title: SizedBox(height: 12, child: ColoredBox(color: AppColors.border)),
        subtitle: SizedBox(
          height: 12,
          child: ColoredBox(color: AppColors.border),
        ),
      ),
    );
  }
}

class SkeletonLabTestCard extends StatelessWidget {
  const SkeletonLabTestCard({super.key});

  @override
  Widget build(BuildContext context) => const SkeletonOrderCard();
}

class SkeletonNotificationItem extends StatelessWidget {
  const SkeletonNotificationItem({super.key});

  @override
  Widget build(BuildContext context) => const SkeletonOrderCard();
}

