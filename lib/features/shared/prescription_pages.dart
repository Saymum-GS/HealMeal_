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
import '../cart/cubit/cart_cubit.dart';

class PrescriptionListScreen extends StatelessWidget {
  const PrescriptionListScreen({super.key});

  static const List<(String, String, String)> _prescriptions =
      <(String, String, String)>[
        ('Prescription - 01', '05 Apr 2026', 'approved'),
        ('Prescription - 02', '02 Apr 2026', 'pending'),
        ('Prescription - 03', '29 Mar 2026', 'rejected'),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(title: 'My Prescriptions', showBack: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/prescriptions/upload'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Upload'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _prescriptions.length + 1,
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

          final rx = _prescriptions[index - 1];
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
                      Text(rx.$1, style: AppTextStyles.h3),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Uploaded on ${rx.$2}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                StatusBadge(status: rx.$3),
              ],
            ),
          );
        },
      ),
    );
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
  int _files = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_files == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one prescription image or file.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    context.read<CartCubit>().setPrescriptionApproved(true);
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Submitted! Pharmacist will call you shortly.'),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
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
          Text('Prescription Files', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.md),
          if (_files == 0)
            InkWell(
              onTap: () => setState(() => _files = 1),
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
                        'Camera / Gallery / PDF',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                mainAxisExtent: 92,
              ),
              itemCount: _files + (_files < 5 ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (index == _files && _files < 5) {
                  return InkWell(
                    onTap: () => setState(() => _files += 1),
                    borderRadius: AppRadius.md,
                    child: DottedBorder(
                      color: AppColors.primary,
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: AppRadius.md,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }

                return Stack(
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: AppRadius.md,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.description_outlined,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () => setState(() => _files -= 1),
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.white,
                          child: Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
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
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
