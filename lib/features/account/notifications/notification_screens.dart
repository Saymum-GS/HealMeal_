import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/data/models.dart';
import '../../../core/data/notifications.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/widgets/common/empty_state_widget.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List<AppNotification>.from(initialNotifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('Notifications'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              setState(() {
                _notifications = _notifications
                    .map((AppNotification item) => item.copyWith(read: true))
                    .toList();
              });
            },
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 800));
          if (mounted) setState(() {});
        },
        child: _notifications.isEmpty
            ? const EmptyStateWidget(type: EmptyStateType.notifications)
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (BuildContext context, int index) {
                  final AppNotification item = _notifications[index];
                  final Color accent = switch (item.type) {
                    'order' => AppColors.primary,
                    'prescription' => AppColors.warning,
                    'lab' => AppColors.accentBlue,
                    _ => AppColors.accentOrange,
                  };
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: item.read
                          ? Theme.of(context).cardColor
                          : AppColors.primaryLight,
                      borderRadius: AppRadius.lg,
                      border: Border(
                        left: BorderSide(
                          color: item.read ? Colors.transparent : AppColors.primary,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: accent.withOpacity(.12),
                          child: Icon(_iconForType(item.type), color: accent),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                item.title,
                                style: AppTextStyles.h3.copyWith(
                                  fontWeight: item.read ? FontWeight.w500 : FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(item.body, style: AppTextStyles.bodySmall),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                AppFormatters.compactDateTime(item.time),
                                style: AppTextStyles.bodyXSmall.copyWith(
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'order': return Icons.local_shipping_outlined;
      case 'prescription': return Icons.description_outlined;
      case 'lab': return Icons.science_outlined;
      default: return Icons.local_offer_outlined;
    }
  }
}
