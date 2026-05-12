import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/models.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/common/healmeal_app_bar.dart';
import '../../../core/widgets/common/healmeal_button.dart';
import '../../../core/widgets/common/healmeal_text_field.dart';
import '../../../core/repositories/offer_repository.dart';
import 'cubit/admin_cubit.dart';

class AdminOfferManagementScreen extends StatefulWidget {
  const AdminOfferManagementScreen({super.key});

  @override
  State<AdminOfferManagementScreen> createState() => _AdminOfferManagementScreenState();
}

class _AdminOfferManagementScreenState extends State<AdminOfferManagementScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _addOffer() async {
    if (_titleController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    final repo = OfferRepository();
    final newOffer = AppOffer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descController.text,
      colors: [AppColors.primary, AppColors.primaryDark],
      discountPercent: 10,
    );
    
    await repo.addOffer(newOffer);
    if (mounted) {
      _titleController.clear();
      _descController.clear();
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Offer Added!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HealMealAppBar(title: 'Manage Offers', showBack: true),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Text("Add New Offer", style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),
              HealMealTextField(controller: _titleController, label: "Offer Title"),
              const SizedBox(height: AppSpacing.sm),
              HealMealTextField(controller: _descController, label: "Description", maxLines: 2),
              const SizedBox(height: AppSpacing.md),
              HealMealButton(label: "Save Offer", onPressed: _addOffer, isLoading: _isLoading),
              const Divider(height: 40),
              Text("Current Offers", style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),
              ...state.currentOffers.map((offer) => ListTile(
                title: Text(offer.title),
                subtitle: Text(offer.description),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: () => context.read<AdminCubit>().deleteOffer(offer.id),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}
