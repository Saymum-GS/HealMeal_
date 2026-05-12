import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/data/models.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/common/healmeal_app_bar.dart';
import '../../../core/widgets/common/healmeal_button.dart';
import '../../../core/widgets/common/healmeal_image.dart';
import '../../../core/widgets/common/healmeal_text_field.dart';
import '../../../core/widgets/common/status_badge.dart';
import '../common/role_widgets.dart';
import 'cubit/pharmacist_cubit.dart';

class PharmacistDashboardScreen extends StatelessWidget {
  const PharmacistDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PharmacistCubit, PharmacistState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(context.strings.businessDashboard),
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
                  Tab(text: '${context.strings.pending} (${state.pendingPrescriptions.length})'),
                  Tab(text: 'Reviewed (${state.reviewedPrescriptions.length})'),
                  Tab(text: '${context.strings.all} (${state.pendingPrescriptions.length + state.reviewedPrescriptions.length})'),
                ],
              ),
            ),
            body: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: StatCard(title: context.strings.pending, value: '${state.pendingPrescriptions.length}'),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: StatCard(title: 'Reviewed', value: '${state.reviewedPrescriptions.length}'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: <Widget>[
                      _PrescriptionQueue(prescriptions: state.pendingPrescriptions),
                      _PrescriptionQueue(prescriptions: state.reviewedPrescriptions),
                      _PrescriptionQueue(prescriptions: [...state.pendingPrescriptions, ...state.reviewedPrescriptions]),
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

class PrescriptionReviewScreen extends StatefulWidget {
  const PrescriptionReviewScreen({super.key, required this.id});

  final String id;

  @override
  State<PrescriptionReviewScreen> createState() =>
      _PrescriptionReviewScreenState();
}

class _PrescriptionReviewScreenState extends State<PrescriptionReviewScreen> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PharmacistCubit, PharmacistState>(
      builder: (context, state) {
        final all = [...state.pendingPrescriptions, ...state.reviewedPrescriptions];
        final prescription = all.firstWhere(
          (p) => p.id == widget.id, 
          orElse: () => Prescription(id: '', userId: '', imageUrl: '', status: PrescriptionStatus.pending, uploadedAt: DateTime.now())
        );
        if (prescription.id.isEmpty) return const Scaffold(body: Center(child: Text('Not found')));

        return Scaffold(
          appBar: HealMealAppBar(
            title: context.strings.approveRx,
            showBack: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: <Widget>[
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: AppRadius.lg,
                ),
                child: HealMealImage(
                  imageUrl: prescription.imageUrl,
                  label: 'Prescription',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              RoleCard(
                title: context.strings.orderReview,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'User ID: ${prescription.userId}',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Text('Status: ', style: AppTextStyles.bodySmall),
                        StatusBadge(status: prescription.status.name),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Mapped Products: ${prescription.mappedProductIds.length}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              HealMealButton(
                label: 'Map Medicines to Order',
                type: ButtonType.outlined,
                onPressed: () => _showMappingDialog(context, prescription.id),
              ),
              const SizedBox(height: AppSpacing.md),
              HealMealTextField(
                controller: _noteController,
                label: 'Add pharmacist note',
                maxLines: 3,
                minLines: 3,
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: HealMealButton(
                    label: 'Reject',
                    type: ButtonType.outlined,
                    onPressed: () {
                      context.read<PharmacistCubit>().updateStatus(widget.id, PrescriptionStatus.rejected, _noteController.text);
                      context.pop();
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: HealMealButton(
                    label: context.strings.approveRx,
                    backgroundColor: AppColors.success,
                    onPressed: () {
                      context.read<PharmacistCubit>().updateStatus(widget.id, PrescriptionStatus.approved, _noteController.text);
                      context.pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMappingDialog(BuildContext context, String id) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Map Medicines'),
          content: const Text('Simulating product search... Would you like to map "Napa Extra" and "Ace Plus" to this prescription?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<PharmacistCubit>().updateMappedProducts(id, ['prod-napa-extra', 'prod-ace-plus']);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Medicines mapped to order')),
                );
              },
              child: const Text('Map & Link'),
            ),
          ],
        );
      },
    );
  }
}

class _PrescriptionQueue extends StatelessWidget {
  const _PrescriptionQueue({required this.prescriptions});

  final List<Prescription> prescriptions;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: prescriptions.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (BuildContext context, int index) {
        final prescription = prescriptions[index];
        return RoleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: AppRadius.md,
                    ),
                    child: HealMealImage(
                      imageUrl: prescription.imageUrl,
                      label: 'Rx',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Prescription #${prescription.id.substring(0, 5)}',
                          style: AppTextStyles.h3,
                        ),
                        Text(
                          'User ID: ${prescription.userId}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        StatusBadge(status: prescription.status.name),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.push(
                        '/pharmacist/prescription/${prescription.id}',
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: HealMealButton(
                      label: 'Approve',
                      size: ButtonSize.small,
                      backgroundColor: AppColors.success,
                      onPressed: () {
                        context.read<PharmacistCubit>().updateStatus(prescription.id, PrescriptionStatus.approved, '');
                      },
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
