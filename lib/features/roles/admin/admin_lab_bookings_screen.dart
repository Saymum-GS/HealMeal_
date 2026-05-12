import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/app_formatters.dart';
import '../../../core/widgets/common/healmeal_app_bar.dart';
import '../../../core/widgets/common/status_badge.dart';
import 'cubit/admin_cubit.dart';

class AdminLabBookingScreen extends StatelessWidget {
  const AdminLabBookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Lab Bookings', showBack: true),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state.labBookings.isEmpty) {
            return const Center(child: Text("No lab bookings yet."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: state.labBookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final booking = state.labBookings[index];
              return Card(
                child: ListTile(
                  title: Text(booking.testName, style: AppTextStyles.h3),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Patient: ${booking.patientName} (${booking.age}, ${booking.gender})"),
                      Text("Date: ${AppFormatters.compactDateTime(booking.selectedDate)}"),
                      Text("Slot: ${booking.timeSlot}"),
                    ],
                  ),
                  trailing: StatusBadge(status: booking.status.name),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
