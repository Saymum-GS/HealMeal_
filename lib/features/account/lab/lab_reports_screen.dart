import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/data/models.dart';
import '../../../core/repositories/lab_repository.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/utils/app_session.dart';
import '../../../core/widgets/common/empty_state_widget.dart';
import '../../../core/widgets/common/healmeal_app_bar.dart';

class LabReportsScreen extends StatelessWidget {
  const LabReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AppSession.userId;
    if (userId == null) {
      return const Scaffold(
        appBar: HealMealAppBar(title: 'My Lab Reports', showBack: true),
        body: Center(child: Text('Please login to see your reports')),
      );
    }

    return Scaffold(
      appBar: const HealMealAppBar(title: 'My Lab Reports', showBack: true),
      body: StreamBuilder<List<LabBooking>>(
        stream: LabRepository().watchUserBookings(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = (snapshot.data ?? []).where((b) => b.status == LabBookingStatus.resultReady || b.reportUrl != null).toList();

          if (reports.isEmpty) {
            return EmptyStateWidget(
              type: EmptyStateType.labTests,
              customTitle: 'No reports yet',
              customBody: 'Your lab test reports will appear here after completion.',
              actionLabel: 'Book a Lab Test',
              onAction: () => context.go('/lab-test'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: reports.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (BuildContext context, int index) {
              final report = reports[index];
              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: AppRadius.lg,
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: <Widget>[
                    const CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.science_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(report.testName, style: AppTextStyles.h3),
                          Text(
                            'Patient: ${report.patientName}',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary),
                          ),
                          Text(
                            AppFormatters.longDate(report.selectedDate),
                            style: AppTextStyles.bodyXSmall.copyWith(color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _viewReport(context, report.reportUrl),
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                      label: const Text('View PDF'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _viewReport(BuildContext context, String? url) async {
    if (url == null) return;
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open report.')),
      );
    }
  }
}
