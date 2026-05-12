import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/data/models.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/common/healmeal_button.dart';
import '../../../core/widgets/common/status_badge.dart';
import '../common/role_widgets.dart';
import 'cubit/lab_tech_cubit.dart';

class LabTechDashboardScreen extends StatelessWidget {
  const LabTechDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LabTechCubit, LabTechState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.strings.labTechDashboard),
              actions: <Widget>[
                IconButton(
                  onPressed: () => logout(context),
                  icon: const Icon(Icons.logout_rounded),
                  tooltip: context.strings.logout,
                ),
              ],
              bottom: TabBar(
                isScrollable: true,
                tabs: <Tab>[
                  Tab(text: '${context.strings.today} (${state.todayBookings.length})'),
                  Tab(text: '${context.strings.pending} (${state.pendingBookings.length})'),
                  Tab(text: '${context.strings.delivered} (${state.completedBookings.length})'),
                ],
              ),
            ),
            body: Column(
              children: <Widget>[
                _LabTechHeader(state: state),
                Expanded(
                  child: TabBarView(
                    children: [
                      _LabBookingList(bookings: state.todayBookings),
                      _LabBookingList(bookings: state.pendingBookings),
                      _LabBookingList(bookings: state.completedBookings),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LabTechHeader extends StatelessWidget {
  const _LabTechHeader({required this.state});
  final LabTechState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _LabStat(label: context.strings.today, value: '${state.todayBookings.length}', icon: Icons.calendar_today_rounded),
          _LabStat(label: context.strings.pending, value: '${state.pendingBookings.length}', icon: Icons.pending_actions_rounded),
          _LabStat(label: context.strings.delivered, value: '${state.completedBookings.length}', icon: Icons.task_alt_rounded),
        ],
      ),
    );
  }
}

class _LabStat extends StatelessWidget {
  const _LabStat({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.h2),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary)),
      ],
    );
  }
}

class _LabBookingList extends StatelessWidget {
  const _LabBookingList({required this.bookings});

  final List<LabBooking> bookings;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.science_outlined, size: 48, color: AppColors.muted),
              const SizedBox(height: AppSpacing.md),
              Text(context.strings.noBookingsFound, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return RoleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.md,
                    ),
                    child: const Icon(Icons.science_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(booking.testName, style: AppTextStyles.h3),
                        Text('${context.strings.account}: ${booking.patientName}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.secondary)),
                      ],
                    ),
                  ),
                  StatusBadge(status: booking.status.name),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (booking.status == LabBookingStatus.upcoming)
                HealMealButton(
                  label: context.strings.markCollected,
                  size: ButtonSize.small,
                  onPressed: () => context.read<LabTechCubit>().markCollected(booking.id),
                )
              else if (booking.status == LabBookingStatus.collected)
                HealMealButton(
                  label: context.strings.uploadReport,
                  size: ButtonSize.small,
                  backgroundColor: AppColors.info,
                  onPressed: () => _showUploadDialog(context, booking.id),
                )
              else if (booking.status == LabBookingStatus.resultReady)
                HealMealButton(
                  label: context.strings.viewReport,
                  size: ButtonSize.small,
                  type: ButtonType.outlined,
                  onPressed: () {}, // Simulated view
                ),
            ],
          ),
        );
      },
    );
  }

  void _showUploadDialog(BuildContext context, String bookingId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(context.strings.uploadReport),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.picture_as_pdf_outlined, size: 48, color: AppColors.primary),
              const SizedBox(height: AppSpacing.md),
              Text(context.strings.uploadReport),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<LabTechCubit>().uploadReport(bookingId, 'https://example.com/report.pdf');
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.strings.reportUploaded)),
                );
              },
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }
}
