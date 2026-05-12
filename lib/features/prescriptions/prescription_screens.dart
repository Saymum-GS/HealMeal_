import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/common/healmeal_app_bar.dart';
import '../../core/widgets/common/healmeal_button.dart';
import '../../core/widgets/common/healmeal_text_field.dart';
import '../../core/widgets/common/info_banner.dart';
import '../../core/widgets/common/status_badge.dart';
import '../../core/utils/image_upload_util.dart';
import '../../core/utils/app_session.dart';
import '../../core/repositories/prescription_repository.dart';
import '../cart/cubit/cart_cubit.dart';
import '../prescriptions/cubit/prescription_cubit.dart';
import '../prescriptions/cubit/prescription_state.dart';
import '../../core/data/models.dart';
import '../../core/localization/app_localizations.dart';

class PrescriptionListScreen extends StatelessWidget {
  const PrescriptionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AppSession.userId;
    if (userId == null) {
      return const Scaffold(
        appBar: HealMealAppBar(title: 'My Prescriptions', showBack: true),
        body: Center(child: Text('Please login to see your prescriptions')),
      );
    }

    return Scaffold(
      appBar: const HealMealAppBar(title: 'My Prescriptions', showBack: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/prescriptions/upload'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Upload'),
      ),
      body: StreamBuilder<List<Prescription>>(
        stream: PrescriptionRepository().getUserPrescriptions(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final prescriptions = snapshot.data ?? [];

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: prescriptions.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return const InfoBanner(
                  title: 'Upload prescription & get 10% OFF + Cashback',
                  body:
                      'Submit a clear photo or PDF and our pharmacist team will call you.',
                  type: InfoBannerType.info,
                );
              }

              final rx = prescriptions[index - 1];
              final String title = rx.fileName ?? 'Prescription';
              final DateTime uploadedAt = rx.uploadedAt;
              String dateStr = '${uploadedAt.day} ${_getMonth(uploadedAt.month)} ${uploadedAt.year}';
              final String status = rx.status.name;

              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: AppRadius.lg,
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppRadius.md,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.description_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(title, style: AppTextStyles.h3),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Uploaded on $dateStr',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    StatusBadge(status: status),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}

class PrescriptionUploadScreen extends StatefulWidget {
  const PrescriptionUploadScreen({super.key});

  @override
  State<PrescriptionUploadScreen> createState() =>
      _PrescriptionUploadScreenState();
}

class _PrescriptionUploadScreenState extends State<PrescriptionUploadScreen> {
  final TextEditingController _noteController = TextEditingController();
  Uint8List? _selectedBytes;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a prescription image.'),
        ),
      );
      return;
    }

    final cubit = context.read<PrescriptionCubit>();
    await cubit.upload(_selectedBytes!, 'prescription_${DateTime.now().millisecondsSinceEpoch}.jpg');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrescriptionCubit, PrescriptionState>(
      listener: (context, state) {
        if (state.status == PrescriptionCubitStatus.success) {
          context.read<CartCubit>().setPrescriptionApproved(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Prescription uploaded successfully!')),
          );
          context.pop();
        } else if (state.status == PrescriptionCubitStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${state.errorMessage}')),
          );
        }
      },
      child: BlocBuilder<PrescriptionCubit, PrescriptionState>(
        builder: (context, state) {
          return Scaffold(
            appBar: const HealMealAppBar(
              title: 'Upload Prescription',
              showBack: true,
            ),
            body: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: AppRadius.lg,
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: ExpansionTile(
                    title: const Text('Tips for a good photo'),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: const <Widget>[
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.check_circle_outline),
                        title: Text('Make sure the whole prescription is visible'),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.check_circle_outline),
                        title: Text('Use enough light and avoid blur'),
                      ),
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.check_circle_outline),
                        title: Text('Keep doctor name and medicine details readable'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Prescription File', style: AppTextStyles.h2),
                const SizedBox(height: AppSpacing.md),
                if (_selectedBytes == null)
                  InkWell(
                    onTap: () async {
                      final file = await ImageUploadUtil.pickImage();
                      if (file != null && mounted) {
                        final bytes = await file.readAsBytes();
                        setState(() => _selectedBytes = bytes);
                      }
                    },
                    borderRadius: AppRadius.lg,
                    child: DottedBorder(
                      color: AppColors.primary,
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(16),
                      dashPattern: const <double>[8, 5],
                      child: Container(
                        height: 180,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.upload_file_rounded,
                              size: 42,
                              color: AppColors.primary,
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Text('Upload Prescription', style: AppTextStyles.h3),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              'Camera / Gallery',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Stack(
                    children: [
                      Container(
                        height: 240,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: AppRadius.lg,
                          image: DecorationImage(
                            image: MemoryImage(_selectedBytes!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () => setState(() => _selectedBytes = null),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: AppSpacing.lg),
                HealMealTextField(
                  controller: _noteController,
                  label: 'Note (optional)',
                  maxLines: 3,
                  minLines: 2,
                ),
                const SizedBox(height: AppSpacing.xl),
                HealMealButton(
                  label: 'Upload',
                  size: ButtonSize.large,
                  isLoading: state.status == PrescriptionCubitStatus.uploading,
                  onPressed: state.status == PrescriptionCubitStatus.uploading ? null : _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
