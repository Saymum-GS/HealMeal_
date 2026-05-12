import 'package:flutter/material.dart';
import 'package:healmeal_app/core/constants/app_colors.dart';
import 'package:healmeal_app/core/constants/app_spacing.dart';
import 'package:healmeal_app/core/constants/app_text_styles.dart';
import 'package:healmeal_app/core/utils/app_formatters.dart';
import 'package:healmeal_app/core/widgets/common/empty_state_widget.dart';
import 'package:healmeal_app/core/widgets/common/status_badge.dart';
import '../lab_data.dart';

class LabOrderList extends StatelessWidget {
  const LabOrderList({super.key, required this.items});

  final List<LabOrderData> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const EmptyStateWidget(type: EmptyStateType.orders);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (BuildContext context, int index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: AppRadius.lg,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(item.id, style: AppTextStyles.labelLarge),
                  ),
                  Text(
                    AppFormatters.longDate(item.date),
                    style: AppTextStyles.bodyXSmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  StatusBadge(status: item.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(item.testName, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Patient: ${item.patientName} | ${item.ageGender}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Sample Collection: ${item.collectionSlot}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const Divider(height: AppSpacing.xl),
              Row(
                children: <Widget>[
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (item.status == 'completed') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('View Report')),
                        );
                      }
                    },
                    child: Text(
                      item.status == 'completed'
                          ? 'View Report'
                          : 'View Booking',
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
